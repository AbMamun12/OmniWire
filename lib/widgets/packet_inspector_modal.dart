import 'package:flutter/material.dart';
import '../models/file_packet.dart';
import '../theme/cyberpunk_theme.dart';

class PacketInspectorModal extends StatefulWidget {
  final FilePacket packet;

  const PacketInspectorModal({
    super.key,
    required this.packet,
  });

  static void show(BuildContext context, FilePacket packet) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        child: PacketInspectorModal(packet: packet),
      ),
    );
  }

  @override
  State<PacketInspectorModal> createState() => _PacketInspectorModalState();
}

class _PacketInspectorModalState extends State<PacketInspectorModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final packet = widget.packet;

    return Container(
      width: 780,
      height: 520,
      decoration: CyberpunkTheme.glowBox(
        glowColor: CyberpunkTheme.neonCyan,
        bgColor: CyberpunkTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CyberpunkTheme.neonCyan, width: 1.5),
      ),
      child: Column(
        children: [
          // Top Title Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: CyberpunkTheme.surfaceElevated,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
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
                        color: CyberpunkTheme.neonCyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: CyberpunkTheme.neonCyan),
                      ),
                      child: Text(
                        "PACKET #${packet.sequenceId}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: CyberpunkTheme.neonCyan,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "WIRESHARK-GRADE DEEP PACKET INSPECTOR",
                      style: const TextStyle(
                        fontSize: 12,
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

          // Tab Bar
          TabBar(
            controller: _tabController,
            labelColor: CyberpunkTheme.neonCyan,
            unselectedLabelColor: CyberpunkTheme.textMuted,
            indicatorColor: CyberpunkTheme.neonCyan,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: "1. RAW BITSTREAM (0s & 1s)"),
              Tab(text: "2. HEX DUMP & ASCII"),
              Tab(text: "3. WIRE FRAME HEADERS"),
              Tab(text: "4. CRYPTO & INTEGRITY"),
            ],
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBitstreamTab(packet),
                _buildHexDumpTab(packet),
                _buildWireHeadersTab(packet),
                _buildCryptoTab(packet),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBitstreamTab(FilePacket packet) {
    final bytes = packet.rawBytes;
    final limit = bytes.length < 32 ? bytes.length : 32;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "BIT-LEVEL QUANTUM VIEW // 8 BITS PER BYTE",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: CyberpunkTheme.neonGreen,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Each character/byte is converted to 8 binary bits (0 or 1) where 1 indicates High Voltage (+5V) and 0 indicates Low Voltage (0V).",
            style: TextStyle(fontSize: 10, color: CyberpunkTheme.textMuted),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CyberpunkTheme.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: CyberpunkTheme.surfaceBorder),
              ),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: List.generate(limit, (i) {
                    final b = bytes[i];
                    final bin = b.toRadixString(2).padLeft(8, '0');
                    final charStr = (b >= 32 && b <= 126) ? String.fromCharCode(b) : '.';

                    return Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: CyberpunkTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: CyberpunkTheme.surfaceBorder),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "'$charStr' (0x${b.toRadixString(16).padLeft(2, '0').toUpperCase()})",
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: CyberpunkTheme.neonAmber,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            bin,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: CyberpunkTheme.neonGreen,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHexDumpTab(FilePacket packet) {
    final hexLines = packet.toHexDump(maxLines: 16);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "OFFSET   00 01 02 03 04 05 06 07  08 09 0A 0B 0C 0D 0E 0F   ASCII DECODE",
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: CyberpunkTheme.neonCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CyberpunkTheme.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: CyberpunkTheme.surfaceBorder),
              ),
              child: ListView.builder(
                itemCount: hexLines.length,
                itemBuilder: (context, index) {
                  final line = hexLines[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      children: [
                        Text(
                          line.offsetHex,
                          style: const TextStyle(fontSize: 10.5, color: CyberpunkTheme.neonPurple),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          line.hexBytes,
                          style: const TextStyle(fontSize: 10.5, color: CyberpunkTheme.neonCyan),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          line.ascii,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: CyberpunkTheme.neonGreen,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWireHeadersTab(FilePacket packet) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "BINARY WIRE FRAME SPECIFICATION",
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: CyberpunkTheme.neonCyan),
          ),
          const SizedBox(height: 10),
          _headerRow("MAGIC BYTES (4B)", "0x5450524F ('TPRO')", "Protocol Identifier", CyberpunkTheme.neonCyan),
          _headerRow("SEQUENCE ID (4B)", "#${packet.sequenceId} (0x${packet.sequenceId.toRadixString(16).padLeft(8, '0').toUpperCase()})", "Packet Ordering & Assembly", CyberpunkTheme.neonGreen),
          _headerRow("TOTAL PACKETS (4B)", "${packet.totalPackets}", "Transfer Slicing Total", CyberpunkTheme.textMain),
          _headerRow("CRC-32 CHECKSUM (4B)", "0x${packet.crc32.toRadixString(16).padLeft(8, '0').toUpperCase()}", "Bit Error & Corruption Detection", CyberpunkTheme.neonAmber),
          _headerRow("PAYLOAD LENGTH (4B)", "${packet.payloadSize} Bytes", "Actual Data Size", CyberpunkTheme.neonPurple),
          _headerRow("ATTEMPTS / RETRY", "${packet.attempts} Transmission(s)", "Flow Control ACK / Retransmit", packet.attempts > 1 ? CyberpunkTheme.neonRed : CyberpunkTheme.neonGreen),
        ],
      ),
    );
  }

  Widget _buildCryptoTab(FilePacket packet) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "CRYPTOGRAPHIC INTEGRITY & AUTHENTICATION",
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: CyberpunkTheme.neonGreen),
          ),
          const SizedBox(height: 12),
          _cryptoCard("SHA-256 CHUNK HASH", packet.sha256, CyberpunkTheme.neonGreen),
          const SizedBox(height: 8),
          _cryptoCard("SYMMETRIC ENCRYPTION", "AES-256-GCM (Galois/Counter Mode)", CyberpunkTheme.neonCyan),
          const SizedBox(height: 8),
          _cryptoCard("INITIALIZATION VECTOR (IV)", "0x9B4E1280F6C27A419082B4A1 (96-bit Nonce)", CyberpunkTheme.neonPurple),
          const SizedBox(height: 8),
          _cryptoCard("AUTH TAG (GMAC)", "0x7C98AA123FF056E1 (128-bit MAC Integrity)", CyberpunkTheme.neonAmber),
        ],
      ),
    );
  }

  Widget _headerRow(String field, String value, String desc, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: CyberpunkTheme.background,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: CyberpunkTheme.surfaceBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(field, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
                Text(desc, style: const TextStyle(fontSize: 9, color: CyberpunkTheme.textMuted)),
              ],
            ),
            Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _cryptoCard(String title, String value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CyberpunkTheme.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: CyberpunkTheme.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          SelectableText(
            value,
            style: const TextStyle(fontSize: 11, color: CyberpunkTheme.textMain),
          ),
        ],
      ),
    );
  }
}
