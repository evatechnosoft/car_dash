import 'package:flutter/material.dart';
import '../../domain/models/gauge_config.dart';

class DraggableGauge extends StatefulWidget {
  final GaugeConfig config;
  final Widget child;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback onSelect;
  final VoidCallback onDeselect;
  final Function(Offset) onPositionChanged;
  final Function(double) onScaleChanged;
  final VoidCallback onSettingsRequested;

  const DraggableGauge({
    super.key,
    required this.config,
    required this.child,
    required this.isSelected,
    required this.isLocked,
    required this.onSelect,
    required this.onDeselect,
    required this.onPositionChanged,
    required this.onScaleChanged,
    required this.onSettingsRequested,
  });

  @override
  State<DraggableGauge> createState() => _DraggableGaugeState();
}

class _DraggableGaugeState extends State<DraggableGauge> {
  bool _isDragging = false;
  Offset _dragStartPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    const double hitBuffer = 60.0;

    return Positioned(
      left: widget.config.position.dx - hitBuffer,
      top: widget.config.position.dy - hitBuffer,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. The Gauge Content Area
          Padding(
            padding: const EdgeInsets.all(hitBuffer),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (widget.isLocked) return;
                if (widget.isSelected) {
                  widget.onDeselect();
                } else {
                  widget.onSelect();
                }
              },
              onLongPressStart: (details) {
                if (widget.isLocked) return;
                _dragStartPosition = widget.config.position;
                setState(() => _isDragging = true);
                widget.onSelect();
              },
              onLongPressEnd: (_) {
                setState(() => _isDragging = false);
              },
              onLongPressMoveUpdate: (details) {
                if (widget.isLocked) return;
                widget.onPositionChanged(_dragStartPosition + details.offsetFromOrigin);
              },
              onDoubleTap: widget.isLocked ? null : widget.onSettingsRequested,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 100, minHeight: 100),
                child: AnimatedScale(
                  scale: (_isDragging || widget.isSelected) ? widget.config.scale * 1.05 : widget.config.scale,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    decoration: (_isDragging || widget.isSelected)
                        ? BoxDecoration(
                            border: Border.all(color: widget.config.accentColor.withOpacity(0.8), width: 2),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: widget.config.accentColor.withOpacity(0.2),
                                blurRadius: 15,
                                spreadRadius: 2,
                              )
                            ],
                          )
                        : null,
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),

          // 2. Interaction Ornaments (Rendered on top)
          if (widget.isSelected && !_isDragging) ...[
            // Quick Resize Slider (Relative to stack at 0,0)
            Positioned(
              left: 10,
              bottom: 10,
              width: 150,
              height: 48,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: widget.config.accentColor.withOpacity(0.6)),
                  boxShadow: const [
                    BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4))
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.zoom_in, size: 16, color: widget.config.accentColor),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                          activeTrackColor: widget.config.accentColor,
                          inactiveTrackColor: Colors.white10,
                          thumbColor: widget.config.accentColor,
                        ),
                        child: Slider(
                          value: widget.config.scale,
                          min: 0.5,
                          max: 2.0,
                          onChanged: widget.onScaleChanged,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Settings Icon (Bottom Right area)
            Positioned(
              right: 20,
              bottom: 20,
              child: GestureDetector(
                onTap: widget.onSettingsRequested,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.config.accentColor,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(color: Colors.black45, blurRadius: 12, offset: Offset(0, 4))
                    ],
                  ),
                  child: const Icon(Icons.tune, size: 24, color: Colors.black),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
