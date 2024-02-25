import 'package:brezze_learn_test/pages/home_page.dart';
import 'package:brezze_learn_test/pages/profile_page.dart';
import 'package:brezze_learn_test/pages/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  LandingPageState createState() => LandingPageState();
}

class LandingPageState extends State<LandingPage> {
  var currentIndex = 0;

  List<IconData> listOfIcons = [
    Icons.home_rounded,
    Icons.person_2_rounded,
    Icons.settings,
  ];

  List<String> listOfStrings = ['Home', 'Profile', 'Settings'];

  List screens = [
    const HomePage(),
    const ProfilePage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: screens[currentIndex],
          ),
          Padding(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height - 100.h),
            child: Container(
              margin: EdgeInsets.all(displayWidth * .05),
              height: displayWidth * .155,
              decoration: BoxDecoration(
                color: Colors.black,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
                borderRadius: BorderRadius.circular(50),
              ),
              child: ListView.builder(
                itemCount: 3,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: displayWidth * .02),
                itemBuilder: (context, index) => InkWell(
                  onTap: () {
                    setState(() {
                      currentIndex = index;
                      HapticFeedback.lightImpact();
                    });
                  },
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Stack(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(seconds: 1),
                        curve: Curves.fastLinearToSlowEaseIn,
                        width: index == currentIndex
                            ? displayWidth * .35
                            : displayWidth * .25,
                        alignment: Alignment.center,
                        child: AnimatedContainer(
                          duration: const Duration(seconds: 1),
                          curve: Curves.fastLinearToSlowEaseIn,
                          height:
                              index == currentIndex ? displayWidth * .12 : 0,
                          width: index == currentIndex ? displayWidth * .35 : 0,
                          decoration: BoxDecoration(
                            color: index == currentIndex
                                ? Colors.white.withOpacity(.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(seconds: 1),
                        curve: Curves.fastLinearToSlowEaseIn,
                        width: index == currentIndex
                            ? displayWidth * .31
                            : displayWidth * .18,
                        alignment: Alignment.center,
                        child: Stack(
                          children: [
                            Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.fastLinearToSlowEaseIn,
                                  width: index == currentIndex
                                      ? displayWidth * .13
                                      : 0,
                                ),
                                AnimatedOpacity(
                                  opacity: index == currentIndex ? 1 : 0,
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.fastLinearToSlowEaseIn,
                                  child: Text(
                                    index == currentIndex
                                        ? listOfStrings[index]
                                        : '',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.fastLinearToSlowEaseIn,
                                  width: index == currentIndex
                                      ? displayWidth * .03
                                      : 20,
                                ),
                                Icon(
                                  listOfIcons[index],
                                  size: displayWidth * .076,
                                  color: index == currentIndex
                                      ? Colors.white
                                      : const Color(0xffFFFFFF),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
