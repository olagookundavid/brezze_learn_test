import 'package:brezze_learn_test/auth/notifiiers/auth_notifier.dart';
import 'package:brezze_learn_test/components/text_field.dart';
import 'package:brezze_learn_test/helper/alert_box.dart';
import 'package:brezze_learn_test/helper/biometrics_helper.dart';
import 'package:brezze_learn_test/helper/storage_class.dart';
import 'package:brezze_learn_test/helper/utils.dart';
import 'package:brezze_learn_test/pages/landing_page.dart';
import 'package:brezze_learn_test/widgets/buttons/login_register_button.dart';
import 'package:brezze_learn_test/widgets/forgot_password_footer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../components/password_field.dart';

class LoginPage extends StatefulWidget {
  final Function()? onPressed;
  const LoginPage({super.key, required this.onPressed});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
// Text Editing Controllers
  String initialEmail = HiveStorage.get(HiveKeys.userName) ?? '';
  String password = HiveStorage.get(HiveKeys.password) ?? '';
  late final TextEditingController emailTextController;
  late final TextEditingController passwordTextController;
  @override
  void initState() {
    emailTextController = TextEditingController(text: initialEmail);
    passwordTextController = TextEditingController();
    super.initState();
  }

  bool showBiometrics = HiveStorage.get(HiveKeys.showBiometrics) ?? false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: SafeArea(
            child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0.w),
            child: Column(
              children: [
                // Welcome Image
                Image.asset(
                  'lib/assets/images/login.png',
                ),
                30.ph,
                // Welcome Back Message
                Text('Welcome Back!',
                    style: TextStyle(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor)),
                20.ph,
                // Email Textfield
                MyTextField(
                  controller: emailTextController,
                  hintText: 'Enter Email',
                  obscureText: false,
                  prefixIcon: Icons.email,
                ),

                10.ph,

                // Password Textfield
                MyPasswordField(
                  controller: passwordTextController,
                ),

                // Forgot Password
                const ForgotPasswordFooter(),

                // Sign Button
                Consumer<AuthViewModel>(
                  builder: (context, authViewModel, child) {
                    return authViewModel.isLoading
                        ? const CircularProgressIndicator()
                        : LoginRegisterButton(
                            text: 'Login',
                            onPressed: () async {
                              if (emailTextController.text.isEmpty &&
                                  passwordTextController.text.isEmpty) {
                                if (mounted) {
                                  getAlert(context, 'Fill all fields');
                                }
                                return;
                              }
                              // Call the signIn method
                              await authViewModel.signInWithEmailPassword(
                                  emailTextController.text,
                                  passwordTextController.text);

                              if (authViewModel.errorMessage != null) {
                                // Show a snackbar with the error message
                                if (mounted) {
                                  getAlert(context,
                                      'Successfully updated profile picture!');
                                }

                                return;
                              }
                              if (mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const LandingPage()),
                                  (Route<dynamic> route) => false,
                                );
                              }
                            });
                  },
                ),

                15.ph,
                Center(child: Consumer<AuthViewModel>(
                    builder: (context, authViewModel, child) {
                  return authViewModel.isLoading
                      ? const CircularProgressIndicator()
                      : InkWell(
                          onTap: () async {
                            if (!showBiometrics) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Biometrics not enabled',
                                        style: TextStyle(fontSize: 20.sp)),
                                    content: Text(
                                      'You have to login and enable Biometrics Authentication.',
                                      style: TextStyle(fontSize: 15.sp),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          'OK',
                                          style: TextStyle(fontSize: 15.sp),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                              return;
                            }
                            final isAuthenticated =
                                await LocalAuthApi.authenticate();
                            if (isAuthenticated) {
                              await authViewModel.signInWithEmailPassword(
                                  initialEmail, password);

                              if (authViewModel.errorMessage != null) {
                                // Show a snackbar with the error message
                                if (mounted) {
                                  getAlert(context,
                                      'Successfully updated profile picture!');
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
                            } else {
                              if (mounted) {
                                getAlert(context, 'Could\'t Authenticate User');
                              }
                            }
                          },
                          child: Text(
                            'Login With Biometrics',
                            style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.blueGrey),
                          ),
                        );
                })),
                20.ph,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Don\'t have an account?',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700)),
                    TextButton(
                        onPressed: widget.onPressed,
                        child: Text('Register now',
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
