import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map _ringtone;


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Ringtone player'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8),
                child: RaisedButton(
                  child: const Text('playAlarm'),
                  onPressed: () {
                    FlutterRingtonePlayer.playAlarm();
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: RaisedButton(
                  child: const Text('playAlarm asAlarm: false'),
                  onPressed: () {
                    FlutterRingtonePlayer.playAlarm(asAlarm: false);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: RaisedButton(
                  child: const Text('playNotification'),
                  onPressed: () {
                    FlutterRingtonePlayer.playNotification();
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: RaisedButton(
                  child: const Text('playRingtone'),
                  onPressed: () {
                    FlutterRingtonePlayer.playRingtone();
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: RaisedButton(
                  child: const Text('play'),
                  onPressed: () {
                    FlutterRingtonePlayer.play(
                      android: AndroidSounds.notification,
                      ios: IosSounds.glass,
                      looping: true,
                      volume: 1.0,
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: RaisedButton(
                  child: const Text('stop'),
                  onPressed: () {
                    FlutterRingtonePlayer.stop();
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: RaisedButton(
                  child: const Text('loadRingtone'),
                  onPressed: () async {
                    _ringtone = await FlutterRingtonePlayer.loadRingtone();
                    print("加载铃声: $_ringtone");
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: RaisedButton(
                  child: const Text('playSystemRingtone'),
                  onPressed: () async {
                    if (null != _ringtone) {
                      var ring = _ringtone.entries.first;
                      FlutterRingtonePlayer.playSystemRingtone(ring.value);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
