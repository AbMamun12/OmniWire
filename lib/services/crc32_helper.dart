
/// Standard CRC-32 (IEEE 802.3 polynomial 0xEDB88320)
class Crc32Helper {
  static final List<int> _table = _buildCrcTable();

  static List<int> _buildCrcTable() {
    final table = List<int>.filled(256, 0);
    for (int i = 0; i < 256; i++) {
      int crc = i;
      for (int j = 0; j < 8; j++) {
        if ((crc & 1) != 0) {
          crc = (crc >>> 1) ^ 0xEDB88320;
        } else {
          crc = crc >>> 1;
        }
      }
      table[i] = crc;
    }
    return table;
  }

  static int compute(List<int> bytes) {
    int crc = 0xFFFFFFFF;
    for (final byte in bytes) {
      final index = (crc ^ byte) & 0xFF;
      crc = (crc >>> 8) ^ _table[index];
    }
    return (crc ^ 0xFFFFFFFF) >>> 0;
  }

  static String toHex(int crcValue) {
    return crcValue.toRadixString(16).padLeft(8, '0').toUpperCase();
  }
}
