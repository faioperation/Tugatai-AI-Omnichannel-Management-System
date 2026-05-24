import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:roberto/features/Auth/screen/forgot_screen.dart';
import 'package:roberto/app/app_routes.dart';
import 'package:roberto/common/dashboard_layout.dart';
import 'package:roberto/common/user_role.dart';
import '../../../app/app_color.dart';
import '../../../common/custom_button.dart';
import '../widget/custom_screen.dart';
import '../widget/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
      body: CustomScreen(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: SvgPicture.asset(
                'assets/logo.svg',
                height: 80,
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
                "Secure access to farm management platform",
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
            CustomButton(
              text: "Login",
              onTap: _handleLogin,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _handleLogin() {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    UserRole? role;
    Map<String, String>? assignedBranch;

    String routePath = '';
    if (email == "salman@gmail.com" && password == "11") {
      role = UserRole.systemOwner;
      routePath = '/system-owner';
    } else if (email == "sadia@gmail.com" && password == "11") {
      role = UserRole.businessOwner;
      routePath = '/business-owner';
    } else if (email == "manager@gmail.com" && password == "11") {
      role = UserRole.branchManager;
      routePath = '/branch-manager';
      assignedBranch = {
        "name": "Brooklyn Hub",
        "address": "123, Brooklyn, NY"
      };
    }

    if (role != null) {
      Navigator.pushReplacementNamed(
        context,
        '$routePath${Routes.overview}',
        arguments: {
          'role': role,
          'assignedBranch': assignedBranch,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid email or password"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}