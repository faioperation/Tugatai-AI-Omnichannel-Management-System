import 'dart:io';

void main() {
  final file = File('lib/features/businesssetting/screen/businessowner_settings.dart');
  String content = file.readAsStringSync();
  
  if (!content.contains("import 'package:roberto/core/services/local_storage_service.dart';")) {
    content = content.replaceFirst(
      "import 'package:flutter/material.dart';",
      "import 'package:flutter/material.dart';\nimport 'package:roberto/core/services/local_storage_service.dart';\nimport 'package:roberto/features/management/bloc/management_bloc.dart';\nimport 'package:roberto/features/management/bloc/management_state.dart';"
    );
  }

  // Replace _showWhatsAppDialog
  final RegExp regex = RegExp(r'void _showWhatsAppDialog\(BuildContext context\) \{.*?\n  \}', dotAll: true);
  
  final String newDialog = '''
  void _showWhatsAppDialog(BuildContext context) {
    final wabaIdController = TextEditingController();
    final phoneNumberIdController = TextEditingController();
    final phoneNumberController = TextEditingController();
    String? selectedDropdownBranchId;

    final needsDropdown = widget.branchId.isEmpty;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Theme.of(context).cardTheme.color,
              child: Container(
                width: 400,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset('assets/msg.svg', height: 28, width: 28),
                        const SizedBox(width: 12),
                        Text(
                          'Connect WhatsApp',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your WhatsApp Business API details below.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    if (needsDropdown) ...[
                      BlocBuilder<ManagementBloc, ManagementState>(
                        builder: (context, state) {
                          if (state is ManagementLoaded) {
                            return DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Select Branch',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              value: selectedDropdownBranchId,
                              items: state.branches.map((branch) {
                                return DropdownMenuItem(
                                  value: branch.id,
                                  child: Text(branch.name),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  selectedDropdownBranchId = val;
                                });
                              },
                            );
                          }
                          return const Center(child: CircularProgressIndicator());
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    _buildTextField(context, wabaIdController, 'WABA ID', Icons.business),
                    const SizedBox(height: 16),
                    _buildTextField(context, phoneNumberIdController, 'Phone Number ID', Icons.phone_android),
                    const SizedBox(height: 16),
                    _buildTextField(context, phoneNumberController, 'Phone Number', Icons.phone),
                    
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            final branchIdToUse = needsDropdown ? selectedDropdownBranchId : widget.branchId;
                            
                            if (branchIdToUse == null || branchIdToUse.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please select a branch first')),
                              );
                              return;
                            }

                            final accessToken = LocalStorageService.accessToken ?? '';

                            context.read<SocialMediaBloc>().add(
                                  ConnectWhatsAppEvent(
                                    branchId: branchIdToUse,
                                    wabaId: wabaIdController.text,
                                    phoneNumberId: phoneNumberIdController.text,
                                    phoneNumber: phoneNumberController.text,
                                    accessToken: accessToken,
                                  ),
                                );
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Connect',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(BuildContext context, TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColor.primary.withOpacity(0.7)),
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).dividerTheme.color ?? const Color(0xffEEEEEE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.primary),
        ),
      ),
    );
  }
''';

  content = content.replaceFirst(regex, newDialog);
  file.writeAsStringSync(content);
}
