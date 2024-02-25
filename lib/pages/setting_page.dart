import 'package:brezze_learn_test/helper/storage_class.dart';
import 'package:brezze_learn_test/helper/utils.dart';
import 'package:brezze_learn_test/pages/auth/log_out.dart';
import 'package:brezze_learn_test/widgets/settings_tile.dart';
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
        automaticallyImplyLeading: false,
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
              icon: Icons.fingerprint_rounded,
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
            InkWell(
              onTap: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                  context: context,
                  builder: (context) => Logout(),
                );
              },
              child: const SettingsTiles(
                text: 'LogOut',
                icon: Icons.logout_rounded,
              ),
            )
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
