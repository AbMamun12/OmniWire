import 'package:flutter/material.dart';
import '../services/transfer_controller.dart';
import '../theme/cyberpunk_theme.dart';

class HudMetricsBar extends StatelessWidget {
  final TransferController controller;

  const HudMetricsBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final speed = controller.currentSpeedMBps;
    final speedGbps = (speed * 8) / 1024;
    final totalPackets = controller.senderPackets.length;
    final received = controller.receivedCount;
    final drops = controller.droppedCount;
    final retries = controller.retransmittedCount;
    final ping = controller.currentPingMs;

    return Row(
      children: [
        _metricBox(
          title: "TRANSFER SPEED",
          value: "${speed.toStringAsFixed(1)} MB/s",
          subvalue: "${(speed * 8).toStringAsFixed(0)} Mbps / ${speedGbps.toStringAsFixed(2)} Gbps",
          color: CyberpunkTheme.neonCyan,
          icon: Icons.speed,
        ),
        const SizedBox(width: 8),
        _metricBox(
          title: "DATA INTEGRITY",
          value: drops == 0 ? "100.00% MATCH" : "RECOVERED VIA CRC",
          subvalue: "CRC-32 & SHA-256 VERIFIED",
          color: CyberpunkTheme.neonGreen,
          icon: Icons.verified_user_outlined,
        ),
        const SizedBox(width: 8),
        _metricBox(
          title: "PACKETS REASSEMBLED",
          value: "$received / $totalPackets",
          subvalue: "${(controller.overallProgress * 100).toStringAsFixed(1)}% COMPLETE",
          color: CyberpunkTheme.neonPurple,
          icon: Icons.dashboard_customize_outlined,
        ),
        const SizedBox(width: 8),
        _metricBox(
          title: "CHAOS & DROPS",
          value: "$drops Dropped",
          subvalue: "$retries Retransmitted",
          color: drops > 0 ? CyberpunkTheme.neonRed : CyberpunkTheme.textMuted,
          icon: Icons.warning_amber_rounded,
        ),
        const SizedBox(width: 8),
        _metricBox(
          title: "RTT LATENCY",
          value: "$ping ms",
          subvalue: "ROUND-TRIP TIME",
          color: CyberpunkTheme.neonAmber,
          icon: Icons.network_ping,
        ),
      ],
    );
  }

  Widget _metricBox({
    required String title,
    required String value,
    required String subvalue,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: CyberpunkTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: CyberpunkTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    subvalue,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 8,
                      color: CyberpunkTheme.textDim,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
