import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lifetech/pages/homepage.dart';
import 'package:lifetech/pages/register.dart';
import 'package:lifetech/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lifetech/services/auth_page.dart';

final FlutterLocalNotificationsPlugin flutterLocalPlugin = FlutterLocalNotificationsPlugin();
const AndroidNotificationChannel notificationChannel =
    AndroidNotificationChannel("Lifetech", "Lifetech", description: "", importance: Importance.high);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initservice();
  runApp(const MyApp());
}

Future<void> initservice() async {
  var service = FlutterBackgroundService();
  if (Platform.isIOS) {
    await flutterLocalPlugin.initialize(const InitializationSettings(iOS: DarwinInitializationSettings()));
  }
  await flutterLocalPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(notificationChannel);
  await service.configure(
      iosConfiguration: IosConfiguration(onBackground: iosBackground, onForeground: onStart),
      androidConfiguration: AndroidConfiguration(
          onStart: onStart,
          autoStart: true,
          isForegroundMode: true,
          notificationChannelId: "Lifetech",
          initialNotificationTitle: "Lifetech Arkaplanda Çalışıyor",
          initialNotificationContent: "Lifetech Hep Yanınızda 💚",
          foregroundServiceNotificationId: 90));
  service.startService();
}

@pragma("vm:entry-point")
void onStart(ServiceInstance service) {
  /*DartPluginRegistrant.ensureInitialized();*/

  service.on("setAsForeground").listen((event) {
    print("foreground ==============================");
  });
  service.on("setAsBackground").listen((event) {
    print("background ==============================");
  });
  service.on("stopService").listen((event) {
    service.stopSelf();
  });


  const NotificationDetails(
    android: AndroidNotificationDetails(
      "Lifetech Arkaplanda Çalışıyor",
      "Lifetech Hep Yanınızda 💚",
      ongoing: true,
      icon: "app_icon",
    ),
  );
}

@pragma("vm:entry-point")
Future<bool> iosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lifetech',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff87D793)),
        useMaterial3: true,
      ),
      home: const CheckUserLoggedInOrNot(),
    );
  }
}

class CheckUserLoggedInOrNot extends StatefulWidget {
  const CheckUserLoggedInOrNot({super.key});

  @override
  State<CheckUserLoggedInOrNot> createState() => _CheckUserLoggedInOrNotState();
}

class _CheckUserLoggedInOrNotState extends State<CheckUserLoggedInOrNot> {
  @override
  void initState() {
    AuthService.isLoggedIn().then((value) {
      if (value) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
