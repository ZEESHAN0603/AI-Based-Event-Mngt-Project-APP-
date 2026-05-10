import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../providers/vendor_provider.dart';
import 'vendor_list.dart';
import '../../widgets/design_system.dart';
import '../../widgets/synora_header.dart';

class VendorCategoriesScreen extends StatefulWidget {
  final Event? event;

  const VendorCategoriesScreen({super.key, this.event});

  @override
  State<VendorCategoriesScreen> createState() => _VendorCategoriesScreenState();
}

class _VendorCategoriesScreenState extends State<VendorCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorProvider>().fetchCategories();
    });
  }

  IconData _getIconForCategory(String name) {
    name = name.toLowerCase();
    if (name.contains('venue')) return Icons.home_work_outlined;
    if (name.contains('catering')) return Icons.restaurant_outlined;
    if (name.contains('photo')) return Icons.photo_camera_outlined;
    if (name.contains('decor')) return Icons.celebration_outlined;
    if (name.contains('light')) return Icons.lightbulb_outline;
    if (name.contains('music')) return Icons.music_note_outlined;
    if (name.contains('print')) return Icons.print_outlined;
    if (name.contains('security')) return Icons.security_outlined;
    if (name.contains('stage')) return Icons.layers_outlined;
    if (name.contains('led')) return Icons.tv_outlined;
    if (name.contains('equip')) return Icons.construction_outlined;
    if (name.contains('tent')) return Icons.event_seat_outlined;
    if (name.contains('makeup')) return Icons.face_retouching_natural_outlined;
    return Icons.category_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final vendorProvider = context.watch<VendorProvider>();
    final categories = vendorProvider.categories;

    return Scaffold(
      body: Column(
        children: [
          const SynoraHeader(
            title: 'Categories',
            subtitle: 'Find the perfect vendor for your event',
          ),
          Expanded(
            child: vendorProvider.isLoading && categories.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : categories.isEmpty
                    ? _buildEmptyState()
                    : AnimationLimiter(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final id = category['id'].toString();
                            final name = category['name'].toString();
                            
                            return AnimationConfiguration.staggeredGrid(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              columnCount: 2,
                              child: ScaleAnimation(
                                child: FadeInAnimation(
                                  child: _buildCategoryCard(context, id, name),
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

  Widget _buildEmptyState() {
    return const Center(
      child: Text('No categories found.', style: TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String id, String name) {
    final icon = _getIconForCategory(name);
    return AnimatedPressable(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VendorListScreen(
              categoryId: id,
              categoryName: name,
              event: widget.event,
            ),
          ),
        );
      },
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 16),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
