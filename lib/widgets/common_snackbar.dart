import 'package:crud_authentication_task/core/constant/app_variable.dart';
import 'package:flutter/material.dart';

showSnackBar({
  String message = '',
  bool isSuccess = false,
  BuildContext? context,
}) {
  if (rootScaffoldMessengerKey.currentState != null) {
    try {
      if (context == null) {
        rootScaffoldMessengerKey.currentState!
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              backgroundColor: isSuccess ? Colors.green : Colors.red,
              elevation: 15,
              content: Text(
                message,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
      } else {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              backgroundColor: isSuccess ? Colors.green : Colors.red,
              elevation: 15,
              content: Text(
                message,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
      }
    } catch (e) {
      print(e);
    }
  }
}
