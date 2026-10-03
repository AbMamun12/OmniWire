import 'package:flutter/material.dart';
import '../services/crc32_helper.dart';
import '../services/transfer_controller.dart';
import '../theme/cyberpunk_theme.dart';

class BitSniperLogicModal extends StatefulWidget {
  final TransferController controller;

  const BitSniperLogicModal({
    super.key,
    required this.controller,
  });

  static void show(BuildContext context, TransferController controller) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: BitSniperLogicModal(controller: controller),
      ),
    );
  }

  @override
  State<BitSniperLogicModal> createState() => _BitSniperLogicModalState();
}

class _BitSniperLogicModalState extends State<BitSniperLogicModal> {
  int _selectedByte = 0;
  int _selectedBit = 7;
  bool _simulatedAlarm = false;

  @override
  Widget build(BuildContext context) {
    final packet = widget.controller.selectedPacket;
    final bytes = packet?.rawBytes ?? [];
    final byteCount = bytes.length < 16 ? bytes.length : 16;

    final currentByteVal = bytes.isNotEmpty ? bytes[_selectedByte] : 0;
    final currentBitVal = (currentByteVal >> _selectedBit) & 1;

    // Simulated XOR Round Key bit
    final keyBit = (_selectedByte + _selectedBit) % 2;
    final cipherBit = currentBitVal ^ keyBit;

    // CRC status
    final currentCrc = packet != null ? packet.crc32 : 0;
    final hexCrc = Crc32Helper.toHex(currentCrc);

    return Container(
      width: 860,
      height: 580,
      decoration: CyberpunkTheme.glowBox(
        glowColor: CyberpunkTheme.neonAmber,
        bgColor: CyberpunkTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CyberpunkTheme.neonAmber, width: 1.5),
      ),
      child: Column(
        children: [
          // Top Title Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: CyberpunkTheme.surfaceElevated,
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              border: Border(bottom: BorderSide(color: CyberpunkTheme.surfaceBorder)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: CyberpunkTheme.neonAmber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: CyberpunkTheme.neonAmber),
                      ),
                      child: const Text(
                        "SILICON LAB",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: CyberpunkTheme.neonAmber,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "BIT SNIPER & BOOLEAN LOGIC XOR INSPECTOR",
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: CyberpunkTheme.textMain,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: CyberpunkTheme.textMuted, size: 18),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Left Side: Interactive Bitboard Matrix
                  Expanded(
                    flex: 5,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CyberpunkTheme.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: CyberpunkTheme.surfaceBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "INTERACTIVE BITBOARD (CLICK TO FLIP BIT)",
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: CyberpunkTheme.neonCyan,
                                ),
                              ),
                              Text(
                                "PACKET #${packet?.sequenceId ?? 0}",
                                style: const TextStyle(fontSize: 10, color: CyberpunkTheme.textMuted),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Select any bit to test how a 1-bit memory or transmission corruption triggers CRC errors.",
                            style: TextStyle(fontSize: 9.5, color: CyberpunkTheme.textMuted),
                          ),
                          const SizedBox(height: 10),

                          Expanded(
                            child: ListView.builder(
                              itemCount: byteCount,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, bIdx) {
                                final byte = bytes[bIdx];
                                final isSelectedByte = _selectedByte == bIdx;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 5),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSelectedByte
                                        ? CyberpunkTheme.surfaceElevated
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(4),
                                    border: isSelectedByte
                                        ? Border.all(color: CyberpunkTheme.neonAmber.withValues(alpha: 0.5))
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 50,
                                        child: Text(
                                          "+${bIdx.toString().padLeft(2, '0')} (0x${byte.toRadixString(16).padLeft(2, '0').toUpperCase()})",
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                            color: isSelectedByte ? CyberpunkTheme.neonAmber : CyberpunkTheme.textDim,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: List.generate(8, (bitIdx) {
                                            final bitPower = 7 - bitIdx;
                                            final bitVal = (byte >> bitPower) & 1;
                                            final isSelected = isSelectedByte && _selectedBit == bitPower;

                                            return InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _selectedByte = bIdx;
                                                  _selectedBit = bitPower;
                                                });
                                                widget.controller.flipBitInSelectedPacket(bIdx, bitPower);
                                              },
                                              borderRadius: BorderRadius.circular(3),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? CyberpunkTheme.neonAmber
                                                      : (bitVal == 1
                                                          ? CyberpunkTheme.neonGreen.withValues(alpha: 0.25)
                                                          : CyberpunkTheme.surface),
                                                  borderRadius: BorderRadius.circular(3),
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? Colors.white
                                                        : (bitVal == 1
                                                            ? CyberpunkTheme.neonGreen.withValues(alpha: 0.7)
                                                            : CyberpunkTheme.surfaceBorder),
                                                    width: 1.0,
                                                  ),
                                                ),
                                                child: Text(
                                                  "$bitVal",
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: isSelected
                                                        ? Colors.black
                                                        : (bitVal == 1 ? CyberpunkTheme.neonGreen : CyberpunkTheme.textDim),
                                                  ),
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
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Right Side: Silicon Boolean Logic XOR & CRC-32 Math
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        // Boolean Logic XOR Gate Box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: CyberpunkTheme.background,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: CyberpunkTheme.neonPurple.withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "BOOLEAN LOGIC: AES CRYPTOGRAPHY XOR GATE",
                                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: CyberpunkTheme.neonPurple),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _logicBitBox("PLAINTEXT BIT [A]", "$currentBitVal", CyberpunkTheme.neonCyan),
                                  const Text("⊕", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                                  _logicBitBox("AES KEY BIT [B]", "$keyBit", CyberpunkTheme.neonAmber),
                                  const Text("=", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                                  _logicBitBox("CIPHER BIT [C]", "$cipherBit", CyberpunkTheme.neonGreen),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Silicon Operation: Transistor logic applies bitwise exclusive-OR (XOR) where 1 ⊕ 0 = 1, and 1 ⊕ 1 = 0.",
                                style: TextStyle(fontSize: 9, color: CyberpunkTheme.textMuted),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // CRC-32 Generator Polynomial Arithmetic Box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: CyberpunkTheme.background,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: CyberpunkTheme.neonGreen.withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "CRC-32 IEEE 802.3 GENERATOR POLYNOMIAL",
                                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: CyberpunkTheme.neonGreen),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: CyberpunkTheme.surfaceElevated,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  "G(x) = x³² + x²⁶ + x²³ + x²² + x¹⁶ + x¹² + x¹¹ + x¹⁰ + x⁸ + x⁷ + x⁵ + x⁴ + x² + x + 1",
                                  style: TextStyle(fontSize: 9.5, color: CyberpunkTheme.neonGreen, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("POLYNOMIAL HEX CONSTANT:", style: TextStyle(fontSize: 9.5, color: CyberpunkTheme.textMuted)),
                                  const Text("0xEDB88320", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: CyberpunkTheme.neonCyan)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("CURRENT PAYLOAD CHECKSUM:", style: TextStyle(fontSize: 9.5, color: CyberpunkTheme.textMuted)),
                                  Text("0x$hexCrc", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: CyberpunkTheme.neonGreen)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Action Banner
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: CyberpunkTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: CyberpunkTheme.neonRed.withValues(alpha: 0.4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(Icons.gps_fixed, color: CyberpunkTheme.neonRed, size: 14),
                                      SizedBox(width: 6),
                                      Text(
                                        "ACTIVE TARGET",
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: CyberpunkTheme.neonRed),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "Byte +$_selectedByte, Bit $_selectedBit",
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ElevatedButton.icon(
                                onPressed: () {
                                  widget.controller.flipBitInSelectedPacket(_selectedByte, _selectedBit);
                                  setState(() => _simulatedAlarm = true);
                                  Future.delayed(const Duration(seconds: 2), () {
                                    if (mounted) setState(() => _simulatedAlarm = false);
                                  });
                                },
                                icon: const Icon(Icons.flash_on, size: 14, color: Colors.black),
                                label: Text(
                                  _simulatedAlarm ? "🚨 CORRUPTED & NACK LOGGED!" : "FLIP SELECTED BIT (SNIPER TRIGGER)",
                                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _simulatedAlarm ? CyberpunkTheme.neonRed : CyberpunkTheme.neonAmber,
                                  minimumSize: const Size.fromHeight(34),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _logicBitBox(String label, String bit, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 8, color: color, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Center(
            child: Text(
              bit,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ),
      ],
    );
  }
}
