import 'package:flutter/material.dart';
import 'package:flutter_alarm_app/model/alarm.dart';
import 'package:flutter_alarm_app/provider/alarm_state.dart';
import 'package:flutter_alarm_app/service/alarm_scheduler.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({Key? key, required this.alarm}) : super(key: key);

  final Alarm alarm;

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> with WidgetsBindingObserver {
  late AudioPlayer audioPlayer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize AudioPlayer
    audioPlayer = AudioPlayer();

    // Play music
    playMusic();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _dismissAlarm();
        break;
      case AppLifecycleState.resumed:
        playMusic();
        break;
      default:
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    audioPlayer.dispose();
    super.dispose();
  }

  void _dismissAlarm() async {
    final alarmState = context.read<AlarmState>();
    final callbackAlarmId = alarmState.callbackAlarmId!;

    // Alarm callback ID is added by `AlarmScheduler` as day(0), month(1), Tuesday(2), ..., Saturday(6).
    // Therefore, the quotient divided by 7 represents the day of the week.

    final firedAlarmWeekday = callbackAlarmId % 7;
    final nextAlarmTime =
        widget.alarm.timeOfDay.toComingDateTimeAt(firedAlarmWeekday);

    await AlarmScheduler.reschedule(callbackAlarmId, nextAlarmTime);
    stopMusic();
    alarmState.dismiss();
  }

  bool playingStatus = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Alarm Screen',
              style: Theme.of(context).textTheme.headline4,
            ),
            TextButton(
              onPressed: _dismissAlarm,
              child: const Text('Alarm off'),
            ),
          ],
        ),
      ),
    );
  }

  void playMusic() async {
    try {
      await audioPlayer.play(
        AssetSource(
          'audio/Sunflower.mp3',
        ),
      );
      print('Playing Music');

      playingStatus = true;
      setState(() {});
    } catch (e) {
      print('Error: $e');
    }
  }

  void stopMusic() {
    if (playingStatus) {
      audioPlayer.stop();
      print('Music stopped');
    }
  }
}
