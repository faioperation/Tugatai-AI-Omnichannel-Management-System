import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/Orderbooking/widget/order_mod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class CustomViewdetails extends StatelessWidget {
  final OrderMod order;
  final String? displayId;
  final VoidCallback? onUpdatePressed;

  const CustomViewdetails({
    Key? key,
    required this.order,
    this.displayId,
    this.onUpdatePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;

    final customFieldRows = <Widget>[];
    final predefinedKeys = {
      'bookingType',
      'appointmentDate',
      'appointmentTime',
      'platform',
      'duration',
      'customRequirement',
      'pickupAddress',
      'pickupDate',
      'pickupTime',
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
      'id',
      'businessId',
      'parcelDeliveryId',
      'tenantId',
      'userId',
      'appointmentId',
      'appointment_id',
      'deletedAt',
    };

    String formatKeyName(String key) {
      final regex = RegExp(r'(?<=[a-z])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])');
      String spaced = key.replaceAllMapped(regex, (match) => ' ');
      spaced = spaced.replaceAll('_', ' ').replaceAll('-', ' ').trim();
      return spaced.toUpperCase();
    }

    order.rawAdditionalDetails.forEach((key, value) {
      if (!predefinedKeys.contains(key) && key.isNotEmpty) {
        String displayValue = value?.toString() ?? '';
        final lowerKey = key.toLowerCase();
        if (lowerKey.contains('type') ||
            lowerKey.contains('mode') ||
            lowerKey.contains('status')) {
          displayValue = displayValue.toUpperCase();
        }

        final isLongValue = displayValue.length > 30;

        customFieldRows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: isLongValue
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatKeyName(key),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayValue,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatKeyName(key),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          displayValue,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      }
    });

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: theme.cardColor,
      child: Container(
        width: isMobile ? width * 0.95 : 600,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context, theme),
              const SizedBox(height: 24),

              // Order ID
              _buildOrderIdSection(context, theme),
              const SizedBox(height: 20),

              // Customer Information
              _buildSectionTitle('Customer Information', theme),
              const SizedBox(height: 8),
              _buildInfoContainer(
                [
                  _buildIconRow(
                    Icons.person_outline,
                    order.customerName,
                    theme,
                  ),
                  const SizedBox(height: 12),
                  _buildIconRow(Icons.phone_outlined, order.phone, theme),
                  if (order.email != null && order.email!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildIconRow(Icons.email_outlined, order.email!, theme),
                  ],
                ],
                theme,
                isDark,
              ),
              const SizedBox(height: 20),

              // Booking Details Section
              _buildSectionTitle(
                order.bookingType == 'Appointment Booking'
                    ? 'Appointment Details'
                    : 'Booking Details (${order.bookingType ?? "General"})',
                theme,
              ),
              const SizedBox(height: 8),
              _buildInfoContainer(
                [
                  if (order.bookingType == 'Appointment Booking') ...[
                    _buildDetailRow(
                      'Date',
                      (order.appointmentDate != null && order.appointmentDate!.isNotEmpty) ? order.appointmentDate! : (order.calenderDate ?? 'N/A'),
                      theme,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Time',
                      (order.appointmentTime != null && order.appointmentTime!.isNotEmpty) ? order.appointmentTime! : (order.calenderTime ?? 'N/A'),
                      theme,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow('Platform', order.platform ?? 'N/A', theme),
                    const SizedBox(height: 8),
                    _buildDetailRow('Duration', order.duration ?? 'N/A', theme),
                    if (order.customRequirement != null &&
                        order.customRequirement!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        'Requirement',
                        order.customRequirement!,
                        theme,
                      ),
                    ],
                  ] else if (order.bookingType == 'Parcel Delivery') ...[
                    _buildDetailRow(
                      'Pickup',
                      order.pickupAddress ?? 'N/A',
                      theme,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Pickup Date',
                      order.pickupDate ?? 'N/A',
                      theme,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Pickup Time',
                      order.pickupTime ?? 'N/A',
                      theme,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Delivery Date',
                      order.deliveryDate ?? 'N/A',
                      theme,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Delivery To',
                      order.deliveryAddress ?? 'N/A',
                      theme,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Receiver Phone',
                      order.receiverPhone ?? 'N/A',
                      theme,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Product Type',
                      order.productType ?? 'N/A',
                      theme,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Height / Weight',
                      '${order.productHeight ?? "N/A"} / ${order.productWeight ?? "N/A"} kg',
                      theme,
                    ),
                  ] else if (order.bookingType == 'Order Booking') ...[
                    _buildDetailRow(
                      'Delivery Date',
                      order.deliveryDate ?? 'N/A',
                      theme,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Delivery To',
                      order.deliveryAddress ?? order.address ?? 'N/A',
                      theme,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Product Type',
                      order.productType ?? 'N/A',
                      theme,
                    ),
                  ],
                ],
                theme,
                isDark,
              ),
              const SizedBox(height: 20),

              // Custom/Extra Fields Section
              if (customFieldRows.isNotEmpty) ...[
                _buildSectionTitle('Additional Fields', theme),
                const SizedBox(height: 8),
                _buildInfoContainer(customFieldRows, theme, isDark),
                const SizedBox(height: 20),
              ],

              // Notes Section (if note is present)
              if (order.note != null && order.note!.isNotEmpty) ...[
                _buildSectionTitle('Notes', theme),
                const SizedBox(height: 8),
                _buildInfoContainer(
                  [
                    Text(
                      order.note!,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ],
                  theme,
                  isDark,
                ),
                const SizedBox(height: 20),
              ],

              // Payment Information
              _buildSectionTitle('Payment Details', theme),
              const SizedBox(height: 8),
              _buildPaymentContainer(theme, isDark),
              const SizedBox(height: 24),

              // Buttons
              _buildActionButtons(context, width, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    final isAppointment = order.bookingType == 'Appointment Booking';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAppointment ? 'Appointment Details' : 'Order Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isAppointment ? 'Complete information about this appointment' : 'Complete information about this order',
                style: TextStyle(fontSize: 14, color: theme.hintColor),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close, color: theme.hintColor, size: 20),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildOrderIdSection(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatusBadge(context, order.status),
      ],
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildInfoContainer(
    List<Widget> children,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceVariant.withOpacity(0.15)
            : const Color(0xffF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildPaymentContainer(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceVariant.withOpacity(0.15)
            : const Color(0xffF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 18,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Total Amount',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Text(
                '\$${order.price}',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (order.paymentMethod != null ||
              order.paymentStatus != null ||
              order.transactionId != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1),
            ),
            _buildDetailRow('Method', order.paymentMethod ?? 'N/A', theme),
            const SizedBox(height: 8),
            _buildDetailRow('Status', order.paymentStatus ?? 'N/A', theme),
            const SizedBox(height: 8),
            _buildDetailRow('Txn ID', order.transactionId ?? 'N/A', theme),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    double width,
    ThemeData theme,
  ) {
    final bool isStack = width < 400;

    final updateBtn = ElevatedButton(
      onPressed: () {
        Navigator.pop(context); // Close view details
        if (onUpdatePressed != null) {
          onUpdatePressed!();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.primary,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
      ),
      child: const Center(
        child: Text(
          'Update Status',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );

    final printBtn = OutlinedButton(
      onPressed: () => _printInvoice(context),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.2)),
      ),
      child: Center(
        child: Text(
          'Print Invoice',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

    if (isStack) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [updateBtn, const SizedBox(height: 12), printBtn],
      );
    }

    return Row(
      children: [
        Expanded(child: updateBtn),
        const SizedBox(width: 12),
        Expanded(child: printBtn),
      ],
    );
  }

  Widget _buildIconRow(IconData icon, String text, ThemeData theme) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context, OrderStatus status) {
    late Color bg, fg;
    late String label;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (status) {
      case OrderStatus.pending:
        bg = isDark ? Colors.amber.withOpacity(0.1) : const Color(0xffFEF3C7);
        fg = isDark ? Colors.amber.shade400 : const Color(0xffD97706);
        label = 'Pending';
        break;
      case OrderStatus.confirmed:
        bg = isDark ? Colors.blue.withOpacity(0.1) : const Color(0xffDBEAFE);
        fg = isDark ? Colors.blue.shade400 : const Color(0xff2563EB);
        label = 'Confirmed';
        break;
      case OrderStatus.completed:
      case OrderStatus.delivered:
        bg = isDark ? Colors.green.withOpacity(0.1) : const Color(0xffD1FAE5);
        fg = isDark ? Colors.green.shade400 : const Color(0xff059669);
        label = status == OrderStatus.completed ? 'Completed' : 'Delivered';
        break;
      case OrderStatus.cancelled:
        bg = isDark ? Colors.red.withOpacity(0.1) : const Color(0xffFEE2E2);
        fg = isDark ? Colors.red.shade400 : const Color(0xffDC2626);
        label = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Future<void> _printInvoice(BuildContext context) async {
    final doc = pw.Document();

    final predefinedKeys = {
      'bookingType',
      'appointmentDate',
      'appointmentTime',
      'platform',
      'duration',
      'customRequirement',
      'pickupAddress',
      'pickupDate',
      'pickupTime',
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
      'id',
      'businessId',
      'parcelDeliveryId',
      'tenantId',
      'userId',
    };

    String formatKeyName(String key) {
      final regex = RegExp(r'(?<=[a-z])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])');
      String spaced = key.replaceAllMapped(regex, (match) => ' ');
      spaced = spaced.replaceAll('_', ' ').replaceAll('-', ' ').trim();
      return spaced.toUpperCase();
    }

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context pdfContext) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    // pw.Column(
                    //   crossAxisAlignment: pw.CrossAxisAlignment.start,
                    //   children: [
                    //     pw.Text(
                    //       'MATRIX AI',
                    //       style: pw.TextStyle(
                    //         fontSize: 24,
                    //         fontWeight: pw.FontWeight.bold,
                    //         color: PdfColors.red900,
                    //       ),
                    //     ),
                    //     pw.SizedBox(height: 4),
                    //     pw.Text(
                    //       'Omnichannel Management System',
                    //       style: const pw.TextStyle(
                    //         fontSize: 10,
                    //         color: PdfColors.grey700,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'INVOICE',
                          style: pw.TextStyle(
                            fontSize: 28,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blueGrey800,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Order ID: ${displayId ?? order.orderId}',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Divider(thickness: 1, color: PdfColors.grey300),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'BILLED TO:',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey600,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          order.customerName,
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Phone: ${order.phone}',
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                        if (order.email != null && order.email!.isNotEmpty) ...[
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Email: ${order.email}',
                            style: const pw.TextStyle(fontSize: 11),
                          ),
                        ],
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'DATE:',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey600,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          DateFormat('dd MMMM yyyy').format(DateTime.now()),
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'STATUS:',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey600,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          order.status.name.toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color:
                                order.status == OrderStatus.completed ||
                                    order.status == OrderStatus.delivered
                                ? PdfColors.green700
                                : order.status == OrderStatus.cancelled
                                ? PdfColors.red700
                                : PdfColors.amber700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Text(
                  'BOOKING DETAILS',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blueGrey800,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(8),
                    ),
                  ),
                  child: pw.Column(
                    children: [
                      _buildPdfRow(
                        'Booking Type',
                        order.bookingType ?? 'General',
                      ),
                      if (order.bookingType == 'Appointment Booking') ...[
                        _buildPdfRow(
                          'Date / Time',
                          '${order.appointmentDate ?? "N/A"} @ ${order.appointmentTime ?? "N/A"}',
                        ),
                        _buildPdfRow('Platform', order.platform ?? 'N/A'),
                        _buildPdfRow('Duration', order.duration ?? 'N/A'),
                      ] else if (order.bookingType == 'Parcel Delivery') ...[
                        _buildPdfRow(
                          'Pickup Address',
                          order.pickupAddress ?? 'N/A',
                        ),
                        _buildPdfRow(
                          'Pickup Date',
                          order.pickupDate ?? 'N/A',
                        ),
                        _buildPdfRow(
                          'Pickup Time',
                          order.pickupTime ?? 'N/A',
                        ),
                        _buildPdfRow(
                          'Delivery Address',
                          order.deliveryAddress ?? 'N/A',
                        ),
                        _buildPdfRow(
                          'Product Type',
                          order.productType ?? 'N/A',
                        ),
                        _buildPdfRow(
                          'Height / Weight',
                          '${order.productHeight ?? "N/A"} / ${order.productWeight ?? "N/A"} kg',
                        ),
                        _buildPdfRow(
                          'Receiver Phone',
                          order.receiverPhone ?? 'N/A',
                        ),
                      ] else if (order.bookingType == 'Order Booking') ...[
                        _buildPdfRow(
                          'Company Name',
                          order.companyName ?? 'N/A',
                        ),
                        _buildPdfRow(
                          'Pickup Date',
                          order.pickupDate ?? 'N/A',
                        ),
                        _buildPdfRow(
                          'Pickup Time',
                          order.pickupTime ?? 'N/A',
                        ),
                        _buildPdfRow(
                          'Delivery Date',
                          order.deliveryDate ?? 'N/A',
                        ),
                        _buildPdfRow(
                          'Delivery Address',
                          order.deliveryAddress ?? 'N/A',
                        ),
                        _buildPdfRow(
                          'Product Type',
                          order.productType ?? 'N/A',
                        ),
                      ],
                    ],
                  ),
                ),
                pw.SizedBox(height: 25),
                if (order.rawAdditionalDetails.entries.any(
                  (e) =>
                      !predefinedKeys.contains(e.key) &&
                      e.key.isNotEmpty &&
                      e.value != null &&
                      e.value.toString().isNotEmpty,
                )) ...[
                  pw.Text(
                    'ADDITIONAL DETAILS',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blueGrey800,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(8),
                      ),
                    ),
                    child: pw.Column(
                      children: order.rawAdditionalDetails.entries
                          .where(
                            (e) =>
                                !predefinedKeys.contains(e.key) &&
                                e.key.isNotEmpty &&
                                e.value != null &&
                                e.value.toString().isNotEmpty,
                          )
                          .map((e) {
                            String valueStr = e.value.toString();
                            final lowerKey = e.key.toLowerCase();
                            if (lowerKey.contains('type') ||
                                lowerKey.contains('mode') ||
                                lowerKey.contains('status')) {
                              valueStr = valueStr.toUpperCase();
                            }
                            return _buildPdfRow(formatKeyName(e.key), valueStr);
                          })
                          .toList(),
                    ),
                  ),
                  pw.SizedBox(height: 25),
                ],
                pw.Text(
                  'PAYMENT DETAILS',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blueGrey800,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColors.grey300,
                    width: 0.5,
                  ),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey200,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Description',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Method',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Txn ID / Details',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Amount',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Booking Service Fee (${order.bookingType ?? "General"})',
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(order.paymentMethod ?? 'N/A'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(order.transactionId ?? 'N/A'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            '\$${order.price}',
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Container(
                      width: 200,
                      child: pw.Column(
                        children: [
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'Subtotal:',
                                style: const pw.TextStyle(fontSize: 12),
                              ),
                              pw.Text(
                                '\$${order.price}',
                                style: const pw.TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 4),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'Tax / Vat (0%):',
                                style: const pw.TextStyle(fontSize: 12),
                              ),
                              pw.Text(
                                '\$0.00',
                                style: const pw.TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          pw.Divider(thickness: 0.5, color: PdfColors.grey400),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'Total Amount:',
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.red900,
                                ),
                              ),
                              pw.Text(
                                '\$${order.price}',
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.red900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.Spacer(),
                if (order.note != null && order.note!.isNotEmpty) ...[
                  pw.Text(
                    'Notes:',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    order.note!,
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                ],
                pw.Center(
                  child: pw.Text(
                    'Thank you for your business!',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Center(
                  child: pw.Text(
                    'Generated via Matrix AI Omnichannel Dashboard',
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey500,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
        name: 'Invoice_${displayId ?? order.orderId}',
      );
    } catch (e) {
      debugPrint("Printing error: $e");
    }
  }

  pw.Widget _buildPdfRow(String label, String value) {
    final isLong = value.length > 40;
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: isLong
          ? pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  label,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  value,
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.black,
                  ),
                ),
              ],
            )
          : pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  label,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: pw.Text(
                    value,
                    textAlign: pw.TextAlign.right,
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.black,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
