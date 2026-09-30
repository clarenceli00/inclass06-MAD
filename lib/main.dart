// In-Class Activity 06 — Drawing with Flutter
// Student: Clarence Li
// Date: September 26, 2026

import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() => runApp(const SmileyApp());

class SmileyApp extends StatelessWidget {
  const SmileyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smiley Painter Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const DrawingPlayground(),
    );
  }
}

class DrawingPlayground extends StatefulWidget {
  const DrawingPlayground({super.key});

  @override
  State<DrawingPlayground> createState() => _DrawingPlaygroundState();
}

class _DrawingPlaygroundState extends State<DrawingPlayground> {
  // Drawing "state" — changing these + setState() triggers shouldRepaint
  double mood = 0.8; // 0.0 sad → 1.0 happy
  double eyeRadius = 0.5;
  double eyeGap = 0.5;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CustomPainter Smiley Lab')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: CustomPaint(
                    painter: SmileyPainter(
                      mood: mood,
                      eyeRadius: eyeRadius * 10 + 10,
                      eyeGap: eyeGap * 80 + 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Mood: ${mood.toStringAsFixed(2)}'),
                Slider(
                  value: mood,
                  onChanged: (double v) => setState(() => mood = v),
                ),
                Text('Eye Radius: ${eyeRadius.toStringAsFixed(2)}'),
                Slider(
                  value: eyeRadius,
                  onChanged: (double v) => setState(() => eyeRadius = v),
                ),
                Text('Eye Gap: ${eyeGap.toStringAsFixed(2)}'),
                Slider(
                  value: eyeGap,
                  onChanged: (double v) => setState(() => eyeGap = v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SmileyPainter extends CustomPainter {
  SmileyPainter({required this.mood,required this.eyeRadius,required this.eyeGap});
  final double mood;
  final double eyeRadius;
  final double eyeGap;
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide * 0.40;

    // 1) Face
    final faceColor;
    if (mood < 0.5) {
  // --- SAD TO NEUTRAL (Blue to Yellow) ---
  // Scale the first half (0.0 to 0.5) into a standard 0.0 to 1.0 fraction
      final double fraction = mood / 0.5;
      faceColor = Color.lerp(Colors.blue, Colors.yellow, fraction)!;
    } else {
      // --- NEUTRAL TO HAPPY (Yellow to Orange) ---
      // Scale the second half (0.5 to 1.0) into a standard 0.0 to 1.0 fraction
      final double fraction = (mood - 0.5) / 0.5;
      faceColor = Color.lerp(Colors.yellow, Colors.orange, fraction)!;
    }
    
    canvas.drawCircle(c, r, Paint()..color = faceColor);

    // 2) Face border
    canvas.drawCircle(
      c, r,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // 3) Eyes
    final eyePaint = Paint()..color = Colors.black87;
    final eyeY = c.dy - r * 0.18;
    canvas.drawCircle(Offset(c.dx - eyeGap, eyeY), eyeRadius, eyePaint);
    canvas.drawCircle(Offset(c.dx + eyeGap, eyeY), eyeRadius, eyePaint);

    // 4) Mouth — map mood (0..1) to arc geometry
    final mouthPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    // (0.0 = Sad, 0.5 = Neutral, 1.0 = Happy)
    final pi = math.pi;

    // This normalizes the mood value into a curvature depth factor from 0.0 to 1.0
    final double curveIntensity = (mood - 0.5).abs() * 2.0;
    // Dynamically scale the sweep angle so it collapses to near-0 when flattening
    final double dynamicSweep = (0.70 * pi) * math.max(curveIntensity, 0.001);

    if (mood >= 0.5) {
      // As mood approaches 0.5, dynamicSweep shrinks, so we must adjust the startAngle 
      // to keep the arc centered horizontally.
      final startAngle = (0.5 * pi) - (dynamicSweep / 2.0);
      
      final mouthRect = Rect.fromCenter(
        center: Offset(c.dx, c.dy + r * 0.15),
        width: r * 1.0,
        height: r * curveIntensity * 0.5, // Height scales down to 0 at mood 0.5
      );

      canvas.drawArc(mouthRect, startAngle, dynamicSweep, false, mouthPaint);
    } else {
      // Neutral to sad
      final startAngle = (1.5 * pi) - (dynamicSweep / 2.0);
      
      final frownRect = Rect.fromCenter(
        center: Offset(c.dx, c.dy + r * 0.15 + (r * 0.25 * curveIntensity)),
        width: r * 1.0,
        height: r * curveIntensity * 0.5, // Height scales up as mood drops below 0.5
      );

      canvas.drawArc(frownRect, startAngle, dynamicSweep, false, mouthPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SmileyPainter oldDelegate) {
    return oldDelegate.mood != mood;
  }
}