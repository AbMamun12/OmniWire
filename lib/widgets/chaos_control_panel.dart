import 'package:flutter/material.dart';
import '../services/transfer_controller.dart';
import '../theme/cyberpunk_theme.dart';

class ChaosControlPanel extends StatelessWidget {
  final TransferController controller;

  const ChaosControlPanel({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: CyberpunkTheme.glowBox(
        glowColor: CyberpunkTheme.neonRed,
        bgColor: CyberpunkTheme.surfaceElevated,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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
                        color: CyberpunkTheme.neonRed,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Flexible(
                      child: Text(
                        "CHAOS LAB",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: CyberpunkTheme.neonRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              // Preset Badges
              Wrap(
                spacing: 4,
                children: [
                  _presetButton("Fiber", 0.0, 0.0, 10),
                  _presetButton("Wi-Fi", 0.08, 0.03, 70),
                  _presetButton("Satellite", 0.20, 0.08, 300),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Row(
              children: [
                // Packet Loss Slider
                Expanded(
                  child: _buildSlider(
                    title: "PACKET LOSS",
                    value: controller.packetLossRate,
                    displayValue: "${(controller.packetLossRate * 100).toInt()}%",
                    min: 0.0,
                    max: 0.30,
                    activeColor: CyberpunkTheme.neonRed,
                    onChanged: (v) => controller.setPacketLossRate(v),
                  ),
                ),
                const SizedBox(width: 8),
                // Bit Flip Slider
                Expanded(
                  child: _buildSlider(
                    title: "BIT FLIP",
                    value: controller.bitFlipRate,
                    displayValue: "${(controller.bitFlipRate * 100).toInt()}%",
                    min: 0.0,
                    max: 0.20,
                    activeColor: CyberpunkTheme.neonAmber,
                    onChanged: (v) => controller.setBitFlipRate(v),
                  ),
                ),
                const SizedBox(width: 8),
                // Latency Slider
                Expanded(
                  child: _buildSlider(
                    title: "RTT PING",
                    value: controller.simulatedLatencyMs.toDouble(),
                    displayValue: "${controller.simulatedLatencyMs}ms",
                    min: 10.0,
                    max: 400.0,
                    activeColor: CyberpunkTheme.neonCyan,
                    onChanged: (v) => controller.setLatency(v.toInt()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _presetButton(String label, double loss, double bitFlip, int latency) {
    return InkWell(
      onTap: () {
        controller.setPacketLossRate(loss);
        controller.setBitFlipRate(bitFlip);
        controller.setLatency(latency);
      },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
        decoration: BoxDecoration(
          color: CyberpunkTheme.surface,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: CyberpunkTheme.surfaceBorder),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 8.5, color: CyberpunkTheme.textMuted),
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String title,
    required double value,
    required String displayValue,
    required double min,
    required double max,
    required Color activeColor,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: CyberpunkTheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: CyberpunkTheme.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: CyberpunkTheme.textMuted),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                displayValue,
                style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: activeColor),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 2.0,
              activeTrackColor: activeColor,
              inactiveTrackColor: CyberpunkTheme.surfaceBorder,
              thumbColor: activeColor,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5.0),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 8.0),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
