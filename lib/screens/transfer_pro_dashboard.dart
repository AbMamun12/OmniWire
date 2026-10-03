import 'package:flutter/material.dart';
import '../models/transfer_models.dart';
import '../services/file_engine.dart';
import '../services/transfer_controller.dart';
import '../theme/cyberpunk_theme.dart';
import '../widgets/bit_matrix_stream.dart';
import '../widgets/chaos_control_panel.dart';
import '../widgets/chunk_grid_view.dart';
import '../widgets/hud_metrics_card.dart';
import '../widgets/osi_elevator_widget.dart';
import '../widgets/bit_sniper_logic_modal.dart';
import '../widgets/packet_inspector_modal.dart';
import '../widgets/packet_journey_studio_modal.dart';
import '../widgets/socket_terminal_drawer.dart';
import '../widgets/telemetry_chart_card.dart';
import '../widgets/waveform_oscilloscope.dart';
import '../widgets/wire_flight_canvas.dart';

class TransferProDashboard extends StatefulWidget {
  const TransferProDashboard({super.key});

  @override
  State<TransferProDashboard> createState() => _TransferProDashboardState();
}

class _TransferProDashboardState extends State<TransferProDashboard> {
  late TransferController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TransferController();
    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final file = _controller.file;
    final stage = _controller.stage;

    return Scaffold(
      backgroundColor: CyberpunkTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top Mission Control Header
              _buildTopBar(file),
              const SizedBox(height: 8),

              // 2. Active Pipeline Stage Notification Banner
              _buildStageBanner(stage),
              const SizedBox(height: 8),

              // 3. Telemetry Metrics Bar
              HudMetricsBar(controller: _controller),
              const SizedBox(height: 8),

              // 4. In-Flight Wire Transmission Canvas
              SizedBox(
                height: 140,
                child: WireFlightCanvas(
                  inFlightPackets: _controller.inFlightPackets,
                  onPacketSelected: (packet) {
                    _controller.selectPacket(packet);
                    PacketInspectorModal.show(context, packet);
                  },
                  progress: _controller.overallProgress,
                  isTransferring: _controller.isTransferring && !_controller.isPaused,
                  senderCount: _controller.sentCount,
                  receiverCount: _controller.receivedCount,
                ),
              ),
              const SizedBox(height: 8),

              // 5. Middle Split Panels: Bit Matrix, Chunk Grid & OSI Elevator
              Expanded(
                flex: 5,
                child: Row(
                  children: [
                    // Left: Live Bitstream Streamer
                    Expanded(
                      flex: 3,
                      child: BitMatrixStreamWidget(
                        activePacket: _controller.selectedPacket,
                        isTransferring: _controller.isTransferring && !_controller.isPaused,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Center: Chunk Allocation Grid
                    Expanded(
                      flex: 4,
                      child: ChunkGridView(
                        senderPackets: _controller.senderPackets,
                        receiverPackets: _controller.receiverPackets,
                        inFlightPackets: _controller.inFlightPackets,
                        selectedPacket: _controller.selectedPacket,
                        onPacketSelected: (packet) {
                          _controller.selectPacket(packet);
                          PacketInspectorModal.show(context, packet);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Right: OSI 7-Layer Elevator
                    Expanded(
                      flex: 3,
                      child: OsiElevatorWidget(
                        selectedLayer: _controller.selectedOsiLayer,
                        currentProcessingLayer: _controller.stage.activeOsiLayer,
                        onLayerSelected: (l) => _controller.selectOsiLayer(l),
                        isTransferring: _controller.isTransferring,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // 6. Lower Panels: Oscilloscope, Telemetry Spectrum & Chaos Sandbox Controls
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    // Oscilloscope
                    Expanded(
                      flex: 4,
                      child: WaveformOscilloscopeWidget(
                        activePacket: _controller.selectedPacket,
                        isTransferring: _controller.isTransferring && !_controller.isPaused,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Telemetry Throughput Spectrum
                    Expanded(
                      flex: 3,
                      child: TelemetryChartCard(controller: _controller),
                    ),
                    const SizedBox(width: 8),

                    // Chaos Sandbox
                    Expanded(
                      flex: 4,
                      child: ChaosControlPanel(controller: _controller),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(ProcessedFile? file) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: CyberpunkTheme.glowBox(
        glowColor: CyberpunkTheme.neonCyan,
        bgColor: CyberpunkTheme.surfaceElevated,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          // Logo & Branding
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: CyberpunkTheme.neonCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: CyberpunkTheme.neonCyan, width: 1.2),
                ),
                child: const Icon(Icons.bolt, color: CyberpunkTheme.neonCyan, size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "TRANSFER PRO",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: CyberpunkTheme.textMain,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: CyberpunkTheme.neonGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "v2.4 HUD",
                          style: TextStyle(fontSize: 8.5, color: CyberpunkTheme.neonGreen, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    file != null
                        ? "${file.name} (${(file.totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB // ${(file.totalBits / 1000000).toStringAsFixed(0)}M BITS)"
                        : "NO FILE LOADED",
                    style: const TextStyle(fontSize: 10, color: CyberpunkTheme.textMuted),
                  ),
                ],
              ),
            ],
          ),

          // File Selector Presets & Custom File
          Row(
            children: [
              _filePresetButton("10 MB", 10),
              const SizedBox(width: 4),
              _filePresetButton("50 MB", 50),
              const SizedBox(width: 4),
              _filePresetButton("100 MB", 100),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _controller.pickUserFile(),
                icon: const Icon(Icons.folder_open, size: 14, color: CyberpunkTheme.neonCyan),
                label: const Text("CUSTOM FILE", style: TextStyle(fontSize: 10, color: CyberpunkTheme.neonCyan)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: CyberpunkTheme.neonCyan),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
            ],
          ),

          // Playback / Transfer Controls
          Row(
            children: [
              // Inspector Modal Button
              if (_controller.selectedPacket != null) ...[
                TextButton.icon(
                  onPressed: () => PacketInspectorModal.show(context, _controller.selectedPacket!),
                  icon: const Icon(Icons.biotech, size: 14, color: CyberpunkTheme.neonAmber),
                  label: const Text("INSPECT PACKET", style: TextStyle(fontSize: 10, color: CyberpunkTheme.neonAmber)),
                ),
                const SizedBox(width: 4),
                // Deep Dive Journey Studio Button
                TextButton.icon(
                  onPressed: () => PacketJourneyStudioModal.show(
                    context,
                    packet: _controller.selectedPacket!,
                    totalPackets: _controller.senderPackets.length,
                    receivedCount: _controller.receivedCount,
                  ),
                  icon: const Icon(Icons.travel_explore, size: 14, color: CyberpunkTheme.neonCyan),
                  label: const Text(
                    "PACKET JOURNEY STUDIO",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: CyberpunkTheme.neonCyan),
                  ),
                ),
                const SizedBox(width: 4),
                // Bit Sniper Button
                TextButton.icon(
                  onPressed: () => BitSniperLogicModal.show(context, _controller),
                  icon: const Icon(Icons.gps_fixed, size: 14, color: CyberpunkTheme.neonAmber),
                  label: const Text(
                    "BIT SNIPER (XOR LAB)",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: CyberpunkTheme.neonAmber),
                  ),
                ),
                const SizedBox(width: 4),
                // Wire Sniffer Terminal Button
                TextButton.icon(
                  onPressed: () => SocketTerminalDrawer.show(context, _controller),
                  icon: const Icon(Icons.terminal, size: 14, color: CyberpunkTheme.neonGreen),
                  label: Text(
                    "WIRE TERMINAL (${_controller.socketLogs.length})",
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: CyberpunkTheme.neonGreen),
                  ),
                ),
              ],

              const SizedBox(width: 6),
              // Single Step Button
              IconButton(
                tooltip: "Step Single Packet (Pause & Step)",
                icon: const Icon(Icons.skip_next, color: CyberpunkTheme.neonCyan, size: 18),
                onPressed: () => _controller.stepSinglePacket(),
              ),

              // Speed selector (1x, 0.5x, 0.1x)
              PopupMenuButton<double>(
                tooltip: "Speed / Slow-Motion",
                initialValue: _controller.playbackSpeed,
                onSelected: (speed) => _controller.setPlaybackSpeed(speed),
                color: CyberpunkTheme.surfaceElevated,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: CyberpunkTheme.surface,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: CyberpunkTheme.surfaceBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${_controller.playbackSpeed}x",
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: CyberpunkTheme.neonCyan),
                      ),
                      const Icon(Icons.arrow_drop_down, size: 14, color: CyberpunkTheme.neonCyan),
                    ],
                  ),
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 1.0, child: Text("1.0x Real-Time Speed", style: TextStyle(fontSize: 11))),
                  const PopupMenuItem(value: 0.5, child: Text("0.5x Half Speed", style: TextStyle(fontSize: 11))),
                  const PopupMenuItem(value: 0.1, child: Text("0.1x Slow-Mo Matrix", style: TextStyle(fontSize: 11))),
                ],
              ),

              const SizedBox(width: 8),
              // Start / Pause Main Action Button
              ElevatedButton.icon(
                onPressed: () {
                  if (_controller.isTransferring && !_controller.isPaused) {
                    _controller.pauseTransfer();
                  } else {
                    _controller.startTransfer();
                  }
                },
                icon: Icon(
                  (_controller.isTransferring && !_controller.isPaused)
                      ? Icons.pause
                      : Icons.play_arrow,
                  size: 16,
                  color: Colors.black,
                ),
                label: Text(
                  (_controller.isTransferring && !_controller.isPaused)
                      ? "PAUSE"
                      : (_controller.isPaused ? "RESUME" : "START TRANSMISSION"),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: (_controller.isTransferring && !_controller.isPaused)
                      ? CyberpunkTheme.neonAmber
                      : CyberpunkTheme.neonGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _filePresetButton(String label, int sizeMb) {
    final isCurrent = _controller.file?.totalBytes == sizeMb * 1024 * 1024;
    return InkWell(
      onTap: () => _controller.loadSyntheticFile(sizeMb: sizeMb),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isCurrent ? CyberpunkTheme.neonCyan.withValues(alpha: 0.2) : CyberpunkTheme.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isCurrent ? CyberpunkTheme.neonCyan : CyberpunkTheme.surfaceBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isCurrent ? CyberpunkTheme.neonCyan : CyberpunkTheme.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildStageBanner(TransferStage stage) {
    Color stageColor = CyberpunkTheme.neonCyan;
    if (stage == TransferStage.completed) stageColor = CyberpunkTheme.neonGreen;
    if (stage == TransferStage.wireTransmission) stageColor = CyberpunkTheme.neonCyan;
    if (stage == TransferStage.encryptionEnvelope) stageColor = CyberpunkTheme.neonPurple;
    if (stage == TransferStage.compressionHash) stageColor = CyberpunkTheme.neonAmber;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: stageColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: stageColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(shape: BoxShape.circle, color: stageColor),
              ),
              const SizedBox(width: 8),
              Text(
                stage.title,
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: stageColor),
              ),
            ],
          ),
          Text(
            stage.description,
            style: const TextStyle(fontSize: 9.5, color: CyberpunkTheme.textMuted),
          ),
        ],
      ),
    );
  }
}
