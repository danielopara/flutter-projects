import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

abstract final class CDeviceUtils {
  // --- Keyboard ---
  static void hideKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

  static bool get isKeyboardOpen => Get.mediaQuery.viewInsets.bottom > 0;

  // --- Snackbar ---
  static void showSnackBar(String message) {
    ScaffoldMessenger.of(Get.context!)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // --- Status bar ---
  static void setStatusBarStyle({
    Color color = Colors.transparent,
    Brightness iconBrightness = Brightness.dark,
  }) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: color,
        statusBarIconBrightness: iconBrightness, // Android
        statusBarBrightness: iconBrightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark, // iOS (inverted meaning)
      ),
    );
  }

  static void hideStatusBar() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom],
    );
  }

  static void showStatusBar() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  static void setFullScreen(bool enable) {
    SystemChrome.setEnabledSystemUIMode(
      enable ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  static double get statusBarHeight => Get.mediaQuery.padding.top;

  // --- Screen ---
  static double get screenHeight => Get.height;
  static double get screenWidth => Get.width;
  static double get pixelRatio => Get.pixelRatio;

  static bool get isPortrait =>
      Get.mediaQuery.orientation == Orientation.portrait;
  static bool get isLandscape =>
      Get.mediaQuery.orientation == Orientation.landscape;

  static Future<void> setPreferredOrientations(
    List<DeviceOrientation> orientations,
  ) => SystemChrome.setPreferredOrientations(orientations);

  // --- Platform ---
  static bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;
  static bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;

  static Future<bool> isPhysicalDevice() async {
    final info = DeviceInfoPlugin();
    if (isAndroid) return (await info.androidInfo).isPhysicalDevice;
    if (isIOS) return (await info.iosInfo).isPhysicalDevice;
    return true;
  }

  // --- Internet ---
  static Future<bool> hasInternetConnection() async {
    final results = await Connectivity().checkConnectivity();
    if (results.contains(ConnectivityResult.none)) return false;
    try {
      final lookup = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // --- Vibration ---
  static void vibrate() => HapticFeedback.vibrate();
  static void lightHaptic() => HapticFeedback.lightImpact();
  static void mediumHaptic() => HapticFeedback.mediumImpact();

  // --- URLs ---
  static Future<bool> openUrl(String url) async {
    try {
      return await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      return false;
    }
  }
}
