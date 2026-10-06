import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'src/app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init notice (running in demo-ready mode): $e');
  }
  runApp(const CanteenCraveApp());
}
