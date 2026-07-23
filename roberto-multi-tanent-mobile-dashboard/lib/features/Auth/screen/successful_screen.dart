import 'package:flutter/material.dart';
import 'package:roberto/app/app_routes.dart';
import '../../../common/custom_button.dart';
import '../widget/custom_screen.dart';


class SuccessfulScreen extends StatefulWidget {
  const SuccessfulScreen({super.key});

  @override
  State<SuccessfulScreen> createState() => _SuccessfulScreenState();
}

class _SuccessfulScreenState extends State<SuccessfulScreen> {


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
                "Password Updated Successfully!",
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
                "Your new password has been saved. You can now continue securely.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),

            const SizedBox(height: 25),
            CustomButton(
              text: "Login",
              onTap: () {
                Navigator.pushReplacementNamed(context, Routes.login);
              },
            ),

            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }
}