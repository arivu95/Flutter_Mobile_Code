import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';

class CallTone {
  AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();
  // static CallTone? _instance;
  // init() {
  //   audioPlayer.open(
  //     Audio('assets/caller_tune.mp3'),
  //     autoStart: false,
  //     showNotification: false,
  //     loopMode: LoopMode.single,
  //     volume: 0.2,
  //     //respectSilentMode: true
  //   );
  // }
  // CallTone._internal() {
  //   audioPlayer.open(
  //     Audio('assets/caller_tune.mp3'),
  //     autoStart: false,
  //     showNotification: false,
  //     loopMode: LoopMode.single,
  //     volume: 0.2,
  //     //respectSilentMode: true
  //   );
  // }

  // static CallTone _getInstance() {
  //   return _instance ??= CallTone._internal();
  // }

  CallTone() {
    audioPlayer.open(
      Audio('assets/caller_tune.mp3'),
      autoStart: false,
      showNotification: false,
      loopMode: LoopMode.single,
      volume: 0.2,
      //respectSilentMode: true
    );
  }

  Future<void> dial_play() async {
    audioPlayer.stop();
    audioPlayer.play();
  }

  Future<void> dial_stop() async {
    audioPlayer.stop();
  }
}
