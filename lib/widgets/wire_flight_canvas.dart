import 'dart:math';
import 'package:flutter/material.dart';
import '../models/file_packet.dart';
import '../theme/cyberpunk_theme.dart';

class WireFlightCanvas extends StatefulWidget {
  final List<FilePacket> inFlightPackets;
  final Function(FilePacket) onPacketSelected;
  final double progress;
  final bool isTransferring;
  final int senderCount;
  final int receiverCount;

  const WireFlightCanvas({
    super.key,
    required this.inFlightPackets,
    required this.onPacketSelected,
    required this.progress,
    required this.isTransferring,
    required this.senderCount,
    required this.receiverCount,
  });

  @override
  State<WireFlightCanvas> createState() => _WireFlightCanvasState();
}

class _WireFlightCanvasState extends State<WireFlightCanvas>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: CyberpunkTheme.glowBox(
              glowColor: CyberpunkTheme.neonCyan,
              bgColor: CyberpunkTheme.surface.withValues(alpha: 0.85),
            ),
            child: Stack(
              children: [
                // Custom Painter for Glowing Wire & Traveling Packets
                CustomPaint(
                  size: Size.infinite,
                  painter: _WireFlightPainter(
                    inFlightPackets: widget.inFlightPackets,
                    pulseValue: _pulseController.value,
                    isTransferring: widget.isTransferring,
                  ),
                ),
                // Left Node: Sender HUD
                Positioned(
                  left: 20,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _buildNodeHud(
                      title: "TX SENDER",
                      subtitle: "127.0.0.1:9000",
                      countText: "${widget.senderCount} Sent",
                      color: CyberpunkTheme.neonCyan,
                      isLeft: true,
                    ),
                  ),
                ),
                // Right Node: Receiver HUD
                Positioned(
                  right: 20,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _buildNodeHud(
                      title: "RX RECEIVER",
                      subtitle: "192.168.1.100:9000",
                      countText: "${widget.receiverCount} Received",
                      color: CyberpunkTheme.neonGreen,
                      isLeft: false,
                    ),
                  ),
                ),
                // Wire Stats Overlay Banner
                Positioned(
                  top: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: CyberpunkTheme.surfaceElevated.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: CyberpunkTheme.surfaceBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.isTransferring
                                  ? CyberpunkTheme.neonGreen
                                  : CyberpunkTheme.textMuted,
                              boxShadow: widget.isTransferring
                                  ? [
                                      const BoxShadow(
                                        color: CyberpunkTheme.neonGreen,
                                        blurRadius: 6,
                                      )
                                    ]
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.isTransferring
                                ? "LIVE HIGH-SPEED BITSTREAM FLIGHT (MTU 1500 BYTES)"
                                : "STANDBY // READY FOR TRANSMISSION",
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                              color: CyberpunkTheme.textMain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNodeHud({
    required String title,
    required String subtitle,
    required String countText,
    required Color color,
    required bool isLeft,
  }) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: CyberpunkTheme.surfaceElevated.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 8.5,
              color: CyberpunkTheme.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              countText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WireFlightPainter extends CustomPainter {
  final List<FilePacket> inFlightPackets;
  final double pulseValue;
  final bool isTransferring;

  _WireFlightPainter({
    required this.inFlightPackets,
    required this.pulseValue,
    required this.isTransferring,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final startX = 170.0;
    final endX = size.width - 170.0;
    final centerY = size.height / 2;

    if (endX <= startX) return;

    // 1. Draw glowing background grid lines
    final gridPaint = Paint()
      ..color = CyberpunkTheme.surfaceBorder.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Main Transmission Wire
    final wireGlow = Paint()
      ..color = CyberpunkTheme.neonCyan.withValues(alpha: 0.15)
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(startX, centerY), Offset(endX, centerY), wireGlow);

    final wireCore = Paint()
      ..color = CyberpunkTheme.neonCyan.withValues(alpha: 0.5)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(startX, centerY), Offset(endX, centerY), wireCore);

    // 3. Pulse Waves traveling along the wire
    if (isTransferring) {
      for (int i = 0; i < 3; i++) {
        final offsetFraction = ((pulseValue + (i * 0.33)) % 1.0);
        final pulseX = startX + (endX - startX) * offsetFraction;
        final pulsePaint = Paint()
          ..color = CyberpunkTheme.neonCyan.withValues(alpha: (1.0 - offsetFraction) * 0.7)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
        canvas.drawCircle(Offset(pulseX, centerY), 4, pulsePaint);
      }
    }

    // 4. Render In-Flight Flying Packets
    for (final packet in inFlightPackets) {
      final currentX = startX + (endX - startX) * packet.inFlightProgress;
      // Slight vertical sine bounce for dynamic motion
      final bounceY = centerY + sin(packet.inFlightProgress * pi * 4) * 8;

      final isCorrupted = packet.isCorruptedSimulated;
      final color = isCorrupted
          ? CyberpunkTheme.neonRed
          : (packet.status == PacketStatus.retransmitting
              ? CyberpunkTheme.neonAmber
              : CyberpunkTheme.neonCyan);

      // Packet Glow Tail
      final tailPaint = Paint()
        ..shader = LinearGradient(
          colors: [color.withValues(alpha: 0.0), color.withValues(alpha: 0.6)],
        ).createShader(Rect.fromPoints(
          Offset(currentX - 25, bounceY),
          Offset(currentX, bounceY),
        ))
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(currentX - 25, bounceY), Offset(currentX, bounceY), tailPaint);

      // Packet Glowing Orb
      final orbGlow = Paint()
        ..color = color.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(currentX, bounceY), 9, orbGlow);

      final orbCore = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(currentX, bounceY), 5, orbCore);

      // Draw Sequence ID label above packet
      final textPainter = TextPainter(
        text: TextSpan(
          text: "#${packet.sequenceId}",
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(currentX - textPainter.width / 2, bounceY - 18));
    }
  }

  @override
  bool shouldRepaint(covariant _WireFlightPainter oldDelegate) {
    return true;
  }
}
