import 'package:flutter/material.dart';
import '../models/socket_log_entry.dart';
import '../services/transfer_controller.dart';
import '../theme/cyberpunk_theme.dart';

class SocketTerminalDrawer extends StatefulWidget {
  final TransferController controller;

  const SocketTerminalDrawer({
    super.key,
    required this.controller,
  });

  static void show(BuildContext context, TransferController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.65,
        child: SocketTerminalDrawer(controller: controller),
      ),
    );
  }

  @override
  State<SocketTerminalDrawer> createState() => _SocketTerminalDrawerState();
}

class _SocketTerminalDrawerState extends State<SocketTerminalDrawer> {
  String _selectedFilter = "ALL";
  bool _autoScroll = true;
  final ScrollController _scrollController = ScrollController();

  final List<String> _filters = [
    "ALL",
    "RAW_SOCKET",
    "TX_ENGINE",
    "CRYPTO_AES",
    "WIRE_OUT",
    "CRC_CHECK",
    "RX_ACK",
    "CHAOS_DROP",
    "BIT_CORRUPT",
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_autoScroll && _scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final allLogs = widget.controller.socketLogs;
    final logs = _selectedFilter == "ALL"
        ? allLogs
        : allLogs.where((l) => l.tag == _selectedFilter).toList();

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Container(
      decoration: BoxDecoration(
        color: CyberpunkTheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border.all(color: CyberpunkTheme.neonCyan.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: CyberpunkTheme.neonCyan.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: CyberpunkTheme.surfaceElevated,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: CyberpunkTheme.surfaceBorder)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: CyberpunkTheme.neonCyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.terminal, color: CyberpunkTheme.neonCyan, size: 16),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "LIVE RAW SOCKET SNIFFER & WIRE EVENT STREAM",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: CyberpunkTheme.textMain,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: CyberpunkTheme.neonGreen.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "${allLogs.length} EVENTS",
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: CyberpunkTheme.neonGreen),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      tooltip: _autoScroll ? "Disable Auto-Scroll" : "Enable Auto-Scroll",
                      icon: Icon(
                        _autoScroll ? Icons.vertical_align_bottom : Icons.pause,
                        color: _autoScroll ? CyberpunkTheme.neonGreen : CyberpunkTheme.textMuted,
                        size: 18,
                      ),
                      onPressed: () => setState(() => _autoScroll = !_autoScroll),
                    ),
                    IconButton(
                      tooltip: "Clear Terminal",
                      icon: const Icon(Icons.delete_sweep, color: CyberpunkTheme.textMuted, size: 18),
                      onPressed: () => setState(() => widget.controller.clearLogs()),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: CyberpunkTheme.textMuted, size: 18),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter Chips Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: CyberpunkTheme.background,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((f) {
                  final isSelected = _selectedFilter == f;
                  final tagCol = f == "ALL" ? CyberpunkTheme.neonCyan : SocketLogEntry.tagColor(f);

                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: InkWell(
                      onTap: () => setState(() => _selectedFilter = f),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isSelected ? tagCol.withValues(alpha: 0.2) : CyberpunkTheme.surface,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isSelected ? tagCol : CyberpunkTheme.surfaceBorder,
                            width: isSelected ? 1.2 : 0.8,
                          ),
                        ),
                        child: Text(
                          f,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? tagCol : CyberpunkTheme.textMuted,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Terminal Log Output
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              color: const Color(0xFF04070E),
              child: logs.isEmpty
                  ? const Center(
                      child: Text(
                        "TERMINAL STANDBY // START TRANSMISSION TO STREAM EVENTS",
                        style: TextStyle(fontSize: 11, color: CyberpunkTheme.textDim),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: logs.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final log = logs[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                log.formattedTime,
                                style: const TextStyle(fontSize: 9.5, color: CyberpunkTheme.textDim),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 90,
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: log.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Text(
                                  "[${log.tag}]",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: log.color,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SelectableText(
                                  log.message,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: log.color == CyberpunkTheme.neonRed ? CyberpunkTheme.neonRed : CyberpunkTheme.textMain,
                                  ),
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
}
