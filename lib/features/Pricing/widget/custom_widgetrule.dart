import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';

class CustomWidgetrule extends StatefulWidget {
  final String title;
  final String badgeText;
  final String description;
  final Map<String, dynamic>? rawConfiguration;

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CustomWidgetrule({
    super.key,
    required this.title,
    required this.badgeText,
    required this.description,
    this.rawConfiguration,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<CustomWidgetrule> createState() => _CustomWidgetruleState();
}

class _CustomWidgetruleState extends State<CustomWidgetrule> {
  bool isActive = true;

  Widget _buildConfigView(BuildContext context) {
    final config = widget.rawConfiguration;
    if (config == null || config.isEmpty) {
      return Text(
        widget.description,
        style: TextStyle(
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    List<Widget> items = [];

    // Currency
    if (config.containsKey('currency')) {
      items.add(_buildConfigItem(
        icon: Icons.monetization_on_outlined,
        label: "Currency",
        value: config['currency'].toString().toUpperCase(),
        theme: theme,
      ));
    }

    // Min Charge
    if (config.containsKey('minimumCharge')) {
      items.add(_buildConfigItem(
        icon: Icons.shopping_bag_outlined,
        label: "Min Charge",
        value: "\$${config['minimumCharge']}",
        theme: theme,
      ));
    }

    // Tax
    if (config['tax'] is Map) {
      final tax = config['tax'] as Map;
      if (tax['enabled'] == true) {
        items.add(_buildConfigItem(
          icon: Icons.percent,
          label: "Tax",
          value: "${tax['percentage']}%",
          theme: theme,
        ));
      }
    }

    // Weight Rate
    if (config['weight'] is Map) {
      final w = config['weight'] as Map;
      if (w['enabled'] == true) {
        items.add(_buildConfigItem(
          icon: Icons.fitness_center,
          label: "Weight Rate",
          value: "\$${w['rate']}/${w['unit'] ?? 'kg'}",
          theme: theme,
        ));
      }
    }

    // Distance Rate
    if (config['distance'] is Map) {
      final d = config['distance'] as Map;
      if (d['enabled'] == true) {
        items.add(_buildConfigItem(
          icon: Icons.map_outlined,
          label: "Distance Rate",
          value: "\$${d['rate']}/${d['unit'] ?? 'km'}",
          theme: theme,
        ));
      }
    }

    // Services
    if (config['serviceTypes'] is Map) {
      final st = config['serviceTypes'] as Map;
      if (st.isNotEmpty) {
        final names = st.keys.map((k) => k.toString().toUpperCase()).join(", ");
        items.add(_buildConfigItem(
          icon: Icons.local_shipping_outlined,
          label: "Services",
          value: names,
          theme: theme,
        ));
      }
    }

    // Extras
    if (config['additionalCharges'] is Map) {
      final ac = config['additionalCharges'] as Map;
      if (ac.isNotEmpty) {
        final names = ac.keys.map((k) => k.toString()).join(", ");
        items.add(_buildConfigItem(
          icon: Icons.add_circle_outline,
          label: "Extras",
          value: names,
          theme: theme,
        ));
      }
    }

    return Tooltip(
      message: "Click to view full configuration details",
      child: InkWell(
        onTap: () => _showConfigurationDetailsDialog(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? theme.colorScheme.surface.withOpacity(0.3) : const Color(0xffF9FAFB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ...items,
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, size: 12, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    "View details",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
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

  Widget _buildConfigItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 13, color: AppColor.primary.withOpacity(0.8)),
          const SizedBox(width: 6),
          Text(
            "$label: ",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showConfigurationDetailsDialog(BuildContext context) {
    final config = widget.rawConfiguration;
    if (config == null) return;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String formatMoney(dynamic val) {
      if (val == null) return '\$0.00';
      final parsed = double.tryParse(val.toString()) ?? 0.0;
      return '\$${parsed.toStringAsFixed(2)}';
    }

    String formatKey(String key) {
      String formatted = key.replaceAll(RegExp(r'([A-Z])'), r' $1');
      return formatted[0].toUpperCase() + formatted.substring(1);
    }

    showDialog(
      context: context,
      builder: (context) {
        final tax = config['tax'] is Map ? Map<String, dynamic>.from(config['tax']) : null;
        final weight = config['weight'] is Map ? Map<String, dynamic>.from(config['weight']) : null;
        final distance = config['distance'] is Map ? Map<String, dynamic>.from(config['distance']) : null;
        final serviceTypes = config['serviceTypes'] is Map ? Map<String, dynamic>.from(config['serviceTypes']) : null;
        final additionalCharges = config['additionalCharges'] is Map ? Map<String, dynamic>.from(config['additionalCharges']) : null;

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: theme.cardTheme.color ?? (isDark ? Colors.grey.shade900 : Colors.white),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Rule Configuration Details",
                              style: TextStyle(fontSize: 13, color: theme.hintColor),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  _buildDialogSectionHeader("General Settings", Icons.settings_outlined, theme),
                  _buildDialogDetailRow("Currency", config['currency']?.toString().toUpperCase() ?? "USD", theme),
                  _buildDialogDetailRow("Minimum Charge", formatMoney(config['minimumCharge']), theme),
                  
                  if (tax != null) ...[
                    _buildDialogDetailRow(
                      "Tax Rate",
                      "${tax['percentage']}% (${tax['enabled'] == true ? 'Enabled' : 'Disabled'})",
                      theme,
                      valueColor: tax['enabled'] == true ? Colors.green : theme.hintColor,
                    ),
                  ],
                  const SizedBox(height: 16),

                  _buildDialogSectionHeader("Base Rates", Icons.analytics_outlined, theme),
                  if (weight != null) ...[
                    _buildDialogDetailRow(
                      "Weight Rate",
                      weight['enabled'] == true ? "${formatMoney(weight['rate'])} per ${weight['unit'] ?? 'kg'}" : "Disabled",
                      theme,
                      valueColor: weight['enabled'] == true ? null : theme.hintColor,
                    ),
                  ],
                  if (distance != null) ...[
                    _buildDialogDetailRow(
                      "Distance Rate",
                      distance['enabled'] == true ? "${formatMoney(distance['rate'])} per ${distance['unit'] ?? 'km'}" : "Disabled",
                      theme,
                      valueColor: distance['enabled'] == true ? null : theme.hintColor,
                    ),
                  ],
                  const SizedBox(height: 16),

                  if (serviceTypes != null && serviceTypes.isNotEmpty) ...[
                    _buildDialogSectionHeader("Service Type Multipliers", Icons.local_shipping_outlined, theme),
                    const SizedBox(height: 4),
                    Table(
                      border: TableBorder.all(color: theme.dividerColor.withOpacity(0.1), width: 1, borderRadius: BorderRadius.circular(8)),
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                          children: const [
                            Padding(padding: EdgeInsets.all(8), child: Text("Service Type", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                            Padding(padding: EdgeInsets.all(8), child: Text("Multiplier", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          ],
                        ),
                        ...serviceTypes.entries.map((e) {
                          final serviceName = e.key.toString().toUpperCase();
                          final multiplier = e.value is Map ? (e.value as Map)['multiplier'] : e.value;
                          return TableRow(
                            children: [
                              Padding(padding: const EdgeInsets.all(8), child: Text(serviceName, style: const TextStyle(fontSize: 12))),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text("${multiplier}x", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColor.primary)),
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (additionalCharges != null && additionalCharges.isNotEmpty) ...[
                    _buildDialogSectionHeader("Additional Extras", Icons.add_circle_outline, theme),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: additionalCharges.entries.map((e) {
                        return Chip(
                          label: Text("${formatKey(e.key.toString())}: ${formatMoney(e.value)}", style: const TextStyle(fontSize: 12)),
                          backgroundColor: isDark ? theme.colorScheme.surface : const Color(0xffF3F4F6),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        );
                      }).toList(),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text("Close", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogSectionHeader(String title, IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColor.primary),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogDetailRow(String label, String value, ThemeData theme, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium?.color)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor ?? theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 900;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 20 : 16,
        vertical: isDesktop ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: isDesktop ? null : BorderRadius.circular(12),
        border: isDesktop
            ? Border(
                bottom: BorderSide(
                    color: theme.dividerColor.withOpacity(0.1), width: 1))
            : Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      margin: isDesktop ? EdgeInsets.zero : const EdgeInsets.only(bottom: 12),
      child: isDesktop
          ? Row(
              children: [
                // Title
                Expanded(
                  flex: 2,
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),

                // Badge
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? theme.colorScheme.surface
                              : const Color(0xffF3F4F6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.badgeText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Description
                Expanded(
                  flex: 3,
                  child: _buildConfigView(context),
                ),

                // Switch
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Transform.scale(
                      scale: 0.75,
                      child: Switch(
                        value: isActive,
                        onChanged: (value) {
                          setState(() {
                            isActive = value;
                          });
                        },
                        activeThumbColor: AppColor.greens,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ),

                // Actions
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        tooltip: "Edit",
                        onPressed: widget.onEdit,
                        icon: const Icon(
                          Icons.edit,
                          size: 18,
                          color: Colors.blue,
                        ),
                      ),
                      IconButton(
                        tooltip: "Delete",
                        onPressed: widget.onDelete,
                        icon: const Icon(
                          Icons.delete,
                          size: 18,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: isActive,
                  onChanged: (value) {
                    setState(() {
                      isActive = value;
                    });
                  },
                  activeThumbColor: AppColor.greens,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 4, horizontal: 10),
                decoration: BoxDecoration(
                  color: isDark ? theme.colorScheme.surface : const Color(0xffF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.badgeText,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildConfigView(context),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: widget.onEdit,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text("Edit"),
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: widget.onDelete,
                icon: const Icon(Icons.delete, size: 18),
                label: const Text("Delete"),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}