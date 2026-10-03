# ⚡ OmniWire

> **Deep Packet Telemetry & Ultra-Speed Visual Transmission Engine**  
> *Inspect every bit. Dissect every frame. Master the wire.*

---

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Web%20%7C%20Linux%20%7C%20Windows-blue)](https://flutter.dev/multi-platform)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Build-Passing-brightgreen.svg)]()

**OmniWire** is a mission-control file transfer suite and interactive network architecture visualizer built with Flutter and Metal/Canvas GPU acceleration. Designed with a cybernetic HUD aesthetic, OmniWire allows developers, network engineers, and students to peer inside the wire and watch high-speed data serialize from raw disk bytes into bitstreams, encrypt via AES-256 GCM, segment across OSI layers, fly through simulated transmission media, and reconstruct with IEEE 802.3 CRC-32 verification.

---

## 🌟 Key Features

### 1. 🔬 Wireshark-Grade Packet Inspector
- **Hex Dump & ASCII View**: Byte-by-byte visual offsets (`0x0000` to `0xFFFF`) with live ASCII translation.
- **Raw Bit Stream Matrix**: Real-time cascading 8-bit binary representation (`01010100 01100101...`).
- **Wire Frame Dissection**: Dissect magic bytes, packet sequences, chunk offsets, payloads, and CRC-32 checksums.
- **Cryptographic Telemetry**: Real-time SHA-256 file hashes, AES-256 GCM ciphertext, initialization vectors (IV), and authentication tags.

### 2. 🎯 Interactive Bit Sniper & XOR Logic Lab
- **Single-Bit Tamper Engine**: Click on any single bit (`0` ➔ `1` or `1` ➔ `0`) inside in-flight packets.
- **Hardware XOR Logic Gate**: Real-time visual Boolean logic breakdown:  
  $$\text{Plaintext Bit} \oplus \text{Key Bit} = \text{Ciphertext Bit}$$
- **Instant Checksum Invalidation**: Demonstrates how flipping a single bit corrupts the CRC-32 checksum, causing immediate receiver rejection, socket drop, and NACK retransmission.

### 3. 🏢 Real-Time OSI 7-Layer Elevator
- Tracks in-flight packet processing in real time across the entire OSI model:
  - **L7 Application**: File I/O & payload preparation (`DATA`)
  - **L6 Presentation**: AES-256 GCM encryption & serialization (`DATA`)
  - **L5 Session**: Wire handshake & chunk stream synchronization (`DATA`)
  - **L4 Transport**: Flow control & sequence ordering (`SEGMENT`)
  - **L3 Network**: Packet addressing & routing headers (`PACKET`)
  - **L2 Data Link**: CRC-32 checksum calculation & framing (`FRAME`)
  - **L1 Physical**: NRZ-L voltage modulation & bit-streaming (`BITS`)
- Interactive layer badges with RFC deep-dive technical explanations.

### 4. 📦 Deep Packet Journey Studio
- **Russian-Doll Nested Envelope Dissector**: Expand and inspect nested encapsulations layer by layer:
  - `Ethernet Frame [14B]` ➔ `IPv4 Header [20B]` ➔ `TCP Segment [20B]` ➔ `OmniWire Header [16B]` ➔ `Payload`.
- **7-Stage Interactive Pipeline**: Step through *Disk File ➔ Bitstream ➔ Encryption ➔ Segmentation ➔ Framing ➔ Transmission ➔ Reassembly*.
- **Live Tile Matrix Reassembly**: Visual block map rendering incoming packets snapping into place on the receiving node.

### 5. 🌊 Physical Layer Oscilloscope
- Hardware-accurate NRZ-L (Non-Return-to-Zero-Level) voltage square wave rendering.
- Visualizes electrical wire state transition: **+5.0V** for bit `1` and **0.0V** for bit `0`.

### 6. ⚡ Chaos Network Engine
- **Packet Loss Simulation (0–30%)**: Simulates lossy wireless connections and packet drops.
- **Bit-Flip Corruption (0–20%)**: Simulates electromagnetic interference and physical layer noise.
- **Variable RTT Latency (10–400ms)**: Dynamically scales packet flight duration across the wire canvas.

### 7. 📟 Live Raw Socket Sniffer Terminal
- Integrated sliding cyber-terminal tracking real-time wire and buffer operations.
- Microsecond-accurate timestamp logs:
  - `[SOCKET_FD:0x4A]` memory buffer allocations
  - `[ENCRYPT_AES256]` block cipher transformations
  - `[WIRE_TX] / [WIRE_RX]` serialization and deserialization
  - `[CRC32_CHECK]` verification status and corruption alerts
- Quick filter chips: `ALL`, `SOCKET`, `ENCRYPT`, `WIRE`, `CRC`, `CHAOS`.

### 8. 📊 Real-Time Telemetry & Throughput Spectrum
- 60 FPS real-time moving sparkline graph tracking bandwidth throughput (MB/s).
- Live HUD metrics: Average Speed, Peak Throughput, Round-Trip Time (RTT), and Retransmission Counter.

---

## 🏗️ Protocol Wire Frame Specification

Each OmniWire packet adheres to the following binary wire protocol specification:

```
+---------------+---------------+---------------+---------------+
| Magic Bytes (0x5450524F)      | Version (0x01)| Flags (0x00)  |
+---------------+---------------+---------------+---------------+
| Packet Sequence (32-bit uint)                                 |
+---------------+---------------+---------------+---------------+
| Total Chunks (32-bit uint)                                    |
+---------------+---------------+---------------+---------------+
| Payload Length (32-bit uint)                                  |
+---------------+---------------+---------------+---------------+
| Variable Length Payload (Encrypted AES-256 GCM) ...          |
+---------------+---------------+---------------+---------------+
| IEEE 802.3 CRC-32 Checksum (32-bit uint)                      |
+---------------+---------------+---------------+---------------+
```

---

## 🛠️ Technology Stack

- **Framework**: [Flutter](https://flutter.dev) (macOS Desktop Native + Modern Web)
- **Language**: [Dart 3.x](https://dart.dev)
- **Rendering Engine**: Custom 60/120 FPS `CustomPainter` canvases with hardware acceleration
- **Typography**: JetBrains Mono & Space Grotesk
- **Integrity**: Custom IEEE 802.3 CRC-32 algorithm implementation & SHA-256 digests
- **Architecture**: Reactive Provider-based state management with high-frequency decoupled canvas tickers

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.22+ recommended)
- Xcode (for macOS native desktop build)
- CocoaPods (`brew install cocoapods`)

### Installation

```bash
# Clone the repository
git clone git@github.com:AbMamun12/OmniWire.git
cd OmniWire

# Fetch dependencies
flutter pub get

# Verify codebase health
flutter analyze
flutter test
```

### Running on macOS Desktop (Native)

```bash
flutter run -d macos
```

### Running on Web

```bash
flutter run -d chrome
# Or build and serve static files:
flutter build web
python3 -m http.server 8090 --directory build/web
```

---

## 📁 Repository Structure

```
transfer_pro/
├── lib/
│   ├── main.dart                          # App bootstrap & theme configuration
│   ├── theme/
│   │   └── cyberpunk_theme.dart           # Neon HUD color tokens & typography
│   ├── models/
│   │   ├── file_packet.dart               # Binary packet slices, hex dump, wire frames
│   │   ├── transfer_models.dart           # Transfer state machine & OSI layer models
│   │   └── socket_log_entry.dart          # Structured socket terminal log entries
│   ├── services/
│   │   ├── crc32_helper.dart              # IEEE 802.3 CRC-32 checksum calculator
│   │   ├── file_engine.dart               # Synthetic & real disk file picker service
│   │   └── transfer_controller.dart       # Master wire loop, chaos injector, telemetry
│   ├── widgets/
│   │   ├── wire_flight_canvas.dart        # 60 FPS in-flight particle canvas
│   │   ├── bit_matrix_stream.dart         # Cascading binary & ASCII stream
│   │   ├── chunk_grid_view.dart           # BitTorrent/SSD block allocation map
│   │   ├── osi_elevator_widget.dart       # Interactive OSI 7-layer elevator
│   │   ├── waveform_oscilloscope.dart     # NRZ-L voltage square wave canvas
│   │   ├── chaos_control_panel.dart       # Loss, bit-flip, and latency sliders
│   │   ├── packet_inspector_modal.dart    # Wireshark-grade 4-tab packet dissector
│   │   ├── packet_journey_studio_modal.dart # Russian-Doll headers & step-by-step trace
│   │   ├── bit_sniper_logic_modal.dart    # Interactive bit-flip & XOR gate studio
│   │   ├── socket_terminal_drawer.dart    # Raw socket sniffer console
│   │   └── telemetry_chart_card.dart      # Real-time throughput sparkline spectrum
│   └── screens/
│       └── transfer_pro_dashboard.dart    # Master HUD dashboard screen
└── test/
    └── widget_test.dart                   # Smoke & regression tests
```

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
