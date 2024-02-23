import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class AlertFlushbar {
  static void showNotification({
    required BuildContext context,
    bool isWarning = false,
    String message = '',
  }) {
    Flushbar(
      maxWidth: MediaQuery.of(context).size.width * 0.7,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      backgroundColor: isWarning ? Colors.red : Theme.of(context).primaryColor,
      isDismissible: true,
      duration: const Duration(seconds: 4),
      showProgressIndicator: false,
      boxShadows: [
        BoxShadow(
          color: Colors.blue.withOpacity(0.5),
          offset: const Offset(0.0, 2.0),
          blurRadius: 3.0,
        ),
      ],
      icon: isWarning
          ? Container(
              margin: const EdgeInsets.only(left: 10),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  color: Colors.transparent,
                  shape: BoxShape.circle),
              child: const Icon(
                Icons.close,
                color: Colors.white,
              ),
            )
          : const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
            ),
      message: message,
      messageColor: Colors.white,
      messageSize: 18,
    ).show(context);
  }
}
