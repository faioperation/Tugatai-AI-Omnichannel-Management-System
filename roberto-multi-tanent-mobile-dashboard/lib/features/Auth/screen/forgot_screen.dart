import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:roberto/app/app_routes.dart';
import 'package:roberto/features/Auth/screen/verify_screen.dart';
import '../../../app/app_color.dart';
import '../../../common/custom_button.dart';
import '../widget/custom_screen.dart';
import '../widget/custom_textfield.dart';


class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  bool _rememberMe = false;


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
                "Reset Password",
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
                "Enter your email to receive a reset link",
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
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleSend(),
            ),

            const SizedBox(height: 25),
            CustomButton(
              text: "Send",
              onTap: _handleSend,
            ),
            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }

  void _handleSend() {
    Navigator.pushNamed(context, Routes.verifyOtp);
  }
}