import 'dart:math';
import 'package:flutter/material.dart';
import '../models/file_packet.dart';
import '../theme/cyberpunk_theme.dart';

class BitMatrixStreamWidget extends StatefulWidget {
  final FilePacket? activePacket;
  final bool isTransferring;

  const BitMatrixStreamWidget({
    super.key,
    required this.activePacket,
    required this.isTransferring,
  });

  @override
  State<BitMatrixStreamWidget> createState() => _BitMatrixStreamWidgetState();
}

class _BitMatrixStreamWidgetState extends State<BitMatrixStreamWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _scrollController;
  final List<String> _rainColumns = [];
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _scrollController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    for (int i = 0; i < 20; i++) {
      _rainColumns.add(_generateRandomBits(16));
    }
  }

  String _generateRandomBits(int count) {
    final buffer = StringBuffer();
    for (int i = 0; i < count; i++) {
      buffer.write(_rng.nextBool() ? '1' : '0');
    }
    return buffer.toString();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final packet = widget.activePacket;
    final bytes = packet?.rawBytes ?? [];
    final sampleLimit = bytes.length < 16 ? bytes.length : 16;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: CyberpunkTheme.glowBox(
        glowColor: CyberpunkTheme.neonGreen,
        bgColor: CyberpunkTheme.surfaceElevated,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
                        color: CyberpunkTheme.neonGreen,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        "BITSTREAM DECODER",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          color: CyberpunkTheme.neonGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                packet != null ? "#${packet.sequenceId}" : "IDLE",
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: CyberpunkTheme.neonCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: CyberpunkTheme.surfaceBorder, height: 1),
          const SizedBox(height: 8),

          // Bit rows with live decoded character and hex
          Expanded(
            child: sampleLimit == 0
                ? const Center(
                    child: Text(
                      "NO ACTIVE PACKET STREAMING",
                      style: TextStyle(fontSize: 11, color: CyberpunkTheme.textDim),
                    ),
                  )
                : ListView.builder(
                    itemCount: sampleLimit,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final byte = bytes[index];
                      final binary = byte.toRadixString(2).padLeft(8, '0');
                      final hex = byte.toRadixString(16).padLeft(2, '0').toUpperCase();
                      final asciiChar = (byte >= 32 && byte <= 126) ? String.fromCharCode(byte) : '·';

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          children: [
                            // Offset index
                            SizedBox(
                              width: 32,
                              child: Text(
                                "+${index.toString().padLeft(2, '0')}",
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: CyberpunkTheme.textDim,
                                ),
                              ),
                            ),
                            // Hex representation
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: CyberpunkTheme.surfaceBorder.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                "0x$hex",
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: CyberpunkTheme.neonCyan,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // ASCII Char
                            SizedBox(
                              width: 18,
                              child: Text(
                                "[$asciiChar]",
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: CyberpunkTheme.neonAmber,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // 8-bit stream with color coded bits (1 = green, 0 = dim)
                            Expanded(
                              child: Row(
                                children: List.generate(8, (bIndex) {
                                  final isOne = binary[bIndex] == '1';
                                  return Container(
                                    margin: const EdgeInsets.only(right: 3),
                                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: isOne
                                          ? CyberpunkTheme.neonGreen.withValues(alpha: 0.2)
                                          : CyberpunkTheme.surface,
                                      borderRadius: BorderRadius.circular(2),
                                      border: Border.all(
                                        color: isOne
                                            ? CyberpunkTheme.neonGreen.withValues(alpha: 0.6)
                                            : CyberpunkTheme.surfaceBorder,
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      binary[bIndex],
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: isOne ? FontWeight.bold : FontWeight.normal,
                                        color: isOne ? CyberpunkTheme.neonGreen : CyberpunkTheme.textDim,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
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
