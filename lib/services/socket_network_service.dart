import 'dart:async';
import '../models/file_packet.dart';

enum ConnectionMode {
  loopbackSimulator,
  lanP2p,
}

class NetworkTransmissionEvent {
  final FilePacket packet;
  final bool isDropped;
  final bool isCorrupted;
  final bool isRetransmit;
  final double currentSpeedMBps;
  final int inFlightCount;

  NetworkTransmissionEvent({
    required this.packet,
    this.isDropped = false,
    this.isCorrupted = false,
    this.isRetransmit = false,
    required this.currentSpeedMBps,
    required this.inFlightCount,
  });
}

class SocketNetworkService {
  final _eventStreamController = StreamController<NetworkTransmissionEvent>.broadcast();
  Stream<NetworkTransmissionEvent> get eventStream => _eventStreamController.stream;

  bool _isPaused = false;
  double speedMultiplier = 1.0;

  // Chaos simulation settings
  double packetLossPercentage = 0.0; // 0% to 30%
  double bitFlipPercentage = 0.0;     // 0% to 20%
  int latencyJitterMs = 15;           // simulated ping latency

  bool get isPaused => _isPaused;

  void pause() => _isPaused = true;
  void resume() => _isPaused = false;

  void updateChaosSettings({
    double? packetLoss,
    double? bitFlip,
    int? latency,
    double? speed,
  }) {
    if (packetLoss != null) packetLossPercentage = packetLoss;
    if (bitFlip != null) bitFlipPercentage = bitFlip;
    if (latency != null) latencyJitterMs = latency;
    if (speed != null) speedMultiplier = speed;
  }

  void dispose() {
    _eventStreamController.close();
  }
}
