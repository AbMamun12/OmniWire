import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import '../models/file_packet.dart';
import 'crc32_helper.dart';

class ProcessedFile {
  final String name;
  final int totalBytes;
  final String mimeType;
  final List<FilePacket> packets;
  final int chunkSizeBytes;
  final int totalChecksum;
  final double simulatedCompressionRatio;

  ProcessedFile({
    required this.name,
    required this.totalBytes,
    required this.mimeType,
    required this.packets,
    required this.chunkSizeBytes,
    required this.totalChecksum,
    required this.simulatedCompressionRatio,
  });

  int get totalBits => totalBytes * 8;
  int get packetCount => packets.length;
}

class FileEngine {
  /// Generate a synthetic high-entropy binary payload for demonstration
  static ProcessedFile generateSyntheticFile({
    String fileName = "enterprise_data_100mb.bin",
    int sizeBytes = 10 * 1024 * 1024, // 10MB default for instant smooth load, configurable
    int chunkSizeBytes = 64 * 1024,     // 64 KB per packet
  }) {
    final totalPackets = (sizeBytes / chunkSizeBytes).ceil();
    final packets = <FilePacket>[];

    // Seed realistic simulated bytes
    for (int i = 0; i < totalPackets; i++) {
      final currentChunkSize = (i == totalPackets - 1)
          ? sizeBytes - (i * chunkSizeBytes)
          : chunkSizeBytes;

      final chunkBytes = Uint8List(currentChunkSize);
      // Fill chunk with patterned binary (header, text, and pseudo-random payload)
      for (int b = 0; b < currentChunkSize; b++) {
        if (b < 16) {
          chunkBytes[b] = (b + i * 3) & 0xFF;
        } else {
          chunkBytes[b] = (b * 7 + (i * 13)) & 0xFF;
        }
      }

      packets.add(FilePacket.fromBytes(
        sequenceId: i,
        totalPackets: totalPackets,
        offset: i * chunkSizeBytes,
        bytes: chunkBytes,
      ));
    }

    return ProcessedFile(
      name: fileName,
      totalBytes: sizeBytes,
      mimeType: "application/octet-stream",
      packets: packets,
      chunkSizeBytes: chunkSizeBytes,
      totalChecksum: 0xA789B1C2,
      simulatedCompressionRatio: 0.74, // 26% compression saving
    );
  }

  /// Process a real file picked by the user from disk
  static Future<ProcessedFile?> pickAndProcessFile({
    int chunkSizeBytes = 64 * 1024,
  }) async {
    try {
      final files = await FilePickerPlatform.instance.pickFiles();
      if (files.isEmpty) return null;
      final file = files.first;

      Uint8List? bytes;
      if (file.path != null) {
        bytes = await File(file.path!).readAsBytes();
      }

      if (bytes == null || bytes.isEmpty) return null;

      final totalBytes = bytes.length;
      final totalPackets = (totalBytes / chunkSizeBytes).ceil();
      final packets = <FilePacket>[];

      for (int i = 0; i < totalPackets; i++) {
        final start = i * chunkSizeBytes;
        final end = (start + chunkSizeBytes > totalBytes) ? totalBytes : start + chunkSizeBytes;
        final chunkBytes = bytes.sublist(start, end);

        packets.add(FilePacket.fromBytes(
          sequenceId: i,
          totalPackets: totalPackets,
          offset: start,
          bytes: chunkBytes,
        ));
      }

      final fullChecksum = Crc32Helper.compute(bytes);

      return ProcessedFile(
        name: file.name,
        totalBytes: totalBytes,
        mimeType: file.name.split('.').last,
        packets: packets,
        chunkSizeBytes: chunkSizeBytes,
        totalChecksum: fullChecksum,
        simulatedCompressionRatio: 0.81,
      );
    } catch (_) {
      return null;
    }
  }
}
