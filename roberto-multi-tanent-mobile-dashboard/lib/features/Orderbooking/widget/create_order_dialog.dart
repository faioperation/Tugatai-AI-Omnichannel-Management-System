import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/Orderbooking/widget/order_mod.dart';
import 'package:roberto/features/Auth/widget/custom_textfield.dart';

class CreateOrderDialog extends StatefulWidget {
  final OrderMod? order;
  const CreateOrderDialog({super.key, this.order});

  @override
  State<CreateOrderDialog> createState() => _CreateOrderDialogState();
}

class _CreateOrderDialogState extends State<CreateOrderDialog> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _fromController;
  late TextEditingController _toController;
  late TextEditingController _productController;
  late TextEditingController _sizeController;
  late TextEditingController _priceController;
  late TextEditingController _notesController;

  int _quantity = 1;
  String? _selectedPaymentMethod = 'Cash on delivery';
  String? _selectedStatus = 'paid';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.order?.customerName);
    _phoneController = TextEditingController(text: widget.order?.phone);
    _emailController = TextEditingController(text: widget.order?.email);
    _fromController = TextEditingController(text: widget.order?.fromAddress);
    _toController = TextEditingController(text: widget.order?.toAddress);
    _productController = TextEditingController(text: widget.order?.productName);
    _sizeController = TextEditingController(text: widget.order?.productSize);
    _priceController = TextEditingController(text: widget.order?.price?.toString() ?? widget.order?.shippingCharge.toString());
    _notesController = TextEditingController(text: widget.order?.notes);
    
    if (widget.order != null) {
      _quantity = widget.order!.quantity;
      _selectedPaymentMethod = widget.order!.paymentMethod ?? 'Cash on delivery';
      // Map OrderStatus enum back to dialog strings if needed, 
      // but for now let's keep it simple or align them
      _selectedStatus = widget.order!.status == OrderStatus.pending ? 'unpaid' : 'paid';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _fromController.dispose();
    _toController.dispose();
    _productController.dispose();
    _sizeController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: theme.cardColor,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.order != null ? "Edit Order" : "Create New Order",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.order != null ? "Update existing order details" : "Create a new order for a customer",
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Form Content
              Flexible(
                child: SingleChildScrollView(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 450;
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Customer Name"),
                          CustomTextfield(hintText: "Enter customer name", controller: _nameController),
                          const SizedBox(height: 16),
                          
                          if (isMobile) ... [
                            _buildLabel("Phone Number"),
                            CustomTextfield(hintText: "+1 (555) 000-0000", controller: _phoneController),
                            const SizedBox(height: 16),
                            _buildLabel("Email (Optional)"),
                            CustomTextfield(hintText: "customer@email.com", controller: _emailController),
                          ] else 
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel("Phone Number"),
                                      CustomTextfield(hintText: "+1 (555) 000-0000", controller: _phoneController),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel("Email (Optional)"),
                                      CustomTextfield(hintText: "customer@email.com", controller: _emailController),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 16),
                          
                          _buildLabel("Delivery Address ( From )"),
                          CustomTextfield(hintText: "Enter location", controller: _fromController),
                          const SizedBox(height: 16),
                          
                          _buildLabel("To"),
                          CustomTextfield(hintText: "Enter location", controller: _toController),
                          const SizedBox(height: 16),
                          
                          if (isMobile) ... [
                            _buildLabel("Select Product"),
                            CustomTextfield(hintText: "Type product Name", controller: _productController),
                            const SizedBox(height: 16),
                            _buildLabel("Select Size"),
                            CustomTextfield(hintText: "Type size/weight", controller: _sizeController),
                          ] else 
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel("Select Product"),
                                      CustomTextfield(hintText: "Type product Name", controller: _productController),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel("Select Size"),
                                      CustomTextfield(hintText: "Type size/weight", controller: _sizeController),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 16),

                          if (isMobile) ... [
                            _buildLabel("Quantity"),
                            _buildQuantityDropdown(),
                            const SizedBox(height: 16),
                            _buildLabel("Price"),
                            CustomTextfield(hintText: "Enter price", controller: _priceController),
                          ] else 
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel("Quantity"),
                                      _buildQuantityDropdown(),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel("Price"),
                                      CustomTextfield(hintText: "Enter price", controller: _priceController),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 16),

                          if (isMobile) ... [
                            _buildLabel("Payment Method"),
                            _buildDropdown(
                              hint: "Cash on delivery",
                              value: _selectedPaymentMethod,
                              items: ["Cash on delivery", "Card payment"],
                              onChanged: (val) => setState(() => _selectedPaymentMethod = val),
                            ),
                            const SizedBox(height: 16),
                            _buildLabel("Status"),
                            _buildDropdown(
                              hint: "paid",
                              value: _selectedStatus,
                              items: ["paid", "unpaid"],
                              onChanged: (val) => setState(() => _selectedStatus = val),
                            ),
                          ] else 
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel("Payment Method"),
                                      _buildDropdown(
                                        hint: "Cash on delivery",
                                        value: _selectedPaymentMethod,
                                        items: ["Cash on delivery", "Card payment"],
                                        onChanged: (val) => setState(() => _selectedPaymentMethod = val),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel("Status"),
                                      _buildDropdown(
                                        hint: "paid",
                                        value: _selectedStatus,
                                        items: ["paid", "unpaid"],
                                        onChanged: (val) => setState(() => _selectedStatus = val),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 16),

                          _buildLabel("Order Notes (Optional)"),
                          CustomTextfield(
                            hintText: "Add any special instructions",
                            maxLines: 3,
                            controller: _notesController,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Create or Update Order object
                        final updatedOrder = (widget.order ?? OrderMod(
                          orderId: '#ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                          customerName: _nameController.text,
                          phone: _phoneController.text,
                          address: _toController.text,
                          status: _selectedStatus == 'paid' ? OrderStatus.confirmed : OrderStatus.pending,
                          shippingCharge: double.tryParse(_priceController.text) ?? 0.0,
                          deliveryTime: 'Today, Soon',
                          avatarInitials: _nameController.text.isNotEmpty ? _nameController.text.substring(0, 1).toUpperCase() : 'U',
                          avatarColor: Colors.blue,
                        )).copyWith(
                          customerName: _nameController.text,
                          phone: _phoneController.text,
                          email: _emailController.text,
                          fromAddress: _fromController.text,
                          toAddress: _toController.text,
                          address: _toController.text,
                          productName: _productController.text,
                          productSize: _sizeController.text,
                          quantity: _quantity,
                          paymentMethod: _selectedPaymentMethod,
                          notes: _notesController.text,
                          price: double.tryParse(_priceController.text),
                          status: _selectedStatus == 'paid' ? OrderStatus.confirmed : OrderStatus.pending,
                        );
                        Navigator.pop(context, updatedOrder);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: Text(widget.order != null ? "Save Changes" : "Create Order", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.onSurface,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
                      ),
                      child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.surface : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerTheme.color ?? const Color(0xffEEEEEE)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(hint, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 14)),
          icon: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).textTheme.bodySmall?.color, size: 20),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildQuantityDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.surface : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerTheme.color ?? const Color(0xffEEEEEE)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$_quantity", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => setState(() => _quantity++),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Icon(Icons.keyboard_arrow_up, size: 14, color: Theme.of(context).textTheme.bodySmall?.color),
                ),
              ),
              InkWell(
                onTap: () {
                  if (_quantity > 1) setState(() => _quantity--);
                },
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Icon(Icons.keyboard_arrow_down, size: 14, color: Theme.of(context).textTheme.bodySmall?.color),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
