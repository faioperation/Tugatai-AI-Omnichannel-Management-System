import 'package:flutter/material.dart';
import 'package:roberto/app/app_routes.dart';
import '../../../common/custom_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widget/custom_screen.dart';
import '../widget/custom_textfield.dart';
import '../bloc/forgot_password_bloc.dart';
import '../bloc/forgot_password_event.dart';
import '../bloc/forgot_password_state.dart';


class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
        listener: (context, state) {
          if (state is ForgotPasswordOtpSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            Navigator.pushNamed(context, Routes.verifyOtp, arguments: _emailController.text.trim());
          } else if (state is ForgotPasswordFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
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
              controller: _emailController,
              hintText: "owner@platform.com",
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleSend(),
            ),

            const SizedBox(height: 25),
            state is ForgotPasswordLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomButton(
                    text: "Send",
                    onTap: _handleSend,
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

  void _handleSend() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      context.read<ForgotPasswordBloc>().add(ForgotPasswordRequested(email: email));
    }
  }
}