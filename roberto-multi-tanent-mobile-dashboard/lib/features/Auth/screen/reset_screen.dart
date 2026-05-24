import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:roberto/app/app_routes.dart';
import 'package:roberto/features/Auth/screen/successful_screen.dart';
import '../../../app/app_color.dart';
import '../../../common/custom_button.dart';
import '../widget/custom_screen.dart';
import '../widget/custom_textfield.dart';


class ResetScreen extends StatefulWidget {
  const ResetScreen({super.key});

  @override
  State<ResetScreen> createState() => _ResetScreenState();
}

class _ResetScreenState extends State<ResetScreen> {
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
                "Set a new Password",
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
                "Ensure it different from previous ones for security",
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
                "New Password",
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
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Confirm Password",
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
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleReset(),
            ),

            const SizedBox(height: 25),
            CustomButton(
              text: "Reset Password",
              onTap: _handleReset,
            ),

            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }

  void _handleReset() {
    Navigator.pushNamed(context, Routes.success);
  }
}