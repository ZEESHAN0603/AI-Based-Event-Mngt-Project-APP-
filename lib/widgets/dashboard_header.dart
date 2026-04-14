import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {

final String title;
final String subtitle;

const DashboardHeader({
super.key,
required this.title,
required this.subtitle,
});

@override
Widget build(BuildContext context) {

double screenWidth = MediaQuery.of(context).size.width;

return Container(
width: double.infinity,
padding: const EdgeInsets.symmetric(
horizontal: 20,
vertical: 20,
),
decoration: BoxDecoration(
color: Theme.of(context).primaryColor.withOpacity(0.1),
borderRadius: BorderRadius.circular(18),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [

Text(
title,
style: TextStyle(
fontSize: screenWidth * 0.06,
fontWeight: FontWeight.bold,
color: Theme.of(context).primaryColor,
),
),

const SizedBox(height: 6),

Text(
subtitle,
style: const TextStyle(
fontSize: 14,
color: Color(0xFF7A5C4E),
),
),

],
),
);
}

}
