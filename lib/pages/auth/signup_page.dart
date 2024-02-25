import 'package:brezze_learn_test/auth/notifiiers/auth_notifier.dart';
import 'package:brezze_learn_test/components/password_field.dart';
import 'package:brezze_learn_test/components/text_field.dart';
import 'package:brezze_learn_test/helper/alert_box.dart';
import 'package:brezze_learn_test/helper/utils.dart';
import 'package:brezze_learn_test/pages/landing_page.dart';
import 'package:brezze_learn_test/widgets/buttons/login_register_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  final Function()? onPressed;
  const SignUpPage({super.key, required this.onPressed});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
// Text Editing Controllers
  final fullNameTextController = TextEditingController();
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.grey.shade100,
        body: SafeArea(
            child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Column(
              children: [
                // Welcome Image
                Image.asset(
                  'lib/assets/images/register.png',
                ),
                30.ph,
                // Welcome Back Message
                Text('Hello There!',
                    style: TextStyle(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor)),
                20.ph,

                // Email Textfield
                MyTextField(
                  controller: fullNameTextController,
                  hintText: 'Enter Name',
                  obscureText: false,
                  prefixIcon: Icons.person,
                ),

                10.ph,

                // Email Textfield
                MyTextField(
                  controller: emailTextController,
                  hintText: 'Enter Email',
                  obscureText: false,
                  prefixIcon: Icons.email,
                ),

                10.ph,

                //  Password Textfield
                MyPasswordField(
                  controller: passwordTextController,
                ),

                20.ph,

                // Sign Up Button

                Consumer<AuthViewModel>(
                  builder: (context, authViewModel, child) {
                    return authViewModel.isLoading
                        ? const CircularProgressIndicator()
                        : LoginRegisterButton(
                            text: 'Sign Up',
                            onPressed: () async {
                              if (emailTextController.text.isEmpty &&
                                  passwordTextController.text.isEmpty &&
                                  fullNameTextController.text.isEmpty) {
                                if (mounted) {
                                  getAlert(context, 'Fill all fields');
                                }
                                return;
                              }
                              // Call the signIn method
                              await authViewModel.signUpWithEmailPassword(
                                  emailTextController.text,
                                  passwordTextController.text,
                                  fullNameTextController.text);

                              if (authViewModel.errorMessage != null) {
                                // Show a snackbar with the error message
                                if (mounted) {
                                  getAlert(
                                      context, authViewModel.errorMessage!);
                                }
                                return;
                              }
                              if (mounted) {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LandingPage(),
                                    ));
                              }
                            });
                  },
                ),

                20.ph,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700)),
                    TextButton(
                        onPressed: widget.onPressed,
                        child: Text('Login now',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600))),
                  ],
                )
              ],
            ),
          ),
        )));
  }
}
