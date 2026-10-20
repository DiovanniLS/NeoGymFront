import 'dart:math' as math;

import 'package:flutter/material.dart';

class WaterFillCard extends StatefulWidget {
  final double progress;
  final double currentWater;
  final double goalWater;
  final VoidCallback onAddWater;
  final VoidCallback onSettings;
  final int waterStepMl;

  const WaterFillCard({
    super.key,
    required this.progress,
    required this.currentWater,
    required this.goalWater,
    required this.waterStepMl,
    required this.onAddWater,
    required this.onSettings,
  });

  @override
  State<WaterFillCard> createState() => _WaterFillCardState();
}

class _WaterFillCardState extends State<WaterFillCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.progress.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.shade200,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Água
            Positioned.fill(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: 0,
                  end: progress,
                ),
                duration: const Duration(
                  milliseconds: 1000,
                ),
                curve: Curves.easeInOut,
                builder: (
                    context,
                    animatedProgress,
                    child,
                    ) {
                  return AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _WaterPainter(
                          progress: animatedProgress,
                          wavePhase:
                          _waveController.value *
                              2 *
                              math.pi,
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Conteúdo
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.water_drop,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Hidratação',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed:
                        widget.onSettings,
                        icon: const Icon(
                          Icons.settings,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  Text(
                    '${widget.currentWater.toStringAsFixed(1)}L'
                        ' / '
                        '${widget.goalWater.toStringAsFixed(1)}L',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    progress >= 1
                        ? 'Meta atingida 🎉'
                        : 'Continue se hidratando',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed:
                      widget.onAddWater,
                      child: Text(
                        '+${widget.waterStepMl}ml',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaterPainter extends CustomPainter {
  final double progress;
  final double wavePhase;

  _WaterPainter({
    required this.progress,
    required this.wavePhase,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final waterHeight =
        size.height * progress;

    final waterTop =
        size.height - waterHeight;

    final paint = Paint()
      ..color = Colors.lightBlue.withOpacity(0.75)
      ..style = PaintingStyle.fill;

    final path = Path();

    path.moveTo(0, waterTop);

    for (
    double x = 0;
    x <= size.width;
    x += 4
    ) {
      final normalizedX =
          x / size.width;

      final wave =
          math.sin(
            normalizedX *
                math.pi *
                4 +
                wavePhase,
          ) *
              5;

      path.lineTo(
        x,
        waterTop + wave,
      );
    }

    path.lineTo(
      size.width,
      size.height,
    );

    path.lineTo(
      0,
      size.height,
    );

    path.close();

    canvas.drawPath(
      path,
      paint,
    );
  }

  @override
  bool shouldRepaint(
      covariant _WaterPainter oldDelegate,
      ) {
    return oldDelegate.progress != progress ||
        oldDelegate.wavePhase != wavePhase;
  }
}