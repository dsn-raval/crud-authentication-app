import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_authentication_task/core/constant/app_variable.dart';
import 'package:crud_authentication_task/core/theme/app_theme_provider.dart';
import 'package:crud_authentication_task/helpers/firebase_services.dart';
import 'package:crud_authentication_task/modules/home/providers/api_provider.dart';
import 'package:crud_authentication_task/modules/auth/providers/auth_provider.dart';
import 'package:crud_authentication_task/modules/settings/providers/profile_provider.dart';
import 'package:crud_authentication_task/modules/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling background message: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseFirestore.instance.terminate();
  await FirebaseFirestore.instance.clearPersistence();
  await FirebaseAPI.initializeNotifications();
  await FirebaseMessaging.instance.subscribeToTopic("all");
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Hive.initFlutter();
  await Hive.openBox('localData');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => ApiProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crud Authentication',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      scaffoldMessengerKey: rootScaffoldMessengerKey,

      home: SplashScreen(),
    );
  }
}
