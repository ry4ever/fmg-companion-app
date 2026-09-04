import 'package:flutter/material.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unlock Full Access')),
      body: const Center(
        child: Text('Subscribe to unlock My Gym and all features.'),
      ),
    );
  }
}