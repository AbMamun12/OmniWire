import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/file_packet.dart';
import '../models/socket_log_entry.dart';
import '../models/transfer_models.dart';
import 'file_engine.dart';
import 'socket_network_service.dart';

class TransferController extends ChangeNotifier {
  final SocketNetworkService networkService = SocketNetworkService();

  ProcessedFile? _file;
  TransferStage _stage = TransferStage.idle;
  
  // Packets state
  List<FilePacket> _senderPackets = [];
  final Map<int, FilePacket> _receiverPackets = {};
  final List<FilePacket> _inFlightPackets = [];

  // Metrics
  int _sentCount = 0;
  int _receivedCount = 0;
  int _droppedCount = 0;
  int _retransmittedCount = 0;
  int _corruptedCount = 0;
  double _currentSpeedMBps = 0.0;
  int _currentPingMs = 12;
  double _overallProgress = 0.0;
  DateTime? _startTime;
  Duration _elapsedTime = Duration.zero;

  // Real-time Telemetry Graph & Wire Sniffer Logs
  final List<SocketLogEntry> _socketLogs = [];
  final List<double> _speedHistory = List.filled(30, 0.0);

  // Visual & Inspection selections
  FilePacket? _selectedPacket;
  int _selectedOsiLayer = 4; // Default to Transport Layer
  String _latestBitStreamSample = "01001000 01100101 01101100 01101100 01101111";

  // Chaos & Playback Controls
  bool _isTransferring = false;
  bool _isPaused = false;
  double _playbackSpeed = 1.0; // 1.0 = normal, 0.2 = slow-mo, 0.05 = super slow
  double _packetLossRate = 0.0; // 0% to 30%
  double _bitFlipRate = 0.0;    // 0% to 20%
  int _simulatedLatencyMs = 15;
  bool _audioFeedbackEnabled = true;

  Timer? _transferTicker;
  Timer? _metricTicker;
  final Random _rng = Random();

  // Getters
  ProcessedFile? get file => _file;
  TransferStage get stage => _stage;
  List<FilePacket> get senderPackets => _senderPackets;
  Map<int, FilePacket> get receiverPackets => _receiverPackets;
  List<FilePacket> get inFlightPackets => _inFlightPackets;

  int get sentCount => _sentCount;
  int get receivedCount => _receivedCount;
  int get droppedCount => _droppedCount;
  int get retransmittedCount => _retransmittedCount;
  int get corruptedCount => _corruptedCount;
  double get currentSpeedMBps => _currentSpeedMBps;
  int get currentPingMs => _currentPingMs;
  double get overallProgress => _overallProgress;
  Duration get elapsedTime => _elapsedTime;

  List<SocketLogEntry> get socketLogs => _socketLogs;
  List<double> get speedHistory => _speedHistory;

  FilePacket? get selectedPacket => _selectedPacket;
  int get selectedOsiLayer => _selectedOsiLayer;
  String get latestBitStreamSample => _latestBitStreamSample;

  bool get isTransferring => _isTransferring;
  bool get isPaused => _isPaused;
  double get playbackSpeed => _playbackSpeed;
  double get packetLossRate => _packetLossRate;
  double get bitFlipRate => _bitFlipRate;
  int get simulatedLatencyMs => _simulatedLatencyMs;
  bool get audioFeedbackEnabled => _audioFeedbackEnabled;

  TransferController() {
    loadSyntheticFile(sizeMb: 100);
    addLog("RAW_SOCKET", "Raw Socket Layer initialized on 127.0.0.1:9000");
  }

  void addLog(String tag, String message) {
    final entry = SocketLogEntry(
      timestamp: DateTime.now(),
      tag: tag,
      message: message,
      color: SocketLogEntry.tagColor(tag),
    );
    _socketLogs.add(entry);
    if (_socketLogs.length > 200) {
      _socketLogs.removeAt(0);
    }
    notifyListeners();
  }

  void clearLogs() {
    _socketLogs.clear();
    notifyListeners();
  }

  void loadSyntheticFile({int sizeMb = 100}) {
    _resetState();
    _file = FileEngine.generateSyntheticFile(
      fileName: "enterprise_data_${sizeMb}mb.dat",
      sizeBytes: sizeMb * 1024 * 1024,
      chunkSizeBytes: (sizeMb >= 50) ? 128 * 1024 : 64 * 1024,
    );
    _senderPackets = List.from(_file!.packets);
    if (_senderPackets.isNotEmpty) {
      _selectedPacket = _senderPackets.first;
      _updateBitSample(_selectedPacket!);
    }
    _stage = TransferStage.idle;
    addLog("TX_ENGINE", "Loaded ${file!.name} (${(file!.totalBytes / (1024*1024)).toStringAsFixed(1)} MB, ${_senderPackets.length} Chunks)");
    notifyListeners();
  }

  Future<void> pickUserFile() async {
    final picked = await FileEngine.pickAndProcessFile();
    if (picked != null) {
      _resetState();
      _file = picked;
      _senderPackets = List.from(picked.packets);
      if (_senderPackets.isNotEmpty) {
        _selectedPacket = _senderPackets.first;
        _updateBitSample(_selectedPacket!);
      }
      _stage = TransferStage.idle;
      addLog("TX_ENGINE", "User file parsed: ${picked.name} (${picked.packets.length} Chunks)");
      notifyListeners();
    }
  }

  void _resetState() {
    _transferTicker?.cancel();
    _metricTicker?.cancel();
    _isTransferring = false;
    _isPaused = false;
    _stage = TransferStage.idle;
    _receiverPackets.clear();
    _inFlightPackets.clear();
    _sentCount = 0;
    _receivedCount = 0;
    _droppedCount = 0;
    _retransmittedCount = 0;
    _corruptedCount = 0;
    _currentSpeedMBps = 0.0;
    _overallProgress = 0.0;
    _elapsedTime = Duration.zero;
  }

  void selectPacket(FilePacket? packet) {
    _selectedPacket = packet;
    if (packet != null) {
      _updateBitSample(packet);
    }
    notifyListeners();
  }

  void selectOsiLayer(int layerNumber) {
    _selectedOsiLayer = layerNumber;
    notifyListeners();
  }

  void _updateBitSample(FilePacket packet) {
    _latestBitStreamSample = packet.toBitString(maxBytes: 8);
  }

  void toggleAudioFeedback() {
    _audioFeedbackEnabled = !_audioFeedbackEnabled;
    notifyListeners();
  }

  void setPlaybackSpeed(double speed) {
    _playbackSpeed = speed;
    addLog("TX_ENGINE", "Playback speed set to ${speed}x");
    notifyListeners();
  }

  void setPacketLossRate(double rate) {
    _packetLossRate = rate.clamp(0.0, 0.4);
    addLog("CHAOS_DROP", "Simulated packet loss rate configured to ${(rate * 100).toInt()}%");
    notifyListeners();
  }

  void setBitFlipRate(double rate) {
    _bitFlipRate = rate.clamp(0.0, 0.3);
    addLog("BIT_CORRUPT", "Simulated bit-flip corruption rate configured to ${(rate * 100).toInt()}%");
    notifyListeners();
  }

  void setLatency(int latencyMs) {
    _simulatedLatencyMs = latencyMs.clamp(5, 500);
    _currentPingMs = _simulatedLatencyMs;
    addLog("RAW_SOCKET", "Network RTT latency set to ${latencyMs}ms");
    notifyListeners();
  }

  void pauseTransfer() {
    _isPaused = true;
    addLog("TX_ENGINE", "Transmission paused by operator");
    notifyListeners();
  }

  void resumeTransfer() {
    _isPaused = false;
    addLog("TX_ENGINE", "Transmission resumed");
    notifyListeners();
  }

  /// Flip a specific bit at a byte offset in the currently selected packet (Single-Bit Sniper)
  void flipBitInSelectedPacket(int byteIndex, int bitIndex) {
    if (_selectedPacket == null) return;
    if (byteIndex >= _selectedPacket!.rawBytes.length) return;
    final oldByte = _selectedPacket!.rawBytes[byteIndex];
    final mask = 1 << bitIndex;
    final newByte = oldByte ^ mask;
    _selectedPacket!.rawBytes[byteIndex] = newByte;
    _selectedPacket!.isCorruptedSimulated = true;
    _corruptedCount++;
    _updateBitSample(_selectedPacket!);
    addLog("BIT_CORRUPT", "🎯 SINGLE-BIT SNIPER: Flipped bit $bitIndex at byte +$byteIndex on Packet #${_selectedPacket!.sequenceId} (0x${oldByte.toRadixString(16).toUpperCase()} ➔ 0x${newByte.toRadixString(16).toUpperCase()})");
    notifyListeners();
  }

  Future<void> startTransfer() async {
    if (_file == null || _senderPackets.isEmpty) return;
    if (_isTransferring && _isPaused) {
      resumeTransfer();
      return;
    }

    _resetState();
    _isTransferring = true;
    _startTime = DateTime.now();

    addLog("RAW_SOCKET", "TCP Duplex Stream established (Host: 127.0.0.1:9000 ➔ Peer: 192.168.1.100:9000)");

    // Stage 1: Slicing
    _stage = TransferStage.fileSlicing;
    addLog("TX_ENGINE", "STAGE 1: Partitioning file into ${_senderPackets.length} binary chunks of ${_file?.chunkSizeBytes ?? 65536}B");
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));

    // Stage 2: Compression & Hash
    _stage = TransferStage.compressionHash;
    addLog("TX_ENGINE", "STAGE 2: Evaluating entropy & computing CRC-32 checksums (-26% Zstd saving)");
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));

    // Stage 3: Encryption Envelope
    _stage = TransferStage.encryptionEnvelope;
    addLog("CRYPTO_AES", "STAGE 3: AES-256-GCM context active (Nonce: 0x9B4E1280, Auth Tag generated)");
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));

    // Stage 4: Packet Framing
    _stage = TransferStage.packetFraming;
    addLog("WIRE_OUT", "STAGE 4: Binary Wire Framing [Magic: 0x5450524F, Seq ID, MTU 1500B]");
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));

    // Stage 5: Wire Transmission
    _stage = TransferStage.wireTransmission;
    addLog("WIRE_OUT", "STAGE 5: Beginning multi-channel in-flight wire stream...");
    notifyListeners();

    _startTransmissionLoop();
  }

  void _startTransmissionLoop() {
    int nextSendIndex = 0;
    final total = _senderPackets.length;

    // Metrics ticker
    _metricTicker = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_startTime != null && _isTransferring && !_isPaused) {
        _elapsedTime = DateTime.now().difference(_startTime!);
        final bytesTransferred = _receivedCount * (_file?.chunkSizeBytes ?? 64 * 1024);
        final seconds = _elapsedTime.inMilliseconds / 1000.0;
        if (seconds > 0.1) {
          _currentSpeedMBps = (bytesTransferred / (1024 * 1024)) / seconds;
        }
        _overallProgress = total > 0 ? (_receivedCount / total).clamp(0.0, 1.0) : 0.0;
        _currentPingMs = _simulatedLatencyMs + _rng.nextInt(5) - 2;

        // Shift speed history graph
        _speedHistory.removeAt(0);
        _speedHistory.add(_currentSpeedMBps);

        notifyListeners();
      }
    });

    // Wire flight & packet transmission ticker
    const baseIntervalMs = 50;
    _transferTicker = Timer.periodic(const Duration(milliseconds: baseIntervalMs), (timer) {
      if (!_isTransferring) {
        timer.cancel();
        return;
      }

      if (_isPaused) return;

      // 1. Update in-flight packets (move along wire)
      final flightStep = (0.07 * _playbackSpeed).clamp(0.01, 0.25);
      final arrived = <FilePacket>[];

      for (final p in _inFlightPackets) {
        p.inFlightProgress += flightStep;
        if (p.inFlightProgress >= 1.0) {
          arrived.add(p);
        }
      }

      // 2. Handle arrived packets at Receiver
      for (final p in arrived) {
        _inFlightPackets.remove(p);
        _handlePacketArrival(p);
      }

      // 3. Dispatch new packets onto the wire if capacity allows
      final maxConcurrentInFlight = (8 * _playbackSpeed).clamp(2, 16).toInt();
      if (_inFlightPackets.length < maxConcurrentInFlight && nextSendIndex < total) {
        final packet = _senderPackets[nextSendIndex];
        nextSendIndex++;
        _dispatchPacket(packet);
      }

      // 4. Check completion
      if (_receivedCount >= total && _inFlightPackets.isEmpty) {
        _finalizeTransfer();
        timer.cancel();
      }

      notifyListeners();
    });
  }

  void _dispatchPacket(FilePacket packet) {
    packet.inFlightProgress = 0.0;
    packet.status = PacketStatus.inFlight;
    _sentCount++;

    // Check Chaos Injection: Bit flip corruption
    if (_rng.nextDouble() < _bitFlipRate) {
      packet.isCorruptedSimulated = true;
      packet.status = PacketStatus.corrupted;
      _corruptedCount++;
      addLog("BIT_CORRUPT", "Chaos Engine: Flipped bits on Packet #${packet.sequenceId}!");
    } else {
      packet.isCorruptedSimulated = false;
    }

    // Check Chaos Injection: Packet Loss
    if (_rng.nextDouble() < _packetLossRate) {
      packet.status = PacketStatus.dropped;
      _droppedCount++;
      addLog("CHAOS_DROP", "Wire Drop: Packet #${packet.sequenceId} lost in transmission (Waiting RTT)");
      // Retransmit after a brief RTT delay
      Future.delayed(Duration(milliseconds: (_simulatedLatencyMs * 2).clamp(50, 400)), () {
        if (_isTransferring) {
          _retransmittedCount++;
          packet.attempts++;
          packet.status = PacketStatus.retransmitting;
          addLog("RX_ACK", "NACK Timeout: Re-dispatching clean Packet #${packet.sequenceId} (Attempt ${packet.attempts})");
          _dispatchPacket(packet);
        }
      });
      return;
    }

    _inFlightPackets.add(packet);
    _selectedPacket = packet;
    _updateBitSample(packet);
    addLog("WIRE_OUT", "Dispatched Packet #${packet.sequenceId} (CRC32: 0x${packet.crc32.toRadixString(16).toUpperCase()})");
  }

  void _handlePacketArrival(FilePacket packet) {
    // If packet arrived corrupted, receiver rejects CRC and asks for retransmit
    if (packet.isCorruptedSimulated) {
      _corruptedCount++;
      packet.status = PacketStatus.corrupted;
      addLog("CRC_CHECK", "🚨 CRC MISMATCH on Packet #${packet.sequenceId}: Checksum failed! Requesting Retransmit");
      Future.delayed(Duration(milliseconds: _simulatedLatencyMs), () {
        if (_isTransferring) {
          _retransmittedCount++;
          packet.attempts++;
          packet.isCorruptedSimulated = false; // Fix upon retransmit
          addLog("RX_ACK", "NACK Dispatched for corrupted Packet #${packet.sequenceId}");
          _dispatchPacket(packet);
        }
      });
      return;
    }

    // Packet successfully verified by CRC32 at receiver!
    packet.status = PacketStatus.verified;
    _receiverPackets[packet.sequenceId] = packet;
    _receivedCount = _receiverPackets.length;
    addLog("CRC_CHECK", "Packet #${packet.sequenceId} verified (CRC32 match: 0x${packet.crc32.toRadixString(16).toUpperCase()} == OK)");
    addLog("RX_ACK", "ACK #${packet.sequenceId} dispatched to Sender");
  }

  void stepSinglePacket() {
    if (!_isTransferring) return;
    _isPaused = true;
    if (_senderPackets.isNotEmpty) {
      for (final p in _senderPackets) {
        if (!_receiverPackets.containsKey(p.sequenceId) && !_inFlightPackets.contains(p)) {
          addLog("TX_ENGINE", "Single Step: Stepping Packet #${p.sequenceId}");
          _dispatchPacket(p);
          break;
        }
      }
    }
    notifyListeners();
  }

  void _finalizeTransfer() {
    _stage = TransferStage.reassemblyVerification;
    addLog("RX_IN", "All ${_receiverPackets.length} packets received. Final integrity verification pass running...");
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 600), () {
      _stage = TransferStage.completed;
      _isTransferring = false;
      _overallProgress = 1.0;
      _metricTicker?.cancel();
      addLog("RX_IN", "🎉 TRANSFER COMPLETED: 100.00% Bit-accurate reconstructed file ready!");
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _transferTicker?.cancel();
    _metricTicker?.cancel();
    networkService.dispose();
    super.dispose();
  }
}
