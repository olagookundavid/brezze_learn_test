import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthApi {
  static final _auth = LocalAuthentication();

  static Future<bool> hasBiometrics() async {
    try {
      final can = await _auth.canCheckBiometrics;
      return can;
    } on PlatformException {
      return false;
    }
  }

  static Future<List<BiometricType>> getBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return <BiometricType>[];
    }
  }

  static Future<bool> authenticate() async {
    final isAvailable = await hasBiometrics();
    if (isAvailable) {
      try {
        return await _auth.authenticate(
            localizedReason: "Scan Fingerprint or Face ID to authenticate",
            options: const AuthenticationOptions(biometricOnly: true));
      } on PlatformException {
        return false;
      }
    } else {
      return false;
    }
  }

  static Future<bool> hasFingerprint() async {
    final biometrics = await LocalAuthApi.getBiometrics();
    if (biometrics.isNotEmpty) {
      for (var item in biometrics) {
        return biometrics.contains(item);
      }
    }
    return false;
  }
}
