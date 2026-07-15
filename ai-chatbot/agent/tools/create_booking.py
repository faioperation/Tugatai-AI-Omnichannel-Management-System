import httpx
from langchain_core.tools import tool
from core.config import ROBERTO_API_BASE, ROBERTO_API_BASE_PUBLIC, ROBERTO_API_TOKEN
from agent.tools.http_fallback import build_candidates, post_with_fallback


VALID_CATEGORIES = {"ORDER_BOOKING", "APPOINTMENT_BOOKING", "PARCEL_DELIVERY"}


def _booking_candidates():
    return build_candidates(
        bases=[ROBERTO_API_BASE, ROBERTO_API_BASE_PUBLIC],
        suffixes=[
            "/bookings/create",
            "/public/bookings/create",
            "/v1/public/bookings/create",
        ],
    )


def make_create_booking(branch_id: str = None, conversation_id: str = None):

    @tool
    async def create_booking(
        business_id: str,
        category: str,
        customer_name: str,
        customer_number: str,
        price: str,
        email: str = None,
        note: str = None,
        payment_details: dict = None,
        extra_fields: dict = None
    ) -> str:
        """
        IMPORTANT: Call this tool the moment the customer CONFIRMS a booking,
        order, or appointment (e.g. 'confirm', 'book it', 'yes', 'proceed',
        'order it', 'schedule it'). A booking is only created after the customer
        confirms, so by definition the booking is confirmed/booked at this point.

        This single tool creates ALL booking types. YOU must decide which
        category the conversation is, using your own judgement - there is no
        fixed mapping from business type to category. Read the conversation and
        pick the one that fits.

        Parameters:
        - business_id: The business ID from the conversation (required)
        - category: EXACTLY one of these three (required). You decide intelligently:
            * "PARCEL_DELIVERY"     - shipping/sending a physical parcel from a
                                      pickup point to a delivery address.
            * "APPOINTMENT_BOOKING" - booking a meeting / consultation / session
                                      at a date & time, often on a platform
                                      (Zoom, Meet, phone, in-person).
            * "ORDER_BOOKING"       - ordering a product/item to be delivered
                                      (general e-commerce / sales style order).
          If genuinely unsure, prefer the category whose required details the
          customer actually provided.
        - customer_name: Full name of the customer (required)
        - customer_number: Phone number of the customer (required)
        - price: Total price as a string (required; use "0" if genuinely free)
        - email: Customer email (optional)
        - note: Any special instruction or order note (optional)
        - payment_details: Optional dict describing payment. Shape:
            {"paymentMethod": "...", "paymentStatus": "PENDING",
             "transactionId": ""}
          paymentStatus is one of PENDING, COMPLETED, FAILED, REFUNDED.
          If the customer didn't discuss payment, you may omit this or send
          {"paymentStatus": "PENDING"}.
        - extra_fields: A dict holding ALL category-specific details plus any
          other relevant info the customer gave. Use exact camelCase keys.
          The backend saves named standard columns and routes the rest into the
          booking's additional_details automatically. Include only what the
          customer actually provided - never invent values.

          For PARCEL_DELIVERY, relevant keys include:
            pickupAddress, deliveryAddress, pickupDate, pickupTime,
            deliveryDate, deliveryTime, productType, productWeight,
            productHeight, receiverName, receiverPhone, insuranceRequired,
            pickupLocationUrl, deliveryLocationUrl

            REQUIRED for PARCEL_DELIVERY specifically (in addition to the
            common required fields above): pickupLocationUrl and
            deliveryLocationUrl are STRICTLY MANDATORY (an actual Google
            Maps link/pin the customer shares for each location - never
            invent one yourself, never proceed without them), and BOTH a
            date AND time for pickup (pickupDate, pickupTime) AND for
            delivery (deliveryDate, deliveryTime) - four separate fields,
            24-hour HH:MM format for times, all mandatory. Pickup timing and
            delivery timing are not the same thing - always collect both,
            never assume one from the other. Ask for all of these naturally
            during the conversation, the same way you ask for name/phone -
            do NOT call create_booking for a PARCEL_DELIVERY until you have
            all of them.

          For APPOINTMENT_BOOKING, relevant keys include:
            appointmentDate, appointmentTime (ISO 8601 string), platform
            (Zoom/Meet/phone/in-person - ALWAYS ask the customer which platform),
            duration, companyName, industry, timezone, meetingLink

          For ORDER_BOOKING, relevant keys include:
            productType, deliveryDate, deliveryAddress, courierService,
            packageColor, fragile

        NOTE ON THE RETURN VALUE:
        This tool's return string tells YOU (the agent) whether the booking was
        actually saved on the backend or not:
        - If it starts with "✅" → the booking was genuinely saved. You can
          confidently tell the customer their booking is confirmed.
        - If it starts with "⚠️" → the booking was NOT saved (backend rejected it
          or was unreachable). Do NOT tell the customer the booking is confirmed.
          Instead, apologize briefly for a system hiccup, tell them you have all
          their details, and let them know the team will confirm manually shortly
          (or use handoff_human if this keeps failing).
        """
        cat = (category or "").strip().upper()
        if cat not in VALID_CATEGORIES:
            print(f"[BOOKING WARN] Unknown category '{category}', "
                  f"defaulting to ORDER_BOOKING")
            cat = "ORDER_BOOKING"

        # --- Required + common fields ---
        payload = {
            "businessId": business_id,
            "category": cat,
            "customerName": customer_name,
            "customerNumber": customer_number,
            "price": str(price),
            "orderStatus": "BOOKED",
        }

        # conversation_id force-injected by code, never by the LLM
        if conversation_id:
            payload["conversationId"] = conversation_id

        if branch_id:
            payload["branchId"] = branch_id
        if email:
            payload["email"] = email
        if note:
            payload["note"] = note

        # --- Payment details ---
        if payment_details:
            pd = dict(payment_details)
            pd.setdefault("paymentStatus", "PENDING")
            payload["paymentDetails"] = pd

        # --- Category-specific + dynamic fields ---
        if extra_fields:
            for k, v in extra_fields.items():
                if k not in payload and v is not None:
                    payload[k] = v

        print(f"[BOOKING] Category: {cat}")
        print(f"[BOOKING] Payload: {payload}")

        try:
            resp = await post_with_fallback(
                candidates=_booking_candidates(),
                json=payload,
                headers={
                    "x-api-token": ROBERTO_API_TOKEN,
                    "Content-Type": "application/json",
                },
                log_tag="BOOKING",
            )

            if resp is not None:
                print(f"[BOOKING] Final status: {resp.status_code}")
                print(f"[BOOKING] Response: {resp.text[:500]}")

                if resp.status_code in (200, 201):
                    return (
                        f"✅ Booking confirmed for {customer_name}!\n"
                        f"💰 Total: {price}\n"
                        f"Our team will contact you at {customer_number} shortly."
                    )

                # Backend reached but REJECTED the booking (400/401/422/500/...).
                # This is a REAL failure — never tell the LLM it succeeded.
                print(f"[BOOKING ERROR] Backend rejected booking: "
                      f"{resp.status_code} - {resp.text[:300]}")
                return (
                    f"⚠️ Booking was NOT saved. Backend rejected the request "
                    f"(status {resp.status_code}): {resp.text[:200]}. "
                    f"Do not tell the customer the booking is confirmed — "
                    f"apologize for a system hiccup and let them know the team "
                    f"will confirm manually shortly."
                )

            # resp is None → every candidate 404'd or was unreachable
            print(f"[BOOKING ERROR] No route responded for business_id={business_id}")
            return (
                f"Booking was NOT saved — could not reach the backend. "
                f"Do not tell the customer the booking is confirmed — apologize "
                f"for a system hiccup and let them know the team will confirm "
                f"manually shortly."
            )

        except Exception as e:
            print(f"[BOOKING ERROR] {e}")
            return (
                f"Booking was NOT saved due to an internal error ({e}). "
                f"Do not tell the customer the booking is confirmed — apologize "
                f"for a system hiccup and let them know the team will confirm "
                f"manually shortly."
            )

    return create_booking