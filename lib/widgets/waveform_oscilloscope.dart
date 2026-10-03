import 'dart:math';
import 'package:flutter/material.dart';
import '../models/file_packet.dart';
import '../theme/cyberpunk_theme.dart';

class WaveformOscilloscopeWidget extends StatefulWidget {
  final FilePacket? activePacket;
  final bool isTransferring;

  const WaveformOscilloscopeWidget({
    super.key,
    required this.activePacket,
    required this.isTransferring,
  });

  @override
  State<WaveformOscilloscopeWidget> createState() => _WaveformOscilloscopeWidgetState();
}

class _WaveformOscilloscopeWidgetState extends State<WaveformOscilloscopeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _sweepController;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: CyberpunkTheme.glowBox(
        glowColor: CyberpunkTheme.neonCyan,
        bgColor: CyberpunkTheme.surfaceElevated,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: CyberpunkTheme.neonCyan,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        "OSCILLOSCOPE // SIGNAL MODULATION (NRZ-L)",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          color: CyberpunkTheme.neonCyan,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "0V - 5.0V",
                style: TextStyle(
                  fontSize: 10,
                  color: CyberpunkTheme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: AnimatedBuilder(
              animation: _sweepController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: _OscilloscopePainter(
                    packet: widget.activePacket,
                    sweepValue: _sweepController.value,
                    isTransferring: widget.isTransferring,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OscilloscopePainter extends CustomPainter {
  final FilePacket? packet;
  final double sweepValue;
  final bool isTransferring;

  _OscilloscopePainter({
    required this.packet,
    required this.sweepValue,
    required this.isTransferring,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Grid
    final gridPaint = Paint()
      ..color = CyberpunkTheme.surfaceBorder.withValues(alpha: 0.4)
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final topY = 20.0;
    final bottomY = size.height - 20.0;
    final midY = (topY + bottomY) / 2;

    // Draw reference voltage horizontal lines
    final refPaint = Paint()
      ..color = CyberpunkTheme.textDim.withValues(alpha: 0.5)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, topY), Offset(size.width, topY), refPaint);
    canvas.drawLine(Offset(0, midY), Offset(size.width, midY), refPaint);
    canvas.drawLine(Offset(0, bottomY), Offset(size.width, bottomY), refPaint);

    // Draw Labels (+5V, 0V)
    final labelPainter = TextPainter(
      text: const TextSpan(
        text: "+5.0V [BIT 1]",
        style: TextStyle(color: CyberpunkTheme.neonGreen, fontSize: 8),
      ),
      textDirection: TextDirection.ltr,
    );
    labelPainter.layout();
    labelPainter.paint(canvas, const Offset(6, 6));

    final labelZero = TextPainter(
      text: const TextSpan(
        text: " 0.0V [BIT 0]",
        style: TextStyle(color: CyberpunkTheme.textMuted, fontSize: 8),
      ),
      textDirection: TextDirection.ltr,
    );
    labelZero.layout();
    labelZero.paint(canvas, Offset(6, bottomY + 4));

    // 2. Square Waveform from actual bits
    final bytes = packet?.rawBytes ?? [72, 101, 108, 108, 111];
    final bitList = <bool>[];
    for (int i = 0; i < min(bytes.length, 6); i++) {
      final b = bytes[i];
      for (int bit = 7; bit >= 0; bit--) {
        bitList.add(((b >> bit) & 1) == 1);
      }
    }

    if (bitList.isEmpty) return;

    final bitWidth = size.width / bitList.length;
    final wavePath = Path();
    wavePath.moveTo(0, bitList[0] ? topY : bottomY);

    for (int i = 0; i < bitList.length; i++) {
      final currentY = bitList[i] ? topY : bottomY;
      final startX = i * bitWidth;
      final endX = (i + 1) * bitWidth;

      // Vertical edge transition
      wavePath.lineTo(startX, currentY);
      // Horizontal signal duration
      wavePath.lineTo(endX, currentY);
    }

    // Glow waveform
    final waveGlow = Paint()
      ..color = CyberpunkTheme.neonCyan.withValues(alpha: 0.3)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.miter;
    canvas.drawPath(wavePath, waveGlow);

    // Sharp core waveform
    final waveCore = Paint()
      ..color = CyberpunkTheme.neonCyan
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(wavePath, waveCore);

    // 3. Oscilloscope sweep beam
    if (isTransferring) {
      final sweepX = size.width * sweepValue;
      final sweepPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            CyberpunkTheme.neonGreen.withValues(alpha: 0.0),
            CyberpunkTheme.neonGreen.withValues(alpha: 0.5),
          ],
        ).createShader(Rect.fromLTWH(sweepX - 30, 0, 30, size.height))
        ..style = PaintingStyle.fill;

      canvas.drawRect(Rect.fromLTWH(sweepX - 30, 0, 30, size.height), sweepPaint);

      final linePaint = Paint()
        ..color = CyberpunkTheme.neonGreen
        ..strokeWidth = 1.5;
      canvas.drawLine(Offset(sweepX, 0), Offset(sweepX, size.height), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OscilloscopePainter oldDelegate) {
    return true;
  }
}
