import 'package:brezze_learn_test/auth/auth.dart';
import 'package:brezze_learn_test/auth/notifiiers/auth_notifier.dart';
import 'package:brezze_learn_test/helper/storage_class.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  // Firebase initialization
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await Hive.openBox(HiveKeys.appBox);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(ChangeNotifierProvider(
    create: (context) => AuthenticationNotifier(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      useInheritedMediaQuery: true,
      minTextAdapt: true,
      designSize: const Size(375, 812),
      builder: (context, _) => GestureDetector(
          onTap: () {
            unfocus();
          },
          child: GetMaterialApp(
              darkTheme: ThemeData.dark(
                useMaterial3: true,
              ),
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme(
                  brightness: Brightness.light,
                  primary: Colors.deepPurple,
                  onPrimary: Colors.white, // Text on primary color
                  background: Colors.white,
                  onSecondary: Colors.white,
                  error: Colors.red,
                  onBackground: Colors.white,
                  onError: Colors.deepPurple,
                  onSurface: Colors.black, // colors for text fields
                  secondary: Colors.white,
                  surface: Colors.grey.shade200,

                  // colors for widgets
                ),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                primaryColor: Colors.deepPurple,
                fontFamily: GoogleFonts.poppins().fontFamily,
              ),
              debugShowCheckedModeBanner: false,
              title: 'ChatBox',
              home: const AuthPage())),
    );
  }
}

void unfocus() {
  FocusManager.instance.primaryFocus?.unfocus();
}
