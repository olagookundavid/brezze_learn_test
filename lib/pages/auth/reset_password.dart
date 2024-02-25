import 'package:brezze_learn_test/auth/login_or_register.dart';
import 'package:brezze_learn_test/auth/notifiiers/auth_notifier.dart';
import 'package:brezze_learn_test/helper/alert_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
// Email Controller
  final _emailController = TextEditingController();

// Memory management
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: const Text('Reset Password',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 50.h, bottom: 50.h),
              child: Image(
                image: const AssetImage(
                  'lib/assets/images/email_otp.png',
                ),
                width: 300.w,
              ),
            ),

// Instructions
            Padding(
              padding: EdgeInsets.only(left: 30.w, right: 30.w),
              child: Text(
                'Enter your email address and we will send you a link to reset your password.',
                style: TextStyle(fontSize: 16.sp),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 30.h),

// Form Field
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 30.w, left: 30.w),
                  child: TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                        labelText: 'Enter your email',
                        focusedBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.r)),
                          borderSide: BorderSide(
                              color: Theme.of(context)
                                  .primaryColor), // Customize underline color
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.r)),
                          borderSide:
                              BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        fillColor: Theme.of(context).primaryColor),
                  ),
                ),

                SizedBox(height: 20.h),

// Submit Button
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.only(left: 30.w, right: 30.w),
                    child: Consumer<AuthViewModel>(
                        builder: (context, authViewModel, child) {
                      return authViewModel.isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor),
                              onPressed: () async {
                                await authViewModel.sendPasswordResetEmail(
                                    _emailController.text);
                                if (authViewModel.errorMessage != null) {
                                  // Show a snackbar with the error message
                                  if (mounted) {
                                    getAlert(
                                        context, authViewModel.errorMessage!);
                                  }
                                  return;
                                }
                                if (mounted) {
                                  getAlert(context,
                                      'Successfully sent reset email!');
                                }
                                if (mounted) {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginOrRegister(),
                                      ));
                                }
                              },
                              child: Padding(
                                padding: EdgeInsets.all(15.w),
                                child: Text(
                                  'Submit',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.sp,
                                      color: Colors.white),
                                ),
                              ),
                            );
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
