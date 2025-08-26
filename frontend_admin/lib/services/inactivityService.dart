import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend_admin/controller/user_contoller.dart';
import 'package:get/get.dart';

class InactivityService with WidgetsBindingObserver {
  static final InactivityService _instance = InactivityService._internal();
  factory InactivityService() => _instance;
  InactivityService._internal();
  final UserController userController = Get.find();

  Timer? _inactivityTimer;
  final Duration timeoutDuration = const Duration(minutes: 5);

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
    _resetTimer();
  }

  void _resetTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(timeoutDuration, _onInactivityTimeout);
  }

  void _onInactivityTimeout() {
    userController.connectWebSocket();
  }

  void userInteractionDetected() {
    _resetTimer();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _inactivityTimer?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _resetTimer();
    }
  }
}
