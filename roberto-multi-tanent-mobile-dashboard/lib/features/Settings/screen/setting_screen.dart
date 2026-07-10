import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/app/theme_controller.dart';
import 'package:roberto/features/Settings/widget/custom_profile.dart';
import 'package:roberto/features/Settings/bloc/profile_bloc.dart';
import 'package:roberto/features/Settings/bloc/profile_event.dart';
import 'package:roberto/features/Settings/bloc/profile_state.dart';
import 'package:image_picker/image_picker.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String? _selectedImagePath;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(FetchProfileRequested());
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Update your profile information and password',
            style: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.bodyMedium?.color),
          ),

          const SizedBox(height: 24),

          // PROFILE CARD
          BlocConsumer<ProfileBloc, ProfileState>(
            listenWhen: (previous, current) =>
                current is ProfileUpdateSuccess ||
                current is ProfileError ||
                current is PasswordChangeSuccess ||
                current is PasswordChangeError,
            listener: (context, state) {
              if (state is ProfileUpdateSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is ProfileError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${state.message}'), backgroundColor: Colors.red),
                );
              } else if (state is PasswordChangeSuccess) {
                _oldPasswordController.clear();
                _newPasswordController.clear();
                _confirmPasswordController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password changed successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is PasswordChangeError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${state.message}'), backgroundColor: Colors.red),
                );
              }
            },
            builder: (context, state) {
              bool isProfileLoading = state is ProfileLoading || state is ProfileUpdating;
              bool isPasswordLoading = state is PasswordChanging;

              if (state is ProfileLoaded || state is ProfileUpdating || state is ProfileUpdateSuccess || state is PasswordChanging || state is PasswordChangeError) {
                final user = (state is ProfileLoaded)
                    ? state.user
                    : (state is ProfileUpdating)
                        ? state.currentUser
                        : (state is ProfileUpdateSuccess)
                            ? state.user
                            : (state is PasswordChanging)
                                ? state.currentUser
                                : (state as PasswordChangeError).currentUser;

                if (_firstNameController.text.isEmpty && _lastNameController.text.isEmpty) {
                  _firstNameController.text = user.firstName;
                  _lastNameController.text = user.lastName ?? '';
                }

                return Column(
                  children: [
                    _buildProfileCard(context, user, isProfileLoading),
                    const SizedBox(height: 24),
                    _buildChangePasswordCard(context, isPasswordLoading),
                  ],
                );
              } else if (state is ProfileError) {
                return Center(child: Text("Error loading profile: ${state.message}"));
              }
              
              return const Center(child: CircularProgressIndicator());
            },
          ),

          const SizedBox(height: 24),

          // SYSTEM PREFERENCES CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerTheme.color ?? Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "System Preferences",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ListenableBuilder(
                  listenable: themeController,
                  builder: (context, _) {
                    return SwitchListTile(
                      title: const Text("Dark Mode"),
                      subtitle: const Text("Switch between light and dark system themes"),
                      value: themeController.isDarkMode,
                      activeThumbColor: AppColor.primary,
                      onChanged: (value) {
                        themeController.toggleTheme();
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, dynamic user, bool isLoading) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerTheme.color ?? const Color(0xffEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Profile Information",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (user.branchName != null && user.branchName.toString().isNotEmpty)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.branchName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        if (user.branchAddress != null)
                          Text(user.branchAddress, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 19),

          // Avatar
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColor.secondary,
                backgroundImage: _selectedImagePath != null
                    ? (kIsWeb ? NetworkImage(_selectedImagePath!) : FileImage(File(_selectedImagePath!))) as ImageProvider
                    : (user.profilePicture != null && user.profilePicture!.isNotEmpty)
                        ? NetworkImage(user.profilePicture!.replaceFirst('http://', 'https://'), headers: const {'ngrok-skip-browser-warning': 'true'})
                        : null,
                child: (_selectedImagePath == null && (user.profilePicture == null || user.profilePicture!.isEmpty))
                    ? const Icon(Icons.person, color: Colors.grey, size: 36)
                    : null,
              ),
              const SizedBox(width: 16),

              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                      ),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (image != null) {
                          final bytes = await image.readAsBytes();
                          setState(() {
                            _selectedImagePath = image.path;
                            _selectedImageBytes = bytes;
                            _selectedImageName = image.name;
                          });
                        }
                      },
                      child: const Text(
                        "Change Photo",
                        style: TextStyle(
                          color: AppColor.white,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "JPG, PNG or GIF. Max size 2MB.",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Divider(color: Theme.of(context).dividerTheme.color ?? const Color(0xffEEEEEE)),
          const SizedBox(height: 20),

          // Form
          LayoutBuilder(
            builder: (context, constraints) {
              bool isMobile = constraints.maxWidth < 600;

              return Column(
                children: [
                  isMobile
                      ? Column(
                    children: [
                      CustomProfile(
                        label: "First Name",
                        hint: "System",
                        controller: _firstNameController,
                      ),
                      const SizedBox(height: 16),
                      CustomProfile(
                        label: "Last Name",
                        hint: "Owner",
                        controller: _lastNameController,
                      ),
                    ],
                  )
                      : Row(
                    children: [
                      Expanded(
                          child: CustomProfile(
                             label:  "First Name", hint: "System", controller: _firstNameController)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: CustomProfile(
                              label: "Last Name", hint: "Owner", controller: _lastNameController)),
                    ],
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 30),

          // Save Button
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 140,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                ),
                onPressed: isLoading
                    ? null
                    : () {
                        context.read<ProfileBloc>().add(
                              UpdateProfileRequested(
                                firstName: _firstNameController.text,
                                lastName: _lastNameController.text,
                                avatarPath: _selectedImagePath,
                                avatarBytes: _selectedImageBytes,
                                avatarName: _selectedImageName,
                              ),
                            );
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        "Save Changes",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangePasswordCard(BuildContext context, bool isLoading) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerTheme.color ?? const Color(0xffEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Change Password",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            "Update your password to keep your account secure",
            style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
          const SizedBox(height: 20),
          Divider(color: Theme.of(context).dividerTheme.color ?? const Color(0xffEEEEEE)),
          const SizedBox(height: 20),

          // Old Password
          _buildPasswordField(
            controller: _oldPasswordController,
            label: "Current Password",
            hint: "Enter current password",
            obscure: _obscureOld,
            onToggle: () => setState(() => _obscureOld = !_obscureOld),
          ),
          const SizedBox(height: 16),

          // New Password
          LayoutBuilder(
            builder: (context, constraints) {
              bool isMobile = constraints.maxWidth < 600;
              if (isMobile) {
                return Column(
                  children: [
                    _buildPasswordField(
                      controller: _newPasswordController,
                      label: "New Password",
                      hint: "Enter new password",
                      obscure: _obscureNew,
                      onToggle: () => setState(() => _obscureNew = !_obscureNew),
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      label: "Confirm New Password",
                      hint: "Re-enter new password",
                      obscure: _obscureConfirm,
                      onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: _buildPasswordField(
                      controller: _newPasswordController,
                      label: "New Password",
                      hint: "Enter new password",
                      obscure: _obscureNew,
                      onToggle: () => setState(() => _obscureNew = !_obscureNew),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPasswordField(
                      controller: _confirmPasswordController,
                      label: "Confirm New Password",
                      hint: "Re-enter new password",
                      obscure: _obscureConfirm,
                      onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 30),

          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 160,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                ),
                onPressed: isLoading
                    ? null
                    : () {
                        final oldPass = _oldPasswordController.text.trim();
                        final newPass = _newPasswordController.text.trim();
                        final confirmPass = _confirmPasswordController.text.trim();

                        if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill in all password fields.'), backgroundColor: Colors.orange),
                          );
                          return;
                        }
                        if (newPass != confirmPass) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('New passwords do not match.'), backgroundColor: Colors.red),
                          );
                          return;
                        }
                        if (newPass.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password must be at least 6 characters.'), backgroundColor: Colors.orange),
                          );
                          return;
                        }
                        context.read<ProfileBloc>().add(
                              ChangePasswordRequested(
                                oldPassword: oldPass,
                                newPassword: newPass,
                              ),
                            );
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        "Change Password",
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Theme.of(context).hintColor, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).dividerTheme.color ?? Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).dividerTheme.color ?? Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColor.primary, width: 1.5),
            ),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: Colors.grey),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }
}

