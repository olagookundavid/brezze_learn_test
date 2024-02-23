import 'package:brezze_learn_test/helper/storage_class.dart';
import 'package:brezze_learn_test/helper/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool switchValueAuth = false;
  bool switchValueFingerPrint =
      HiveStorage.get(HiveKeys.showBiometrics) ?? false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Settings',
          style: GoogleFonts.rammettoOne(
              color: Theme.of(context).primaryColorLight, fontSize: 24),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Column(
          children: [
            20.ph,
            const SettingList(keyValue: "Version:", value: '1'),
            15.ph,
            const SettingList(keyValue: "App Name:", value: 'Chat Box'),
            15.ph,
            const SettingList(keyValue: "Company:", value: 'Breeze Learn'),
            15.ph,
            const SettingList(keyValue: "Developer:", value: 'David Olagookun'),
            20.ph,
            SettingsTiles(
              text: 'Enable Fingerprint/Face ID',
              assest: 'enablefinger',
              switchWidget: Switch.adaptive(
                  inactiveTrackColor: Colors.grey.withOpacity(.5),
                  value: switchValueFingerPrint,
                  onChanged: (e) async {
                    switchValueFingerPrint = !switchValueFingerPrint;
                    await HiveStorage.put(
                        HiveKeys.showBiometrics, switchValueFingerPrint);
                    setState(() {});
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingList extends StatelessWidget {
  const SettingList({
    super.key,
    required this.keyValue,
    required this.value,
  });
  final String keyValue, value;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              keyValue,
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
            )
          ],
        ),
        5.ph,
        Divider(
          height: 5.h,
          color: Colors.grey,
        )
      ],
    );
  }
}

class SettingsTiles extends StatelessWidget {
  const SettingsTiles({
    super.key,
    required this.text,
    required this.assest,
    this.switchWidget,
    this.color,
    this.text2,
  });
  final String text;
  final String? text2;
  final String assest;
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
            child: const Icon(Icons.fingerprint_rounded),
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
                size: 15.5.r,
                color: const Color(0xffBCBCBC),
              )
        ],
      ),
    );
  }
}
