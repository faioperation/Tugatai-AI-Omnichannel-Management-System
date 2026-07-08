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
  String? _selectedImagePath;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(FetchProfileRequested());
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
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
            'Settings',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Manage your system preferences and configurations',
            style: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.bodyMedium?.color),
          ),

          const SizedBox(height: 24),

          // PROFILE CARD
          BlocConsumer<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is ProfileUpdateSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully!')),
                );
              } else if (state is ProfileError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${state.message}')),
                );
              }
            },
            builder: (context, state) {
              bool isLoading = state is ProfileLoading || state is ProfileUpdating;

              if (state is ProfileLoaded || state is ProfileUpdating || state is ProfileUpdateSuccess) {
                final user = (state is ProfileLoaded)
                    ? state.user
                    : (state is ProfileUpdating)
                        ? state.currentUser
                        : (state as ProfileUpdateSuccess).user;

                if (_firstNameController.text.isEmpty && _lastNameController.text.isEmpty) {
                  _firstNameController.text = user.firstName;
                  _lastNameController.text = user.lastName ?? '';
                }

                return _buildProfileCard(context, user, isLoading);
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

                  // const SizedBox(height: 16),
                  //
                  // CustomProfile(
                  //   label: "Phone Number",
                  //   hint: "+1 (555) 000-0000",
                  //   icon: Icons.phone_android,
                  // ),
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
                        "Save",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}