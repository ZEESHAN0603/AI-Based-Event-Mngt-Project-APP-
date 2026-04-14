import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../models/vendor.dart';
import 'vendor_list.dart';
import '../../widgets/design_system.dart';
import '../../widgets/synora_header.dart';

class VendorCategoriesScreen extends StatelessWidget {
  const VendorCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      ('Venue', Icons.home_work_outlined, VendorCategory.venue),
      ('Catering', Icons.restaurant_outlined, VendorCategory.catering),
      ('Photography', Icons.photo_camera_outlined, VendorCategory.photography),
      ('Decoration', Icons.celebration_outlined, VendorCategory.decoration),
      ('Lighting', Icons.lightbulb_outline, VendorCategory.lighting),
      ('Music', Icons.music_note_outlined, VendorCategory.music),
      ('Printing', Icons.print_outlined, VendorCategory.printing),
      ('Security', Icons.security_outlined, VendorCategory.security),
      ('Stage', Icons.layers_outlined, VendorCategory.stage),
      ('LED Wall', Icons.tv_outlined, VendorCategory.ledWall),
      ('Equipment', Icons.construction_outlined, VendorCategory.equipment),
      ('Tent', Icons.event_seat_outlined, VendorCategory.tent),
      ('Makeup', Icons.face_retouching_natural_outlined, VendorCategory.makeup),
    ];

    return Scaffold(
      body: Column(
        children: [
          const SynoraHeader(
            title: 'Categories',
            subtitle: 'Find the perfect vendor for your event',
          ),
          Expanded(
            child: AnimationLimiter(
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final (title, icon, category) = categories[index];
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    columnCount: 2,
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: _buildCategoryCard(context, title, icon, category),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, IconData icon, VendorCategory category) {
    return AnimatedPressable(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VendorListScreen(category: category)),
        );
      },
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              child: Icon(icon, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
