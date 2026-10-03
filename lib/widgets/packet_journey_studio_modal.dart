import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/file_packet.dart';
import '../theme/cyberpunk_theme.dart';

class PacketJourneyStudioModal extends StatefulWidget {
  final FilePacket packet;
  final int totalPackets;
  final int receivedCount;

  const PacketJourneyStudioModal({
    super.key,
    required this.packet,
    required this.totalPackets,
    required this.receivedCount,
  });

  static void show(BuildContext context, {
    required FilePacket packet,
    required int totalPackets,
    required int receivedCount,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: PacketJourneyStudioModal(
          packet: packet,
          totalPackets: totalPackets,
          receivedCount: receivedCount,
        ),
      ),
    );
  }

  @override
  State<PacketJourneyStudioModal> createState() => _PacketJourneyStudioModalState();
}

class _PacketJourneyStudioModalState extends State<PacketJourneyStudioModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentStepIndex = 0;
  bool _isPlaying = false;
  Timer? _stepTimer;

  // Step definition for the 7-stage packet journey
  final List<Map<String, dynamic>> _journeySteps = [
    {
      "step": 1,
      "title": "Raw File Ingestion & Chunking",
      "layer": "L7 Application",
      "color": CyberpunkTheme.neonCyan,
      "icon": Icons.folder_open,
      "desc": "Reads 65,536 bytes (64 KB) from the disk buffer and loads into RAM as raw Uint8List.",
      "visualState": "RAW FILE BUFFER [64 KB]",
      "details": "MIME: application/octet-stream | File Offset: 0x00040000 | Data Size: 65,536 Bytes",
    },
    {
      "step": 2,
      "title": "Zstandard Entropy Compression",
      "layer": "L6 Presentation",
      "color": CyberpunkTheme.neonPurple,
      "icon": Icons.compress,
      "desc": "Analyzes byte redundancy and compresses data volume by 26% to speed up transmission.",
      "visualState": "COMPRESSED: 64 KB ➔ 47.3 KB (-26% Volume)",
      "details": "Original: 65,536 B | Compressed: 48,496 B | Compression Ratio: 0.74 | Algo: Zstd",
    },
    {
      "step": 3,
      "title": "AES-256-GCM Symmetric Encryption",
      "layer": "L6 Presentation",
      "color": CyberpunkTheme.neonAmber,
      "icon": Icons.lock,
      "desc": "Encrypts payload with 256-bit key and generates 96-bit Nonce and 128-bit Authentication Tag.",
      "visualState": "PLAINTEXT ➔ SCRAMBLED CIPHERTEXT (0x9F4C1B7A...)",
      "details": "Cipher: AES-256-GCM | IV Nonce: 0x9B4E1280F6C27A41 | GMAC Auth Tag: 0x7C98AA123FF056E1",
    },
    {
      "step": 4,
      "title": "Binary Protocol Framing & MTU Slicing",
      "layer": "L4-L5 Transport & Session",
      "color": CyberpunkTheme.neonGreen,
      "icon": Icons.view_in_ar,
      "desc": "Attaches 20-byte wire frame header: Magic Bytes (0x5450524F), Sequence ID, Total, and CRC-32.",
      "visualState": "HEADER [20 BYTES] + PAYLOAD [48,496 BYTES]",
      "details": "Magic: 0x5450524F ('TPRO') | Seq ID: #0004 | Port: 9000 ➔ 9000 | CRC-32: 0xA789B1C2",
    },
    {
      "step": 5,
      "title": "Network Wire & Optical Flight",
      "layer": "L1-L3 Physical, Data Link & Network",
      "color": CyberpunkTheme.neonBlue,
      "icon": Icons.wifi_tethering,
      "desc": "Transmits binary bits across network wire modulated into electrical voltage (+5.0V / 0.0V).",
      "visualState": "TRAVELING: TX (127.0.0.1) ➔ RX (192.168.1.100) [12ms RTT]",
      "details": "Src MAC: 00:1A:2B:3C:4D:5E | Dst MAC: 3A:F2:10:88:99:01 | Throughput: 1.0 Gbps",
    },
    {
      "step": 6,
      "title": "Receiver Checksum & Integrity Match",
      "layer": "L4 Transport",
      "color": CyberpunkTheme.neonGreen,
      "icon": Icons.verified,
      "desc": "Receiver recomputes CRC-32 over received payload and compares with header CRC-32.",
      "visualState": "INTEGRITY CHECK: 0xA789B1C2 == 0xA789B1C2 (100% MATCH ✓)",
      "details": "Packet Verified: 0 Bit Errors Detected | ACK #0004 dispatched back to Sender",
    },
    {
      "step": 7,
      "title": "Decryption & File Assembly",
      "layer": "L7 Application",
      "color": CyberpunkTheme.neonCyan,
      "icon": Icons.check_circle,
      "desc": "Decrypts ciphertext, decompresses payload and slots chunk into final reconstructed file buffer.",
      "visualState": "CHUNK REASSEMBLED INTO FINAL FILE (CHUNK #4 / TOTAL)",
      "details": "Reassembly Buffer: Offset 0x00040000 Filled | File Progress: 100% Bit-Accurate",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _toggleAutoPlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _stepTimer?.cancel();
        _stepTimer = Timer.periodic(const Duration(milliseconds: 1400), (timer) {
          if (!mounted) {
            timer.cancel();
            return;
          }
          setState(() {
            if (_currentStepIndex < _journeySteps.length - 1) {
              _currentStepIndex++;
            } else {
              _currentStepIndex = 0;
            }
          });
        });
      } else {
        _stepTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 950,
      height: 620,
      decoration: CyberpunkTheme.glowBox(
        glowColor: CyberpunkTheme.neonCyan,
        bgColor: CyberpunkTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CyberpunkTheme.neonCyan, width: 1.5),
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
                        color: CyberpunkTheme.neonCyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: CyberpunkTheme.neonCyan),
                      ),
                      child: const Text(
                        "DEEP DIVE STUDIO",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: CyberpunkTheme.neonCyan,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "PACKET JOURNEY & NESTED ENVELOPE DISSECTOR",
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

          // Tab Selector
          TabBar(
            controller: _tabController,
            labelColor: CyberpunkTheme.neonCyan,
            unselectedLabelColor: CyberpunkTheme.textMuted,
            indicatorColor: CyberpunkTheme.neonCyan,
            labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: "1. TRACE 7-STAGE PACKET JOURNEY"),
              Tab(text: "2. RUSSIAN-DOLL NESTED ENVELOPE"),
              Tab(text: "3. LIVE FILE TILE ASSEMBLY PREVIEW"),
            ],
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildJourneyTab(),
                _buildNestedEnvelopeTab(),
                _buildTileAssemblyTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TAB 1: 7-Stage Interactive Packet Journey Walkthrough
  Widget _buildJourneyTab() {
    final current = _journeySteps[_currentStepIndex];
    final stepColor = current["color"] as Color;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Step Progress Bar
          Row(
            children: List.generate(_journeySteps.length, (index) {
              final isPassed = index < _currentStepIndex;
              final isCurrent = index == _currentStepIndex;
              final color = isCurrent
                  ? stepColor
                  : (isPassed ? CyberpunkTheme.neonGreen : CyberpunkTheme.surfaceBorder);

              return Expanded(
                child: InkWell(
                  onTap: () => setState(() => _currentStepIndex = index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? color.withValues(alpha: 0.25)
                          : CyberpunkTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: color, width: isCurrent ? 1.5 : 1.0),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "STEP ${index + 1}",
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Icon(
                          isPassed
                              ? Icons.check
                              : (current["icon"] as IconData),
                          size: 12,
                          color: color,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // Main Step Display Card
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CyberpunkTheme.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: stepColor.withValues(alpha: 0.6), width: 1.4),
                boxShadow: [
                  BoxShadow(
                    color: stepColor.withValues(alpha: 0.15),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(current["icon"] as IconData, color: stepColor, size: 22),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "STAGE ${_currentStepIndex + 1} OF 7: ${current["title"].toUpperCase()}",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                  color: stepColor,
                                ),
                              ),
                              Text(
                                "OSI Architecture: ${current["layer"]}",
                                style: const TextStyle(fontSize: 10, color: CyberpunkTheme.textMuted),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: stepColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: stepColor),
                        ),
                        child: Text(
                          "PACKET #${widget.packet.sequenceId}",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: stepColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: CyberpunkTheme.surfaceBorder),
                  const SizedBox(height: 10),

                  Text(
                    current["desc"] as String,
                    style: const TextStyle(fontSize: 12, color: CyberpunkTheme.textMain),
                  ),
                  const SizedBox(height: 14),

                  // Visual State Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: CyberpunkTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: stepColor.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "ACTIVE PAYLOAD STATE ON WIRE",
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: CyberpunkTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          current["visualState"] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: stepColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Technical Specifications Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: CyberpunkTheme.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: CyberpunkTheme.surfaceBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "PROTOCOL ATTRIBUTES & TELEMETRY",
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: CyberpunkTheme.neonAmber),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          current["details"] as String,
                          style: const TextStyle(fontSize: 10.5, color: CyberpunkTheme.textMain),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Playback Navigation Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: _currentStepIndex > 0
                    ? () => setState(() => _currentStepIndex--)
                    : null,
                icon: const Icon(Icons.arrow_back, size: 14),
                label: const Text("PREVIOUS STEP", style: TextStyle(fontSize: 10.5)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: CyberpunkTheme.surfaceBorder),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _toggleAutoPlay,
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 16, color: Colors.black),
                label: Text(
                  _isPlaying ? "PAUSE AUTO-TRACE" : "AUTO-TRACE JOURNEY",
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isPlaying ? CyberpunkTheme.neonAmber : CyberpunkTheme.neonCyan,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _currentStepIndex < _journeySteps.length - 1
                    ? () => setState(() => _currentStepIndex++)
                    : null,
                icon: const Icon(Icons.arrow_forward, size: 14),
                label: const Text("NEXT STEP", style: TextStyle(fontSize: 10.5)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: CyberpunkTheme.surfaceBorder),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // TAB 2: Russian-Doll Nested Envelope Dissector
  Widget _buildNestedEnvelopeTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "THE RUSSIAN-DOLL PROTOCOL ENVELOPE (DATA ENCAPSULATION)",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: CyberpunkTheme.neonCyan,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "See how each network layer physically wraps the payload inside its own header envelope.",
            style: TextStyle(fontSize: 10, color: CyberpunkTheme.textMuted),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: SingleChildScrollView(
              child: _buildLayerBox(
                layerName: "LAYER 2: ETHERNET MAC FRAME",
                headerInfo: "Preamble (7B) | Src MAC: 00:1A:2B:3C:4D:5E | Dst MAC: 3A:F2:10:88:99:01 | Type: 0x0800 (IPv4)",
                color: CyberpunkTheme.neonRed,
                child: _buildLayerBox(
                  layerName: "LAYER 3: IP NETWORK PACKET",
                  headerInfo: "Version: IPv4 | Total Len: 1500B | TTL: 64 | Protocol: 6 (TCP) | Src: 127.0.0.1 ➔ Dst: 192.168.1.100",
                  color: CyberpunkTheme.neonAmber,
                  child: _buildLayerBox(
                    layerName: "LAYER 4: TCP TRANSPORT SEGMENT",
                    headerInfo: "Src Port: 9000 | Dst Port: 9000 | Seq #: 0x00000004 | Ack #: 0x00000003 | Window: 65535",
                    color: CyberpunkTheme.neonGreen,
                    child: _buildLayerBox(
                      layerName: "LAYERS 5-6: SESSION & AES-256 CIPHER ENVELOPE",
                      headerInfo: "Session ID: SES-TPRO-9842 | AES-256-GCM Nonce: 0x9B4E1280 | Auth Tag: 0x7C98AA123FF0",
                      color: CyberpunkTheme.neonPurple,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CyberpunkTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: CyberpunkTheme.neonCyan, width: 1.2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  "LAYER 7: RAW FILE PAYLOAD (64 KB)",
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: CyberpunkTheme.neonCyan,
                                  ),
                                ),
                                Text(
                                  "ACTUAL FILE BYTES",
                                  style: TextStyle(fontSize: 9, color: CyberpunkTheme.textMuted),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            SelectableText(
                              widget.packet.toBitString(maxBytes: 8),
                              style: const TextStyle(
                                fontSize: 10.5,
                                letterSpacing: 1.1,
                                color: CyberpunkTheme.neonGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayerBox({
    required String layerName,
    required String headerInfo,
    required Color color,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CyberpunkTheme.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.7), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                layerName,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: color,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text(
                  "HEADER ENCAPSULATION",
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            headerInfo,
            style: const TextStyle(fontSize: 9, color: CyberpunkTheme.textMuted),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  // TAB 3: Live File Tile Assembly Preview Canvas
  Widget _buildTileAssemblyTab() {
    final total = widget.totalPackets > 0 ? widget.totalPackets : 100;
    final received = widget.receivedCount;
    final progress = (received / total).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "FILE RECONSTRUCTION PREVIEW CANVAS",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: CyberpunkTheme.neonGreen,
                    ),
                  ),
                  Text(
                    "Watching incoming binary packets assemble tile-by-tile into the finished destination file.",
                    style: const TextStyle(fontSize: 10, color: CyberpunkTheme.textMuted),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CyberpunkTheme.neonGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: CyberpunkTheme.neonGreen),
                ),
                child: Text(
                  "$received / $total TILES ASSEMBLED (${(progress * 100).toStringAsFixed(1)}%)",
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: CyberpunkTheme.neonGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // File Reconstruction Tiles
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CyberpunkTheme.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: CyberpunkTheme.surfaceBorder),
              ),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 16,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: min(total, 256),
                itemBuilder: (context, index) {
                  final isTileReady = index < received;
                  final isCurrent = index == received;

                  Color tileColor = CyberpunkTheme.surfaceElevated;
                  if (isTileReady) {
                    // Seed pleasant neon gradient across assembled tiles
                    tileColor = (index % 2 == 0)
                        ? CyberpunkTheme.neonGreen
                        : CyberpunkTheme.neonCyan;
                  } else if (isCurrent) {
                    tileColor = CyberpunkTheme.neonAmber;
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: isTileReady ? tileColor.withValues(alpha: 0.8) : tileColor,
                      borderRadius: BorderRadius.circular(3),
                      border: isCurrent
                          ? Border.all(color: Colors.white, width: 1.5)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        "#$index",
                        style: TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                          color: isTileReady ? Colors.black : CyberpunkTheme.textDim,
                        ),
                      ),
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
}
