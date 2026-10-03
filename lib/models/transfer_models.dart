enum TransferStage {
  idle,
  fileSlicing,
  compressionHash,
  encryptionEnvelope,
  packetFraming,
  wireTransmission,
  reassemblyVerification,
  completed,
}

extension TransferStageX on TransferStage {
  String get title {
    switch (this) {
      case TransferStage.idle:
        return "SYSTEM IDLE";
      case TransferStage.fileSlicing:
        return "STAGE 1: BINARY SLICING (FILE ➔ BYTES)";
      case TransferStage.compressionHash:
        return "STAGE 2: COMPRESSION & INTEGRITY HASH (CRC-32)";
      case TransferStage.encryptionEnvelope:
        return "STAGE 3: ENCRYPTION ENVELOPE (AES-256-GCM)";
      case TransferStage.packetFraming:
        return "STAGE 4: PACKET FRAMING & MTU PACKING";
      case TransferStage.wireTransmission:
        return "STAGE 5: WIRE TRANSMISSION (IN-FLIGHT STREAM)";
      case TransferStage.reassemblyVerification:
        return "STAGE 6: REASSEMBLY & BIT INTEGRITY CHECK";
      case TransferStage.completed:
        return "STAGE 7: VERIFIED & COMPLETED";
    }
  }

  String get description {
    switch (this) {
      case TransferStage.idle:
        return "Select a file or start simulation to inspect pipeline";
      case TransferStage.fileSlicing:
        return "Reading raw file buffer and partitioning into byte chunks";
      case TransferStage.compressionHash:
        return "Evaluating entropy, compressing payload and computing CRC-32 checksums";
      case TransferStage.encryptionEnvelope:
        return "Applying symmetric cryptography and attaching authentication vectors";
      case TransferStage.packetFraming:
        return "Encoding magic headers (0x5450524F), sequence IDs and frame delimiters";
      case TransferStage.wireTransmission:
        return "Broadcasting binary frames across network wire with flow control";
      case TransferStage.reassemblyVerification:
        return "Reordering jitter buffers, verifying CRC-32 match and decoding to file";
      case TransferStage.completed:
        return "100.00% Bit-level match verified. File successfully transferred.";
    }
  }

  /// Maps the current transfer stage to the corresponding active OSI layer (7 down to 1)
  int get activeOsiLayer {
    switch (this) {
      case TransferStage.idle:
        return 7;
      case TransferStage.fileSlicing:
        return 7; // L7 Application
      case TransferStage.compressionHash:
      case TransferStage.encryptionEnvelope:
        return 6; // L6 Presentation
      case TransferStage.packetFraming:
        return 4; // L4 Transport (after L5 Session)
      case TransferStage.wireTransmission:
        return 1; // L1 Physical (traveling on wire via L2/L3)
      case TransferStage.reassemblyVerification:
        return 4; // L4 Jitter Buffer & CRC Check
      case TransferStage.completed:
        return 7; // L7 Final file presented to user
    }
  }
}

class OsiLayerInfo {
  final int layerNumber;
  final String name;
  final String protocol;
  final String responsibility;
  final String activeTransform;
  final String dataUnit;
  final String headerSummary;
  final String colorHex;
  final String visualIllustration;
  final String nextStepAction;

  const OsiLayerInfo({
    required this.layerNumber,
    required this.name,
    required this.protocol,
    required this.responsibility,
    required this.activeTransform,
    required this.dataUnit,
    required this.headerSummary,
    required this.colorHex,
    required this.visualIllustration,
    required this.nextStepAction,
  });

  static const List<OsiLayerInfo> layers = [
    OsiLayerInfo(
      layerNumber: 7,
      name: "Application Layer",
      protocol: "TransferPro Native / HTTP3",
      responsibility: "File ingestion, buffer stream allocation & MIME detection",
      activeTransform: "Streams file buffer directly into Uint8List byte array",
      dataUnit: "DATA",
      headerSummary: "File: 100MB | MIME: application/octet-stream | Chunks: 1000",
      colorHex: "#00F0FF",
      visualIllustration: "📁 [ RAW FILE (100 MB) ] ➔ Sliced into [ 64 KB CHUNKS ]",
      nextStepAction: "➔ Next: Passes to L6 (Presentation) for Compression & AES Encryption",
    ),
    OsiLayerInfo(
      layerNumber: 6,
      name: "Presentation Layer",
      protocol: "Zstd + AES-256-GCM",
      responsibility: "Entropy evaluation, Zstandard compression & cryptographic ciphering",
      activeTransform: "Transforms plaintext bytes into authenticated ciphertext",
      dataUnit: "ENCRYPTED DATA",
      headerSummary: "Cipher: AES-256-GCM | IV Nonce: 96-bit | Tag: 128-bit | Comp: -26%",
      colorHex: "#B026FF",
      visualIllustration: "🔒 [ PLAIN BYTES ] ➔ AES-GCM Encrypt ➔ [ CIPHER BYTES: 0x9F4C1B... ]",
      nextStepAction: "➔ Next: Passes to L5 (Session) to attach Session Auth Token",
    ),
    OsiLayerInfo(
      layerNumber: 5,
      name: "Session Layer",
      protocol: "WebRTC / Socket Channel",
      responsibility: "Duplex state synchronization & connection session lifecycle",
      activeTransform: "Validates peer handshake, channel duplexing & session token",
      dataUnit: "SESSION DATA",
      headerSummary: "Session ID: SES-TPRO-9842 | Channel: Duplex 0 | Heartbeat: 1000ms",
      colorHex: "#2979FF",
      visualIllustration: "🤝 [ SENDER TX ] ⟷ [ TOKEN: SES-9842 ] ⟷ [ RECEIVER RX ]",
      nextStepAction: "➔ Next: Passes to L4 (Transport) to partition into segments & attach Seq ID",
    ),
    OsiLayerInfo(
      layerNumber: 4,
      name: "Transport Layer",
      protocol: "TCP/UDP Flow Control",
      responsibility: "Packet sequencing, flow control, CRC-32 checksum & sliding window",
      activeTransform: "Attaches sequence ID (#0..#N), window size & CRC-32 integrity header",
      dataUnit: "SEGMENT",
      headerSummary: "Port: 9000 ➔ 9000 | Seq: #0004 | Ack: #0003 | Window: 65535",
      colorHex: "#00FF88",
      visualIllustration: "📦 ┌─[ TCP HEADER (Port 9000 | Seq #4) ]─┬─[ ENCRYPTED DATA ]─┐",
      nextStepAction: "➔ Next: Passes to L3 (Network) to attach IP packet routing headers",
    ),
    OsiLayerInfo(
      layerNumber: 3,
      name: "Network Layer",
      protocol: "IPv4 / IPv6 Packets",
      responsibility: "Source/Destination IP resolution, packet routing & MTU slicing",
      activeTransform: "Encapsulates into IP packet (Src/Dest IP, TTL: 64, MTU: 1500 bytes)",
      dataUnit: "PACKET",
      headerSummary: "Src IP: 127.0.0.1 | Dst IP: 192.168.1.100 | TTL: 64 | MTU: 1500",
      colorHex: "#FFB800",
      visualIllustration: "🌐 ┌─[ IP HEADER (127.0.0.1 ➔ 192.168.1.100) ]─┬─[ L4 SEGMENT ]─┐",
      nextStepAction: "➔ Next: Passes to L2 (Data Link) to attach MAC Frame & CRC FCS",
    ),
    OsiLayerInfo(
      layerNumber: 2,
      name: "Data Link Layer",
      protocol: "Ethernet Frame / MAC",
      responsibility: "Hardware MAC addressing, frame delimiters & error-checking (FCS)",
      activeTransform: "Envelopes IP packet inside Ethernet MAC frame with CRC-32 FCS",
      dataUnit: "FRAME",
      headerSummary: "Src MAC: 00:1A:2B:3C:4D:5E | Dst MAC: 3A:F2:10:88:99:01 | CRC32",
      colorHex: "#FF0055",
      visualIllustration: "🖥️ ┌─[ MAC HEADER ]─┬─[ IP PACKET ]─┬─[ FCS CRC-32 CHECKSUM ]─┐",
      nextStepAction: "➔ Next: Passes to L1 (Physical) for voltage & optical signal modulation",
    ),
    OsiLayerInfo(
      layerNumber: 1,
      name: "Physical Layer",
      protocol: "PHY / Fiber / Wi-Fi Waves",
      responsibility: "Bitstream modulation into digital voltage pulses or optical light waves",
      activeTransform: "Modulates binary 0s and 1s into NRZ-L electrical voltage (+5.0V / 0.0V)",
      dataUnit: "BITS (0s & 1s)",
      headerSummary: "Voltage: +5.0V (Bit 1) / 0.0V (Bit 0) | Rate: 1.0 Gbps | NRZ-L",
      colorHex: "#00FFCC",
      visualIllustration: "⚡ HIGH (+5V) ‾|_|‾|_‾| LOW (0V) ➔ [ 01001000 01100101 01101100... ]",
      nextStepAction: "🚀 In-Transit: Traveling across physical wire/fiber to receiver node!",
    ),
  ];
}
