import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
// Height based on device

    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Logo & Slogan
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 50.h),
                  child: Text(
                    'ChatBox',
                    style: GoogleFonts.rammettoOne(
                        fontSize: 60.sp, color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),

            // Welcome Image
            Column(
              children: [
                // Welcome Image
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: const Image(
                    image: AssetImage('lib/assets/images/welcome.png'),
                  ),
                ),
              ],
            ),

            Padding(
              padding: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 20.h),
            ),

            // Sign Up Button
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: 30.w, left: 30.w),
                    child: ElevatedButton(
                      // go to register page
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                          // shape: RoundedRectangleBorder(),
                          backgroundColor: Theme.of(context).primaryColor),
                      child: Padding(
                        padding: EdgeInsets.all(15.h),
                        child: Text('Get Started',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.sp,
                                color: Colors.white)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
