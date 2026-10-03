import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;
import '../services/crc32_helper.dart';

enum PacketStatus {
  queued,
  slicing,
  encrypting,
  framed,
  inFlight,
  dropped,
  corrupted,
  retransmitting,
  received,
  verified,
}

class FilePacket {
  static const int magicHeader = 0x5450524F; // "TPRO" in ASCII hex

  final int sequenceId;
  final int totalPackets;
  final int offset;
  final Uint8List rawBytes;
  final int crc32;
  final String sha256;
  PacketStatus status;
  int attempts;
  double inFlightProgress; // 0.0 to 1.0 along the wire
  bool isCorruptedSimulated;
  DateTime timestamp;

  FilePacket({
    required this.sequenceId,
    required this.totalPackets,
    required this.offset,
    required this.rawBytes,
    required this.crc32,
    required this.sha256,
    this.status = PacketStatus.queued,
    this.attempts = 1,
    this.inFlightProgress = 0.0,
    this.isCorruptedSimulated = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory FilePacket.fromBytes({
    required int sequenceId,
    required int totalPackets,
    required int offset,
    required Uint8List bytes,
  }) {
    final crc = Crc32Helper.compute(bytes);
    final hash = computeSha256(bytes);
    return FilePacket(
      sequenceId: sequenceId,
      totalPackets: totalPackets,
      offset: offset,
      rawBytes: bytes,
      crc32: crc,
      sha256: hash,
    );
  }

  static String computeSha256(Uint8List data) {
    return crypto.sha256.convert(data).toString();
  }

  int get payloadSize => rawBytes.length;

  /// Returns 0s and 1s binary string formatted in 8-bit bytes
  String toBitString({int maxBytes = 16}) {
    final limit = rawBytes.length < maxBytes ? rawBytes.length : maxBytes;
    final buffer = StringBuffer();
    for (int i = 0; i < limit; i++) {
      buffer.write(rawBytes[i].toRadixString(2).padLeft(8, '0'));
      if (i < limit - 1) buffer.write(' ');
    }
    if (rawBytes.length > maxBytes) {
      buffer.write(' ... (+${rawBytes.length - maxBytes} bytes)');
    }
    return buffer.toString();
  }

  /// Returns formatted Wireshark/Hex-editor style dump
  List<HexDumpLine> toHexDump({int maxLines = 12}) {
    final lines = <HexDumpLine>[];
    const int bytesPerLine = 16;
    final totalLines = (rawBytes.length / bytesPerLine).ceil();
    final displayLines = totalLines < maxLines ? totalLines : maxLines;

    for (int l = 0; l < displayLines; l++) {
      final lineOffset = l * bytesPerLine;
      final endOffset = (lineOffset + bytesPerLine < rawBytes.length)
          ? lineOffset + bytesPerLine
          : rawBytes.length;
      final chunk = rawBytes.sublist(lineOffset, endOffset);

      final hexParts = <String>[];
      final asciiParts = StringBuffer();

      for (int i = 0; i < bytesPerLine; i++) {
        if (i < chunk.length) {
          final b = chunk[i];
          hexParts.add(b.toRadixString(16).padLeft(2, '0').toUpperCase());
          if (b >= 32 && b <= 126) {
            asciiParts.write(String.fromCharCode(b));
          } else {
            asciiParts.write('.');
          }
        } else {
          hexParts.add('  ');
        }
      }

      lines.add(HexDumpLine(
        offsetHex: (offset + lineOffset).toRadixString(16).padLeft(8, '0').toUpperCase(),
        hexBytes: hexParts.join(' '),
        ascii: asciiParts.toString(),
      ));
    }

    return lines;
  }

  Uint8List toWireFrame() {
    final frame = Uint8List(20 + rawBytes.length);
    final bdata = ByteData.sublistView(frame);
    bdata.setUint32(0, magicHeader, Endian.big);
    bdata.setUint32(4, sequenceId, Endian.big);
    bdata.setUint32(8, totalPackets, Endian.big);
    bdata.setUint32(12, isCorruptedSimulated ? (crc32 ^ 0xFF) : crc32, Endian.big);
    bdata.setUint32(16, rawBytes.length, Endian.big);
    frame.setRange(20, 20 + rawBytes.length, rawBytes);
    return frame;
  }
}

class HexDumpLine {
  final String offsetHex;
  final String hexBytes;
  final String ascii;

  HexDumpLine({
    required this.offsetHex,
    required this.hexBytes,
    required this.ascii,
  });
}
