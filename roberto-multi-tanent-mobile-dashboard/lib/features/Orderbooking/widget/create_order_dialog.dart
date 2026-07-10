import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/Auth/widget/custom_textfield.dart';
import 'package:roberto/features/Orderbooking/widget/order_mod.dart';
import 'package:intl/intl.dart';

class CreateOrderDialog extends StatefulWidget {
  final OrderMod? order;
  final String? businessType;

  const CreateOrderDialog({Key? key, this.order, this.businessType}) : super(key: key);

  @override
  State<CreateOrderDialog> createState() => _CreateOrderDialogState();
}

class _CreateOrderDialogState extends State<CreateOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // General fields
  late TextEditingController _customerNameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _noteCtrl;

  late TextEditingController _countryCtrl;

  // Booking Type selection
  String _bookingType = 'Appointment Booking';

  // Appointment Booking fields
  late TextEditingController _appointmentDateCtrl;
  late TextEditingController _appointmentTimeCtrl;
  late TextEditingController _platformCtrl;
  late TextEditingController _durationCtrl;
  late TextEditingController _customRequirementCtrl;

  // Parcel Delivery fields
  late TextEditingController _pickupAddressCtrl;
  late TextEditingController _deliveryDateCtrl;
  late TextEditingController _deliveryAddressCtrl;
  late TextEditingController _productTypeCtrl;
  late TextEditingController _productHeightCtrl;
  late TextEditingController _productWeightCtrl;
  late TextEditingController _receiverPhoneCtrl;
  late TextEditingController _productNameCtrl;

  // Order Booking fields (uses deliveryDate, deliveryAddress, productType from above)
  late TextEditingController _companyNameCtrl;

  // Payment Details
  late TextEditingController _paymentMethodCtrl;
  late TextEditingController _transactionIdCtrl;
  String _paymentStatus = 'PENDING';

  // Extra/Custom key-value fields
  List<MapEntry<TextEditingController, TextEditingController>> _customFields = [];

  @override
  void initState() {
    super.initState();
    final o = widget.order;

    // General fields init
    _customerNameCtrl = TextEditingController(text: o?.customerName ?? '');
    _phoneCtrl = TextEditingController(text: o?.phone ?? '');
    _emailCtrl = TextEditingController(text: o?.email ?? '');
    _priceCtrl = TextEditingController(text: o?.price ?? '');
    _noteCtrl = TextEditingController(text: o?.note ?? '');
    _countryCtrl = TextEditingController(text: o?.country ?? '');

    // Determine booking type
    if (o != null) {
      if (o.rawAdditionalDetails.containsKey('bookingType')) {
        _bookingType = o.rawAdditionalDetails['bookingType'] ?? 'Appointment Booking';
      } else if (o.appointmentDate != null && o.appointmentDate!.isNotEmpty) {
        _bookingType = 'Appointment Booking';
      } else if (o.pickupAddress != null && o.pickupAddress!.isNotEmpty) {
        _bookingType = 'Parcel Delivery';
      } else {
        _bookingType = 'Order Booking';
      }
    } else if (widget.businessType != null) {
      _bookingType = _mapBusinessTypeToBookingType(widget.businessType);
    }

    // Appointment fields init
    _appointmentDateCtrl = TextEditingController(text: o?.appointmentDate ?? '');
    _appointmentTimeCtrl = TextEditingController(text: o?.appointmentTime ?? '');
    _platformCtrl = TextEditingController(text: o?.platform ?? 'Zoom');
    _durationCtrl = TextEditingController(text: o?.duration ?? '60 Minutes');
    _customRequirementCtrl = TextEditingController(text: o?.customRequirement ?? '');

    // Parcel fields init
    _pickupAddressCtrl = TextEditingController(text: o?.pickupAddress ?? '');
    _deliveryDateCtrl = TextEditingController(text: o?.deliveryDate ?? '');
    _deliveryAddressCtrl = TextEditingController(text: o?.deliveryAddress ?? '');
    _productTypeCtrl = TextEditingController(text: o?.productType ?? '');
    _productHeightCtrl = TextEditingController(text: o?.productHeight ?? '');
    _productWeightCtrl = TextEditingController(text: o?.productWeight ?? '');
    _receiverPhoneCtrl = TextEditingController(text: o?.receiverPhone ?? '');
    _productNameCtrl = TextEditingController(text: o?.productName ?? '');

    // Order fields init
    _companyNameCtrl = TextEditingController(text: o?.companyName ?? '');

    // Payment init
    _paymentMethodCtrl = TextEditingController(text: o?.paymentMethod ?? 'Cash on Delivery');
    _transactionIdCtrl = TextEditingController(text: o?.transactionId ?? '');
    _paymentStatus = o?.paymentStatus ?? 'PENDING';

    // Parse dynamic custom fields
    final predefinedKeys = {
      'bookingType',
      'appointmentDate',
      'appointmentTime',
      'platform',
      'duration',
      'customRequirement',
      'pickupAddress',
      'deliveryDate',
      'deliveryAddress',
      'productType',
      'productHeight',
      'productWeight',
      'receiverPhone',
      'companyName',
      'customerName',
      'customerNumber',
      'email',
      'price',
      'note',
      'status',
      'branchId',
      'country',
      'productName',
      'id',
      'businessId',
      'parcelDeliveryId',
      'createdAt',
      'updatedAt',
    };

    if (o != null) {
      o.rawAdditionalDetails.forEach((key, value) {
        if (!predefinedKeys.contains(key) && key.isNotEmpty) {
          _customFields.add(MapEntry(
            TextEditingController(text: key),
            TextEditingController(text: value?.toString() ?? ''),
          ));
        }
      });
    }
  }

  @override
  void dispose() {
    _customerNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _priceCtrl.dispose();
    _noteCtrl.dispose();
    _countryCtrl.dispose();

    _appointmentDateCtrl.dispose();
    _appointmentTimeCtrl.dispose();
    _platformCtrl.dispose();
    _durationCtrl.dispose();
    _customRequirementCtrl.dispose();

    _pickupAddressCtrl.dispose();
    _deliveryDateCtrl.dispose();
    _deliveryAddressCtrl.dispose();
    _productTypeCtrl.dispose();
    _productHeightCtrl.dispose();
    _productWeightCtrl.dispose();
    _receiverPhoneCtrl.dispose();
    _productNameCtrl.dispose();

    _companyNameCtrl.dispose();

    _paymentMethodCtrl.dispose();
    _transactionIdCtrl.dispose();

    for (var entry in _customFields) {
      entry.key.dispose();
      entry.value.dispose();
    }
    super.dispose();
  }

  String _mapBusinessTypeToBookingType(String? businessType) {
    if (businessType == null) return 'Appointment Booking';
    final normalized = businessType.toUpperCase().replaceAll(' ', '_');
    if (normalized.contains('SERVICE') || normalized.contains('APPOINTMENT') || normalized.contains('ZOOM') || normalized.contains('MEETING')) {
      return 'Appointment Booking';
    } else if (normalized.contains('PARCEL') || normalized.contains('DELIVERY') || normalized.contains('CARGO') || normalized.contains('SHIPPING')) {
      return 'Parcel Delivery';
    } else if (normalized.contains('RETAIL') || normalized.contains('MANUFACTURING') || normalized.contains('ORDER') || normalized.contains('PRODUCT') || normalized.contains('SHOP')) {
      return 'Order Booking';
    }
    return 'Appointment Booking';
  }

  void _submit() {
    if (_isSubmitting) return;
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      final payload = <String, dynamic>{
        'customerName': _customerNameCtrl.text.trim(),
        'customerNumber': _phoneCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'price': _priceCtrl.text.trim(),
        'note': _noteCtrl.text.trim(),
        'status': widget.order?.status.name.toUpperCase() ?? 'PENDING',
        'country': _countryCtrl.text.trim(),
        'paymentMethod': _paymentMethodCtrl.text.trim(),
        'paymentStatus': _paymentStatus,
      };

      if (_transactionIdCtrl.text.trim().isNotEmpty) {
        payload['transactionId'] = _transactionIdCtrl.text.trim();
      }

      if (_bookingType == 'Appointment Booking') {
        payload['appointmentDate'] = _appointmentDateCtrl.text.trim();
        payload['appointmentTime'] = _appointmentTimeCtrl.text.trim();
        payload['platform'] = _platformCtrl.text.trim();
        payload['duration'] = _durationCtrl.text.trim();
        if (_customRequirementCtrl.text.trim().isNotEmpty) {
          payload['customRequirement'] = _customRequirementCtrl.text.trim();
        }
      } else if (_bookingType == 'Parcel Delivery') {
        payload['pickupAddress'] = _pickupAddressCtrl.text.trim();
        payload['deliveryDate'] = _deliveryDateCtrl.text.trim();
        payload['deliveryAddress'] = _deliveryAddressCtrl.text.trim();
        payload['productType'] = _productTypeCtrl.text.trim();
        payload['productHeight'] = _productHeightCtrl.text.trim();
        payload['productName'] = _productNameCtrl.text.trim();
        if (_productWeightCtrl.text.trim().isNotEmpty) {
          payload['productWeight'] = int.tryParse(_productWeightCtrl.text.trim()) ?? 0;
        }
        payload['receiverPhone'] = _receiverPhoneCtrl.text.trim();
      } else if (_bookingType == 'Order Booking') {
        payload['deliveryDate'] = _deliveryDateCtrl.text.trim();
        payload['deliveryAddress'] = _deliveryAddressCtrl.text.trim();
        payload['productType'] = _productTypeCtrl.text.trim();
        payload['companyName'] = _companyNameCtrl.text.trim();
        payload['productName'] = _productNameCtrl.text.trim();
      }

      // Add dynamic custom fields
      for (var entry in _customFields) {
        final k = entry.key.text.trim();
        final v = entry.value.text.trim();
        if (k.isNotEmpty) {
          payload[k] = v;
        }
      }

      // Remove empty strings so we don't send empty fields
      payload.removeWhere((key, value) => value is String && value.isEmpty);

      Navigator.pop(context, payload);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: theme.cardColor,
      child: Container(
        width: isMobile ? width * 0.95 : 600,
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.order == null ? 'Create Booking' : 'Update Booking',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Fill in the booking information below.',
                          style: TextStyle(fontSize: 14, color: theme.hintColor),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: theme.hintColor),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: theme.dividerColor.withOpacity(0.1)),
            
            // Form body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section: Booking Type (Dynamic Form Controller)
                      if (widget.order == null && widget.businessType == null) ...[
                        _buildSectionTitle('Booking Details', theme),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Booking Type', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _bookingType,
                              isExpanded: true,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
                              ),
                              items: ['Appointment Booking', 'Parcel Delivery', 'Order Booking']
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (v) => setState(() => _bookingType = v!),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Section: Customer Info
                      _buildSectionTitle('Customer Info', theme),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Customer Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                          const SizedBox(height: 8),
                          CustomTextfield(validator: (v) => null, controller: _customerNameCtrl, hintText: 'Enter Customer Name'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Phone', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                              const SizedBox(height: 8),
                              CustomTextfield(validator: (v) => null, controller: _phoneCtrl, hintText: 'Enter Phone Number'),
                            ],
                          )),
                          const SizedBox(width: 16),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Email', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                              const SizedBox(height: 8),
                              CustomTextfield(validator: (v) => null, controller: _emailCtrl, hintText: 'example@gmail.com'),
                            ],
                          )),
                        ],
                      ),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Country', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                              const SizedBox(height: 8),
                              CustomTextfield(validator: (v) => null, controller: _countryCtrl, hintText: 'Enter Country'),
                            ],
                          ),
                          const SizedBox(height: 24),

                      // Type Specific Fields
                      if (_bookingType == 'Appointment Booking') ...[
                        _buildSectionTitle('Appointment Information', theme),
                        Row(
                          children: [
                            Expanded(child: _buildDatePickerField(
                              context: context,
                              controller: _appointmentDateCtrl,
                              label: 'Appointment Date',
                              hintText: '2026-06-25',
                              theme: theme,
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Appointment Time', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                                const SizedBox(height: 8),
                                CustomTextfield(validator: (v) => null, controller: _appointmentTimeCtrl, hintText: '14:30'),
                              ],
                            )),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Platform', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                                const SizedBox(height: 8),
                                CustomTextfield(validator: (v) => null, controller: _platformCtrl, hintText: 'Google Meet'),
                              ],
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Duration', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                                const SizedBox(height: 8),
                                CustomTextfield(validator: (v) => null, controller: _durationCtrl, hintText: '45 minutes'),
                              ],
                            )),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Custom Requirement', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                            const SizedBox(height: 8),
                            CustomTextfield(validator: (v) => null, controller: _customRequirementCtrl, hintText: 'Requires recording of the meeting'),
                          ],
                        ),
                      ] else if (_bookingType == 'Parcel Delivery') ...[
                        _buildSectionTitle('Parcel Delivery Details', theme),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pickup Address', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                            const SizedBox(height: 8),
                            CustomTextfield(validator: (v) => null, controller: _pickupAddressCtrl, hintText: 'Enter Location'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildDatePickerField(
                              context: context,
                              controller: _deliveryDateCtrl,
                              label: 'Delivery Date',
                              hintText: '2026-06-24',
                              theme: theme,
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Receiver Phone', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                                const SizedBox(height: 8),
                                CustomTextfield(validator: (v) => null, controller: _receiverPhoneCtrl, hintText: 'Enter Receiver Phone Number'),
                              ],
                            )),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Delivery Address', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                            const SizedBox(height: 8),
                            CustomTextfield(validator: (v) => null, controller: _deliveryAddressCtrl, hintText: 'Enter Delivery Address'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Product Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                                const SizedBox(height: 8),
                                CustomTextfield(validator: (v) => null, controller: _productNameCtrl, hintText: 'e.g. Medicine'),
                              ],
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Product Type', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                                const SizedBox(height: 8),
                                CustomTextfield(validator: (v) => null, controller: _productTypeCtrl, hintText: 'Electronics'),
                              ],
                            )),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Product Size/Height', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                                const SizedBox(height: 8),
                                CustomTextfield(validator: (v) => null, controller: _productHeightCtrl, hintText: '15 cm'),
                              ],
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Product Weight (kg)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                                const SizedBox(height: 8),
                                CustomTextfield(validator: (v) => null, controller: _productWeightCtrl, hintText: '2'),
                              ],
                            )),
                          ],
                        ),
                      ] else if (_bookingType == 'Order Booking') ...[
                        _buildSectionTitle('Order Details', theme),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Company Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                            const SizedBox(height: 8),
                            CustomTextfield(validator: (v) => null, controller: _companyNameCtrl, hintText: 'Enter Company Name'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildDatePickerField(
                              context: context,
                              controller: _deliveryDateCtrl,
                              label: 'Delivery Date',
                              hintText: '2026-06-28',
                              theme: theme,
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Product Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                                const SizedBox(height: 8),
                                CustomTextfield(validator: (v) => null, controller: _productNameCtrl, hintText: 'Office Supplies'),
                              ],
                            )),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Delivery Address', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                                const SizedBox(height: 8),
                                CustomTextfield(validator: (v) => null, controller: _deliveryAddressCtrl, hintText: 'Scranton Branch'),
                              ],
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Product Type', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                                const SizedBox(height: 8),
                                CustomTextfield(validator: (v) => null, controller: _productTypeCtrl, hintText: 'e.g. Bulk items'),
                              ],
                            )),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Section: Payment Details
                      _buildSectionTitle('Payment Details', theme),
                      Row(
                        children: [
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Price', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                              const SizedBox(height: 8),
                              CustomTextfield(validator: (v) => null, controller: _priceCtrl, hintText: '250'),
                            ],
                          )),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Payment Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _paymentStatus,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
                                  ),
                                  items: ['PENDING', 'COMPLETED', 'FAILED']
                                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                      .toList(),
                                  onChanged: (v) => setState(() => _paymentStatus = v!),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Payment Method', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                              const SizedBox(height: 8),
                              CustomTextfield(validator: (v) => null, controller: _paymentMethodCtrl, hintText: 'Bkash / Stripe / Cash'),
                            ],
                          )),
                          const SizedBox(width: 16),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Transaction ID', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                              const SizedBox(height: 8),
                              CustomTextfield(validator: (v) => null, controller: _transactionIdCtrl, hintText: 'TRX123456'),
                            ],
                          )),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Section: General note
                      _buildSectionTitle('Additional Notes', theme),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Note', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                          const SizedBox(height: 8),
                          CustomTextfield(
                            controller: _noteCtrl, 
                            hintText: 'Any extra notes...',
                            validator: (v) => null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Section: Custom Fields
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionTitle('Custom Fields', theme),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _customFields.add(MapEntry(TextEditingController(), TextEditingController()));
                              });
                            },
                            icon: const Icon(Icons.add_circle_outline, color: AppColor.primary),
                            tooltip: 'Add Custom Field',
                          ),
                        ],
                      ),
                      if (_customFields.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'No custom fields added yet. Press the + button to add.',
                            style: TextStyle(fontSize: 13, color: theme.hintColor, fontStyle: FontStyle.italic),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _customFields.length,
                          itemBuilder: (context, index) {
                            final entry = _customFields[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: CustomTextfield(
                                      validator: (v) => null, controller: entry.key,
                                      hintText: 'Field Name',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: CustomTextfield(
                                      validator: (v) => null, controller: entry.value,
                                      hintText: 'Value',
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _customFields.removeAt(index);
                                      });
                                    },
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      if (widget.order != null) ...[
                        const SizedBox(height: 24),
                        _buildSectionTitle('Record Details', theme),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Created At', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.order!.createdAt != null ? DateFormat('MMM dd, yyyy - hh:mm a').format(widget.order!.createdAt!) : (widget.order!.rawAdditionalDetails['createdAt']?.toString() ?? 'N/A'),
                                    style: TextStyle(fontSize: 14, color: theme.hintColor),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Updated At', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.order!.rawAdditionalDetails['updatedAt'] != null 
                                      ? (DateTime.tryParse(widget.order!.rawAdditionalDetails['updatedAt'].toString()) != null 
                                          ? DateFormat('MMM dd, yyyy - hh:mm a').format(DateTime.tryParse(widget.order!.rawAdditionalDetails['updatedAt'].toString())!)
                                          : widget.order!.rawAdditionalDetails['updatedAt'].toString())
                                      : 'N/A',
                                    style: TextStyle(fontSize: 14, color: theme.hintColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            Divider(height: 1, color: theme.dividerColor.withOpacity(0.1)),
            // Footer
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel', style: TextStyle(color: theme.hintColor)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: Text(widget.order == null ? 'Create Booking' : 'Save Changes', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
      ),
    );
  }

  Widget _buildDatePickerField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hintText,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            DateTime initialDate = DateTime.now();
            if (controller.text.isNotEmpty) {
              final parsed = DateTime.tryParse(controller.text);
              if (parsed != null) {
                initialDate = parsed;
              }
            }
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              builder: (context, child) {
                return Theme(
                  data: theme.copyWith(
                    colorScheme: theme.colorScheme.copyWith(
                      primary: AppColor.primary,
                      onPrimary: Colors.white,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (selectedDate != null) {
              final formatted = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
              controller.text = formatted;
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              controller: controller,
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                  fontSize: 14,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                filled: true,
                fillColor: theme.cardTheme.color,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.dividerTheme.color ?? theme.dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.dividerTheme.color ?? theme.dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColor.primary),
                ),
                suffixIcon: Icon(Icons.calendar_today, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.5)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
