import 'package:flutter/material.dart';
import 'package:roberto/features/management/widget/custom_adduser.dart';

class CustomUserRow extends StatefulWidget {
  final String slNo;
  final String username;
  final String mail;
  final String location;
  final String status;
  final bool isMobile;

  const CustomUserRow({
    super.key,
    required this.slNo,
    required this.username,
    required this.mail,
    required this.location,
    required this.status,
    this.isMobile = false,
  });

  @override
  State<CustomUserRow> createState() => _CustomUserRowState();
}

class _CustomUserRowState extends State<CustomUserRow> {
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.status;
  }

  bool get _isActive => _currentStatus.toLowerCase() == 'active';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (widget.isMobile) {
      return _buildMobileCard(context);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerTheme.color ?? const Color(0xffEEEEEE)),
        ),
      ),
      child: Row(
        children: [
          // SL No
          Expanded(
            flex: 1,
            child: Text(widget.slNo, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface)),
          ),

          // Name
          Expanded(
            flex: 2,
            child: Text(widget.username,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: theme.colorScheme.onSurface)),
          ),

          // Contact
          Expanded(
            flex: 2,
            child: Text(widget.mail,
                style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 13)),
          ),

          // Location
          // Expanded(
          //   flex: 2,
          //   child: Row(
          //     children: [
          //       Icon(Icons.location_on, size: 14, color: theme.textTheme.bodySmall?.color),
          //       const SizedBox(width: 4),
          //       Expanded(
          //         child: Text(
          //           widget.location,
          //           overflow: TextOverflow.ellipsis,
          //           style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 13),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

          // Status
          Expanded(
            flex: 2,
            child: Center(child: _buildStatusDropdown(context)),
          ),
          const SizedBox(width: 16),

          // Actions
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionIcon(Icons.edit_outlined, Colors.blue, () {
                  showDialog(
                    context: context,
                    builder: (context) => CustomAdduser(
                      isEdit: true,
                      username: widget.username,
                      mail: widget.mail,
                      // location: widget.location,
                      status: _currentStatus,
                    ),
                  );
                }),
                const SizedBox(width: 8),
                // _buildActionIcon(Icons.remove_red_eye_outlined,
                //     theme.textTheme.bodySmall?.color ?? Colors.grey, () {}),
                // const SizedBox(width: 8),
                _buildActionIcon(Icons.delete_outline, Colors.red, () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerTheme.color ?? const Color(0xffEEEEEE)),
        boxShadow: !isDark ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.slNo,
                style: TextStyle(
                  color: theme.textTheme.bodySmall?.color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildStatusDropdown(context),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.username,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.email_outlined, size: 14, color: theme.textTheme.bodySmall?.color),
              const SizedBox(width: 4),
              Text(widget.mail, style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 14, color: theme.textTheme.bodySmall?.color),
              const SizedBox(width: 4),
              Text(widget.location, style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: theme.dividerTheme.color),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionIcon(Icons.edit_outlined, Colors.blue, () {
                showDialog(
                  context: context,
                  builder: (context) => CustomAdduser(
                    isEdit: true,
                    username: widget.username,
                    mail: widget.mail,
                    location: widget.location,
                    status: _currentStatus,
                  ),
                );
              }),
              const SizedBox(width: 12),
              _buildActionIcon(Icons.remove_red_eye_outlined,
                  theme.textTheme.bodySmall?.color ?? Colors.grey, () {}),
              const SizedBox(width: 12),
              _buildActionIcon(Icons.delete_outline, Colors.red, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final activeBg = isDark ? const Color(0xFF1B5E20).withValues(alpha: 0.2) : const Color(0xFFE8F5E9);
    final inactiveBg = isDark ? const Color(0xFFB71C1C).withValues(alpha: 0.2) : const Color(0xFFFFEBEE);
    final activeColor = isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32);
    final inactiveColor = isDark ? const Color(0xFFE57373) : const Color(0xFFC62828);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _isActive ? activeBg : inactiveBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isActive ? activeColor.withValues(alpha: 0.3) : inactiveColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _currentStatus.toLowerCase(),
          isDense: true,
          dropdownColor: theme.cardTheme.color,
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 14,
            color: _isActive ? activeColor : inactiveColor,
          ),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: _isActive ? activeColor : inactiveColor,
          ),
          items: const [
            DropdownMenuItem(value: 'active', child: Text('Active')),
            DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _currentStatus = value;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}