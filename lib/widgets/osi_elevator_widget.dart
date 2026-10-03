import 'package:flutter/material.dart';
import '../models/transfer_models.dart';
import '../theme/cyberpunk_theme.dart';

class OsiElevatorWidget extends StatefulWidget {
  final int selectedLayer;
  final int currentProcessingLayer;
  final Function(int) onLayerSelected;
  final bool isTransferring;

  const OsiElevatorWidget({
    super.key,
    required this.selectedLayer,
    required this.currentProcessingLayer,
    required this.onLayerSelected,
    required this.isTransferring,
  });

  @override
  State<OsiElevatorWidget> createState() => _OsiElevatorWidgetState();
}

class _OsiElevatorWidgetState extends State<OsiElevatorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showLayerDetailModal(BuildContext context, OsiLayerInfo layer) {
    final layerColor = Color(int.parse(layer.colorHex.replaceFirst('#', '0xFF')));

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        child: Container(
          width: 650,
          padding: const EdgeInsets.all(20),
          decoration: CyberpunkTheme.glowBox(
            glowColor: layerColor,
            bgColor: CyberpunkTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: layerColor, width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: layerColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: layerColor),
                        ),
                        child: Text(
                          "LAYER ${layer.layerNumber} : ${layer.dataUnit}",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: layerColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        layer.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: CyberpunkTheme.textMain,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: CyberpunkTheme.textMuted, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(color: CyberpunkTheme.surfaceBorder),
              const SizedBox(height: 12),

              // Responsibilities
              _infoCard("🎯 RESPONSIBILITY & LAYER ROLE", layer.responsibility, layerColor),
              const SizedBox(height: 10),

              // Active Transformation
              _infoCard("⚙️ DATA TRANSFORMATION MECHANISM", layer.activeTransform, CyberpunkTheme.neonCyan),
              const SizedBox(height: 10),

              // Visual Encapsulation Box Diagram
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CyberpunkTheme.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: layerColor.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.view_in_ar, size: 14, color: CyberpunkTheme.neonAmber),
                        const SizedBox(width: 6),
                        const Text(
                          "PACKET ENCAPSULATION ENVELOPE (DATA BOX)",
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: CyberpunkTheme.neonAmber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: CyberpunkTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: CyberpunkTheme.surfaceBorder),
                      ),
                      child: Text(
                        layer.visualIllustration,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: layerColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Header Metadata: ${layer.headerSummary}",
                      style: const TextStyle(fontSize: 10, color: CyberpunkTheme.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Next step
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: CyberpunkTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: CyberpunkTheme.neonGreen.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_downward, color: CyberpunkTheme.neonGreen, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        layer.nextStepAction,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: CyberpunkTheme.neonGreen,
                        ),
                      ),
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

  Widget _infoCard(String title, String desc, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CyberpunkTheme.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: CyberpunkTheme.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(fontSize: 11, color: CyberpunkTheme.textMain)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: CyberpunkTheme.glowBox(
            glowColor: CyberpunkTheme.neonAmber,
            bgColor: CyberpunkTheme.surfaceElevated,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: CyberpunkTheme.neonAmber,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Flexible(
                          child: Text(
                            "OSI 7-LAYER PIPELINE",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                              color: CyberpunkTheme.neonAmber,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: CyberpunkTheme.neonCyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: CyberpunkTheme.neonCyan.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      widget.isTransferring
                          ? "L${widget.currentProcessingLayer} BUSY"
                          : "L1-L7 READY",
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: CyberpunkTheme.neonCyan,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Layers List
              Expanded(
                child: ListView.builder(
                  itemCount: OsiLayerInfo.layers.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final layer = OsiLayerInfo.layers[index];
                    final isSelected = widget.selectedLayer == layer.layerNumber;
                    final isCurrentlyActive = widget.isTransferring &&
                        (widget.currentProcessingLayer == layer.layerNumber);
                    final isCompleted = widget.isTransferring &&
                        (layer.layerNumber > widget.currentProcessingLayer);

                    final layerColor =
                        Color(int.parse(layer.colorHex.replaceFirst('#', '0xFF')));

                    // Border and background calculation
                    Color borderColor = CyberpunkTheme.surfaceBorder;
                    Color bgColor = CyberpunkTheme.surface;

                    if (isCurrentlyActive) {
                      borderColor = layerColor;
                      bgColor = layerColor.withValues(
                          alpha: 0.15 + (_pulseController.value * 0.15));
                    } else if (isSelected) {
                      borderColor = layerColor;
                      bgColor = layerColor.withValues(alpha: 0.1);
                    } else if (isCompleted) {
                      borderColor = CyberpunkTheme.neonGreen.withValues(alpha: 0.4);
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: InkWell(
                        onTap: () {
                          widget.onLayerSelected(layer.layerNumber);
                          _showLayerDetailModal(context, layer);
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: borderColor,
                              width: isCurrentlyActive ? 1.6 : 1.0,
                            ),
                            boxShadow: isCurrentlyActive
                                ? [
                                    BoxShadow(
                                      color: layerColor.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Layer Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: layerColor.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(3),
                                      border: Border.all(color: layerColor, width: 0.8),
                                    ),
                                    child: Text(
                                      "L${layer.layerNumber}",
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: layerColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  // Data Unit Tag
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: CyberpunkTheme.surfaceBorder,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      layer.dataUnit,
                                      style: const TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: CyberpunkTheme.textMain,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  // Layer Name
                                  Expanded(
                                    child: Text(
                                      layer.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isCurrentlyActive || isSelected
                                            ? Colors.white
                                            : CyberpunkTheme.textMain,
                                      ),
                                    ),
                                  ),
                                  // Status Indicator
                                  if (isCurrentlyActive)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: CyberpunkTheme.neonAmber.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: const Text(
                                        "ACTIVE ⚙️",
                                        style: TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          color: CyberpunkTheme.neonAmber,
                                        ),
                                      ),
                                    )
                                  else if (isCompleted)
                                    const Icon(Icons.check_circle,
                                        color: CyberpunkTheme.neonGreen, size: 12)
                                  else
                                    const Icon(Icons.touch_app_outlined,
                                        color: CyberpunkTheme.textDim, size: 12),
                                ],
                              ),
                              const SizedBox(height: 3),
                              // Visual Representation Snippet
                              Text(
                                isCurrentlyActive
                                    ? layer.visualIllustration
                                    : layer.responsibility,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 8.5,
                                  color: isCurrentlyActive
                                      ? layerColor
                                      : CyberpunkTheme.textMuted,
                                ),
                              ),
                            ],
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
      },
    );
  }
}
