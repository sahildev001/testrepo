import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alarm_app/model/alarm.dart';
import 'package:flutter_alarm_app/provider/alarm_list_provider.dart';
import 'package:flutter_alarm_app/provider/permission_provider.dart';
import 'package:flutter_alarm_app/service/alarm_file_handler.dart';
import 'package:flutter_alarm_app/service/alarm_polling_worker.dart';
import 'package:flutter_alarm_app/provider/alarm_state.dart';
import 'package:flutter_alarm_app/view/alarm_observer.dart';
import 'package:flutter_alarm_app/view/home_screen.dart';
import 'package:flutter_alarm_app/view/permission_request_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AndroidAlarmManager.initialize();

  final AlarmState alarmState = AlarmState();
  final List<Alarm> alarms = await AlarmFileHandler().read() ?? [];
  final SharedPreferences preference = await SharedPreferences.getInstance();

  AlarmPollingWorker().createPollingWorker(alarmState);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => alarmState),
      ChangeNotifierProvider(create: (context) => AlarmListProvider(alarms)),
      ChangeNotifierProvider(
        create: (context) => PermissionProvider(preference),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alarm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const PermissionRequestScreen(
        child: AlarmObserver(
          child: HomeScreen(),
        ),
      ),
    );
  }
}
