import 'dart:async';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:lifetech/pages/profile_page.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'FAQ_Page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Color buttonColor = Colors.green;
  final stt.SpeechToText _speech = stt.SpeechToText();
  double _gyroX = 0.0;
  double _gyroY = 0.0;
  double _gyroZ = 0.0;
  int _alertCount = 0;
  late StreamSubscription<GyroscopeEvent> gyroscopeSubscription;
  FlutterTts flutterTts = FlutterTts();
  bool _isDialogOpen = false;
  final FlutterLocalNotificationsPlugin flutterLocalPlugin = FlutterLocalNotificationsPlugin();
  AndroidNotificationChannel notificationChannel = const AndroidNotificationChannel("Lifetech", "Lifetech",
      description: "Lifetech Bildirimleri", importance: Importance.high);

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _initializeNotifications();
    _speech.initialize().then((_) {
      if (_speech.isAvailable) {
        _startListening();
      }
    });
    gyroscopeSubscription = gyroscopeEventStream().listen((GyroscopeEvent event) {
      setState(() {
        _gyroX = event.x;
        _gyroY = event.y;
        _gyroZ = event.z;
      });

      if (_gyroX.abs() > 10 || _gyroY.abs() > 10 || _gyroZ.abs() > 10) {
        _showAlert('İyi misin? Bir sorun var mı?');
        _startListening();
      }
    });
  }

  Future<bool> _requestPermission() async {
    var phoneStatus = await Permission.phone.status;
    var ignoreBatteryOptimizationStatus = await Permission.ignoreBatteryOptimizations.status;
    var locationAlwaysStatus = await Permission.locationAlways.status;
    var locationStatus = await Permission.location.status;
    var microphoneStatus = await Permission.microphone.status;

    if (!phoneStatus.isGranted) {
      await Permission.phone.request();
    }

    if (!ignoreBatteryOptimizationStatus.isGranted) {
      await Permission.ignoreBatteryOptimizations.request();
      if (!(await Permission.ignoreBatteryOptimizations.status).isGranted) {
        AppSettings.openAppSettings(type: AppSettingsType.batteryOptimization);
        return false;
      }
    }

    if (!locationAlwaysStatus.isGranted) {
      await Permission.locationAlways.request();
      if (!(await Permission.locationAlways.status).isGranted) {
        /*AppSettings.openAppSettings(type: AppSettingsType.location);*/
        return false;
      }
    }

    if (!locationStatus.isGranted) {
      await Permission.location.request();
      if (!(await Permission.location.status).isGranted) {
        /*AppSettings.openAppSettings(type: AppSettingsType.location);*/
        return false;
      }
    }
    if (!microphoneStatus.isGranted) {
      await Permission.microphone.request();
    }

    return true;
  }

  void _startListening() async {
    await Future.delayed(const Duration(seconds: 3));
    try {
      var microphoneStatus = await _requestPermission();
      if (microphoneStatus) {
        _speech.listen(
          onResult: (result) {
            print(result.recognizedWords);
            print(result.finalResult);
            if (result.finalResult) {
              if (result.recognizedWords.toLowerCase() == 'iyiyim') {
                Navigator.of(context).popUntil((route) => route.isFirst);
                _alertCount = 0;
                _stopListening();
              }
            }
          },
        );
      } else {
        print("İzinler sağlanamadı.");
      }
    } catch (error) {
      print('Sesli komut dinleme hatası: $error');
    }
  }
  void _stopListening() {
    _speech.stop();
  }
  @override
  void dispose() {
    super.dispose();
    _speech.stop();
    gyroscopeSubscription.cancel();
  }
  void _showConfirmationButton() {
    _isDialogOpen = true;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İyi Misin ?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              _isDialogOpen = false;
              Navigator.of(context).popUntil((route) => route.isFirst);
              _alertCount = 0;
            },
            child: const Text('İyiyim'),
          ),
        ],
      ),
    ).then((value) {
      if (!_isDialogOpen) {
        _alertCount = 0;
      }
    });
  }

  Future<void> _showAlert(String message) async {
    _alertCount++;
    if (_alertCount <= 2) {
      await flutterTts.speak(message);
      _showConfirmationButton();
      _triggerVibration();
      _showNotification(message);
    } else {
      _callEmergency();
    }
  }
  void _callEmergency() async {
    var status = await Permission.phone.status;
    if (status.isGranted) {
      await FlutterPhoneDirectCaller.callNumber('542');
    } else {
      print('Arama izni verilmedi!');
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
    _alertCount = 0;
  }
  Future<void> _showNotification(String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails("Lifetech", "Lifetech", importance: Importance.high);
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalPlugin.show(
      0,
      'Lifetech Bildirim',
      message,
      platformChannelSpecifics,
      payload: 'Bildirim Payload',
    );
  }
  void _triggerVibration() {
    Vibration.vibrate(duration: 1500);
  }
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalPlugin.initialize(initializationSettings);
    await flutterLocalPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(notificationChannel);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lifetech"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
              },
              icon: Icon(
                Icons.person,
                size: size.width*0.08,
              ))
        ],
      ),
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.green],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    buttonColor = buttonColor == Colors.green ? Colors.blueGrey : Colors.green;
                  });
                  if (buttonColor == Colors.blueGrey) {
                    FlutterBackgroundService().invoke("stopService");
                    gyroscopeSubscription.cancel();
                  } else {
                    FlutterBackgroundService().startService();
                    gyroscopeEventStream().listen((GyroscopeEvent event) {
                      setState(() {
                        _gyroX = event.x;
                        _gyroY = event.y;
                        _gyroZ = event.z;
                      });

                      if (_gyroX.abs() > 10 || _gyroY.abs() > 10 || _gyroZ.abs() > 10) {
                        _showAlert('İyi misin? Bir sorun var mı?');
                        _startListening();
                      }
                    });
                  }
                },
                child: Container(
                  decoration: BoxDecoration(color: buttonColor, borderRadius: BorderRadius.circular(50)),
                  width: size.width * 0.85,
                  height: 100,
                  child: const Center(
                    child: Text("Aktiflik Durumu", style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ),
              ),
              SizedBox(height: size.height * 20 / 896,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      launchUrl(emailLaunchUri);
                    },
                    child: Container(
                      decoration: BoxDecoration(color: Colors.blueGrey, borderRadius: BorderRadius.circular(50)),
                      width: size.width * 0.4,
                      height: 100,
                      child: const Center(
                        child: Text(
                          'Destek',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const FAQPage()));
                    },
                    child: Container(
                      decoration: BoxDecoration(color: Colors.blueGrey, borderRadius: BorderRadius.circular(50)),
                      width: size.width * 0.4,
                      height: 100,
                      child: const Center(
                        child: Text(
                          'Sıkça Sorulan Sorular',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: 'lifetechtechnologies@gmail.com',
  );
}
