import 'package:flutter/material.dart';
import '../models/file_packet.dart';
import '../theme/cyberpunk_theme.dart';

class ChunkGridView extends StatelessWidget {
  final List<FilePacket> senderPackets;
  final Map<int, FilePacket> receiverPackets;
  final List<FilePacket> inFlightPackets;
  final FilePacket? selectedPacket;
  final Function(FilePacket) onPacketSelected;

  const ChunkGridView({
    super.key,
    required this.senderPackets,
    required this.receiverPackets,
    required this.inFlightPackets,
    required this.selectedPacket,
    required this.onPacketSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (senderPackets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: CyberpunkTheme.glowBox(),
        child: const Center(
          child: Text(
            "NO FILE LOADED",
            style: TextStyle(color: CyberpunkTheme.textDim),
          ),
        ),
      );
    }

    final inFlightIds = inFlightPackets.map((p) => p.sequenceId).toSet();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: CyberpunkTheme.glowBox(
        glowColor: CyberpunkTheme.neonPurple,
        bgColor: CyberpunkTheme.surfaceElevated,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: CyberpunkTheme.neonPurple,
                ),
              ),
              const SizedBox(width: 8),
              const Flexible(
                child: Text(
                  "CHUNKS ALLOCATION & REASSEMBLY MAP",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: CyberpunkTheme.neonPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Legend
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _legendItem("Queued", CyberpunkTheme.surfaceBorder),
              _legendItem("In-Flight", CyberpunkTheme.neonCyan),
              _legendItem("Reassembled", CyberpunkTheme.neonGreen),
              _legendItem("Retransmit", CyberpunkTheme.neonAmber),
              _legendItem("Dropped", CyberpunkTheme.neonRed),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 18,
                mainAxisSpacing: 3,
                crossAxisSpacing: 3,
              ),
              itemCount: senderPackets.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final packet = senderPackets[index];
                final isReceived = receiverPackets.containsKey(packet.sequenceId);
                final isInFlight = inFlightIds.contains(packet.sequenceId);
                final isSelected = selectedPacket?.sequenceId == packet.sequenceId;

                Color blockColor = CyberpunkTheme.surfaceBorder;
                if (isReceived) {
                  blockColor = CyberpunkTheme.neonGreen;
                } else if (isInFlight) {
                  blockColor = packet.isCorruptedSimulated
                      ? CyberpunkTheme.neonRed
                      : (packet.status == PacketStatus.retransmitting
                          ? CyberpunkTheme.neonAmber
                          : CyberpunkTheme.neonCyan);
                } else if (packet.status == PacketStatus.dropped) {
                  blockColor = CyberpunkTheme.neonRed;
                }

                return Tooltip(
                  message: "Chunk #${packet.sequenceId}\nOffset: 0x${packet.offset.toRadixString(16).toUpperCase()}\nCRC32: 0x${packet.crc32.toRadixString(16).toUpperCase()}\nStatus: ${isReceived ? 'Reassembled' : (isInFlight ? 'In-Flight' : 'Pending')}",
                  child: InkWell(
                    onTap: () => onPacketSelected(packet),
                    borderRadius: BorderRadius.circular(2),
                    child: Container(
                      decoration: BoxDecoration(
                        color: blockColor,
                        borderRadius: BorderRadius.circular(2),
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 1.5)
                            : null,
                        boxShadow: isSelected
                            ? [
                                const BoxShadow(
                                  color: Colors.white,
                                  blurRadius: 4,
                                )
                              ]
                            : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: CyberpunkTheme.textMuted),
        ),
      ],
    );
  }
}
