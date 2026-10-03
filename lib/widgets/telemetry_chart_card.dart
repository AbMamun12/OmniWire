import 'package:flutter/material.dart';
import '../services/transfer_controller.dart';
import '../theme/cyberpunk_theme.dart';

class TelemetryChartCard extends StatelessWidget {
  final TransferController controller;

  const TelemetryChartCard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final speed = controller.currentSpeedMBps;
    final ping = controller.currentPingMs;

    return Container(
      padding: const EdgeInsets.all(10),
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
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: CyberpunkTheme.neonCyan,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Flexible(
                      child: Text(
                        "THROUGHPUT SPECTRUM",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.9,
                          color: CyberpunkTheme.neonCyan,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Row(
                children: [
                  Text(
                    "${speed.toStringAsFixed(1)} MB/s",
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: CyberpunkTheme.neonCyan),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${ping}ms",
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: CyberpunkTheme.neonAmber),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _TelemetryChartPainter(
                history: controller.speedHistory,
                isTransferring: controller.isTransferring,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TelemetryChartPainter extends CustomPainter {
  final List<double> history;
  final bool isTransferring;

  _TelemetryChartPainter({
    required this.history,
    required this.isTransferring,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) return;

    // Grid
    final gridPaint = Paint()
      ..color = CyberpunkTheme.surfaceBorder.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    for (double y = 0; y < size.height; y += 15) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final maxVal = history.fold<double>(10.0, (prev, elem) => elem > prev ? elem : prev);
    final points = <Offset>[];
    final stepX = size.width / (history.length - 1);

    for (int i = 0; i < history.length; i++) {
      final x = i * stepX;
      final normalized = (history[i] / maxVal).clamp(0.0, 1.0);
      final y = size.height - (normalized * (size.height - 10)) - 4;
      points.add(Offset(x, y));
    }

    final linePath = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }

    // Gradient fill under curve
    final fillPath = Path.from(linePath)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          CyberpunkTheme.neonCyan.withValues(alpha: 0.25),
          CyberpunkTheme.neonCyan.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Glowing Line
    final lineGlow = Paint()
      ..color = CyberpunkTheme.neonCyan.withValues(alpha: 0.4)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(linePath, lineGlow);

    final lineCore = Paint()
      ..color = CyberpunkTheme.neonCyan
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(linePath, lineCore);

    // Current head point
    final lastPoint = points.last;
    final dotPaint = Paint()..color = CyberpunkTheme.neonGreen;
    canvas.drawCircle(lastPoint, 3.0, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _TelemetryChartPainter oldDelegate) => true;
}
