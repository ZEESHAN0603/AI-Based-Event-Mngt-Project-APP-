import 'package:flutter/material.dart';
import '../../widgets/glass_container.dart';

class VendorReviewsScreen extends StatelessWidget {
  const VendorReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> reviews = [
      {'name': 'Amit Pathak', 'rating': '5', 'date': '12 Mar 2024', 'comment': 'The food was absolutely delicious! Every guest praised the catering. Highly recommended for weddings.'},
      {'name': 'Sangeeta Roy', 'rating': '4', 'date': '10 Mar 2024', 'comment': 'Very professional team. They managed the crowd well, though the dessert refill was a bit slow.'},
      {'name': 'Vikram Malhotra', 'rating': '5', 'date': '08 Mar 2024', 'comment': 'Top-notch service. The presentation was elegant and the staff was extremely polite.'},
      {'name': 'Neha Gupta', 'rating': '5', 'date': '05 Mar 2024', 'comment': 'Synora recommended them for my engagement. Best decision ever! The snacks were the highlight.'},
      {'name': 'Rajesh Khanna', 'rating': '3', 'date': '01 Mar 2024', 'comment': 'Food was good but the communication before the event could have been better.'},
      {'name': 'Priya Sharma', 'rating': '5', 'date': '28 Feb 2024', 'comment': 'The menu customization they offered was great. Everyone loved the traditional dishes.'},
      {'name': 'Anil Kapoor', 'rating': '4', 'date': '25 Feb 2024', 'comment': 'Punctual and efficient. They handled the corporate lunch with great grace.'},
      {'name': 'Kavita Singh', 'rating': '5', 'date': '20 Feb 2024', 'comment': 'Exceptional taste and hygiene. Will definitely book them again for family functions.'},
      {'name': 'Suresh Raina', 'rating': '4', 'date': '15 Feb 2024', 'comment': 'Great value for money. The mocktail bar was a huge hit with the youngsters.'},
      {'name': 'Meera Das', 'rating': '5', 'date': '10 Feb 2024', 'comment': 'Superb service from start to finish. They made our anniversary dinner truly special.'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Customer Reviews')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final r = reviews[index];
          final double rating = double.parse(r['rating']!);
          return GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(r['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(r['date']!, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ...List.generate(5, (i) => Icon(
                        i < rating ? Icons.star : Icons.star_border,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      )),
                      const SizedBox(width: 8),
                      Text(r['rating']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    r['comment']!,
                    style: const TextStyle(height: 1.4),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
