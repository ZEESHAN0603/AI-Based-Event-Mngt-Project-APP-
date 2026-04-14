import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
final Widget child;

const GlassContainer({super.key, required this.child});

@override
Widget build(BuildContext context) {
return ClipRRect(
borderRadius: BorderRadius.circular(20),
child: BackdropFilter(
filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
child: Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.white.withValues(alpha: 0.2),
borderRadius: BorderRadius.circular(20),
border: Border.all(
color: Colors.white.withValues(alpha: 0.3),
),
),
child: child,
),
),
);
}
}
