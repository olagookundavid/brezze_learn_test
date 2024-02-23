import 'package:brezze_learn_test/auth/notifiiers/auth_notifier.dart';
import 'package:brezze_learn_test/helper/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class Logout extends StatelessWidget {
  Logout({super.key, this.color});
  final Color? color;
  final TextEditingController ctrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .4,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.sp),
          child: Column(
            children: [
              10.ph,
              Container(
                width: 50.w,
                height: 7.h,
                decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(2)),
              ),
              10.ph,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: double.infinity,
                  ),
                  SizedBox(
                      height: 50.h,
                      width: 50.w,
                      child: Image.asset(
                        'lib/assets/images/logoutpic.png',
                        fit: BoxFit.fill,
                      )),
                  5.ph,
                  Text(
                    'Logout',
                    style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff212121)),
                  ),
                  12.ph,
                  Text(
                    'Oh no, you’re leaving! Are you sure?',
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xff5A6376)),
                  ),
                  40.ph,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Consumer<AuthenticationNotifier>(
                          builder: (context, value, child) {
                        final auth = context.read<AuthenticationNotifier>();
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white),
                          onPressed: () {
                            auth.logout();
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: const Text(
                              'Logout',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple),
                            ),
                          ),
                        );
                      }),
                      10.ph,
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
