import 'dart:async';
import 'package:crud_authentication_task/core/utils/responsive_utils.dart';
import 'package:crud_authentication_task/modules/auth/providers/auth_provider.dart';
import 'package:crud_authentication_task/modules/auth/views/signup_screen.dart';
import 'package:crud_authentication_task/modules/home/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Consumer<AuthProvider>(
        builder: (context, auth, child) {
          return (auth.user != null || auth.isAuthenticated)
              ? HomeScreen()
              : SignupScreen();
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          "assets/splash.jpg",
          height: ScreenUtil.scaledHeight(context, 80),
          width: ScreenUtil.scaledWidth(context, 80),
        ),
      ),
    );
  }
}
