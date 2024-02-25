import 'package:brezze_learn_test/helper/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsTiles extends StatelessWidget {
  const SettingsTiles({
    super.key,
    required this.text,
    required this.icon,
    this.switchWidget,
    this.color,
    this.text2,
  });
  final String text;
  final String? text2;
  final IconData icon;
  final Widget? switchWidget;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 5.w),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          CircleAvatar(
            radius: 15.r,
            child: Icon(icon),
          ),
          15.pw,
          text2 == null
              ? Text(
                  text,
                  style: TextStyle(
                      fontSize: 12.sp,
                      color: color ?? const Color(0xff212121),
                      fontWeight: FontWeight.w600),
                )
              : SizedBox(
                  width: MediaQuery.of(context).size.width * .6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: TextStyle(
                            fontSize: 12.sp,
                            color: color ?? const Color(0xff212121),
                            fontWeight: FontWeight.w600),
                      ),
                      2.ph,
                      Text(
                        text2!,
                        style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xff868FA0),
                            fontWeight: FontWeight.w400),
                      )
                    ],
                  ),
                ),
          const Spacer(),
          switchWidget ??
              Icon(
                Icons.arrow_forward_ios,
                size: 20.r,
                color: Colors.red,
              )
        ],
      ),
    );
  }
}
