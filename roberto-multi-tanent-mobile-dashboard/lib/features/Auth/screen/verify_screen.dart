import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:roberto/app/app_routes.dart';
import '../../../app/app_color.dart';
import '../../../common/custom_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widget/custom_screen.dart';
import '../bloc/forgot_password_bloc.dart';
import '../bloc/forgot_password_event.dart';
import '../bloc/forgot_password_state.dart';

class VerifyScreen extends StatefulWidget {
  final String email;
  const VerifyScreen({super.key, required this.email});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
        listener: (context, state) {
          if (state is ForgotPasswordOtpVerified) {
            Navigator.pushNamed(context, Routes.resetPassword);
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
                "Check Your Email",
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
                "We sent a code to ${widget.email.isNotEmpty ? widget.email : 'your email address'}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
            const SizedBox(height: 20),

            PinCodeTextField(
                length: 6,
                obscureText: false,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(8),
                    fieldHeight: 50,
                    fieldWidth: 40,
                    activeColor: AppColor.primary,
                    selectedColor: AppColor.primary,
                    inactiveColor: Theme.of(context).dividerTheme.color),
                animationDuration: const Duration(milliseconds: 300),
                controller: _otpController,
                appContext: context,
                onCompleted: (_) => _handleVerify(),
                validator: (v) {
                  if (v == null || v.length < 6) {
                    return "Please enter a 6-digit OTP";
                  }
                  return null;
                },
            ),

            const SizedBox(height: 25),
            state is ForgotPasswordLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomButton(
                    text: "Verify",
                    onTap: _handleVerify,
                  ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {},
              child: RichText(
                text: TextSpan(
                  text: "You have not received the email?  ",
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  children: const [
                    TextSpan(
                      text: "Resend",
                      style: TextStyle(
                        color: AppColor.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      );
      },
      ),
    );
  }

  void _handleVerify() {
    if (_formKey.currentState!.validate()) {
      final otp = _otpController.text.trim();
      context.read<ForgotPasswordBloc>().add(VerifyOtpRequested(email: widget.email, otp: otp));
    }
  }
}