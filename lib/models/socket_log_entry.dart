import 'package:flutter/material.dart';
import '../theme/cyberpunk_theme.dart';

enum LogTag {
  rawSocket,
  txEngine,
  cryptoAes,
  wireOut,
  rxIn,
  crcCheck,
  rxAck,
  chaosDrop,
  bitCorrupt,
}

class SocketLogEntry {
  final DateTime timestamp;
  final String tag;
  final String message;
  final Color color;

  SocketLogEntry({
    required this.timestamp,
    required this.tag,
    required this.message,
    required this.color,
  });

  String get formattedTime {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    final s = timestamp.second.toString().padLeft(2, '0');
    final ms = timestamp.millisecond.toString().padLeft(3, '0');
    return "$h:$m:$s.$ms";
  }

  static Color tagColor(String tag) {
    switch (tag) {
      case "RAW_SOCKET":
        return CyberpunkTheme.neonCyan;
      case "TX_ENGINE":
        return CyberpunkTheme.neonBlue;
      case "CRYPTO_AES":
        return CyberpunkTheme.neonPurple;
      case "WIRE_OUT":
        return CyberpunkTheme.neonCyan;
      case "RX_IN":
        return CyberpunkTheme.neonGreen;
      case "CRC_CHECK":
        return CyberpunkTheme.neonGreen;
      case "RX_ACK":
        return CyberpunkTheme.neonAmber;
      case "CHAOS_DROP":
        return CyberpunkTheme.neonRed;
      case "BIT_CORRUPT":
        return CyberpunkTheme.neonRed;
      default:
        return CyberpunkTheme.textMain;
    }
  }
}
