import 'package:flutter/material.dart';

class CanteenCraveApp extends StatelessWidget {
  const CanteenCraveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Canteen Crave',
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: Center(child: Text('Canteen Crave — setup OK')),
      ),
    );
  }
}
