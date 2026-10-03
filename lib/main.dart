import 'package:flutter/material.dart';
import 'screens/transfer_pro_dashboard.dart';
import 'theme/cyberpunk_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TransferProApp());
}

class TransferProApp extends StatelessWidget {
  const TransferProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transfer Pro — Bitstream & Packet Engine',
      debugShowCheckedModeBanner: false,
      theme: CyberpunkTheme.darkTheme,
      home: const TransferProDashboard(),
    );
  }
}
