import 'package:flutter/material.dart';
import 'package:roberto/app/app_routes.dart';
import 'package:roberto/common/user_role.dart';
import '../../../common/custom_button.dart';
import '../widget/custom_screen.dart';
import '../widget/custom_textfield.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/features/Auth/bloc/auth_bloc.dart';
import 'package:roberto/features/Auth/bloc/auth_event.dart';
import 'package:roberto/features/Auth/bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            final user = state.user;
            final role = user.primaryRole;
            String routePath = '';
            if (role == UserRole.systemOwner) {
              routePath = '/system-owner';
            } else if (role == UserRole.businessOwner) {
              routePath = '/business-owner';
            } else if (role == UserRole.branchManager) {
              routePath = '/branch-manager';
            }

            Map<String, String>? branchArg;
            if (user.branchId != null) {
              branchArg = {
                'id': user.branchId!,
                'name': user.branchName ?? 'Branch',
                'address': user.branchAddress ?? '',
              };
            }

            if (routePath.isNotEmpty) {
              Navigator.pushReplacementNamed(
                context,
                '$routePath${Routes.overview}',
                arguments: {
                  'role': role,
                  if (branchArg != null) 'assignedBranch': branchArg,
                },
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Unknown user role"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return CustomScreen(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                    Center(
                      child: Image.asset(
                        Theme.of(context).brightness == Brightness.dark
                            ? 'assets/Omnirra_AI_logo_white.png'
                            : 'assets/Omnirra_AI_logo_black.png',
                        height: 120,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        "Dashboard Login",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Center(
                      child: Text(
                        "Secure access to Matrix Ai platform",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Email Address",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextfield(
                      hintText: "owner@platform.com",
                      controller: _emailController,
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: 20),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Password",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    CustomTextfield(
                      hintText: "*********",
                      isPassword: true,
                      controller: _passwordController,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleLogin(),
                    ),

                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, Routes.forgotPassword);
                      },
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    state is AuthLoading 
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(
                            text: "Login",
                            onTap: _handleLogin,
                          ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
          );
        },
      ),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      context.read<AuthBloc>().add(
        LoginRequested(email: email, password: password),
      );
    }
  }
}