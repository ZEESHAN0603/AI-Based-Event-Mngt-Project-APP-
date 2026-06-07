import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../providers/vendor_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/design_system.dart';
import '../../widgets/synora_header.dart';
import 'vendor_list.dart';

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

  IconData _iconFor(String name) {
    name = name.toLowerCase();
    if (name.contains('venue')) return Icons.home_work_outlined;
    if (name.contains('cater')) return Icons.restaurant_outlined;
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

  // Unique gradient per index
  List<Color> _gradientFor(int index) {
    const palettes = [
      [Color(0xFF6366F1), Color(0xFF818CF8)],
      [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
      [Color(0xFFEC4899), Color(0xFFF472B6)],
      [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
      [Color(0xFF10B981), Color(0xFF34D399)],
      [Color(0xFFF59E0B), Color(0xFFFBBF24)],
      [Color(0xFFEF4444), Color(0xFFF87171)],
      [Color(0xFF14B8A6), Color(0xFF2DD4BF)],
    ];
    return palettes[index % palettes.length];
  }

  @override
  Widget build(BuildContext context) {
    final vendorProvider = context.watch<VendorProvider>();
    final categories = vendorProvider.categories;

    return Scaffold(
      body: Column(
        children: [
          const SynoraHeader(
            title: 'Vendor Categories',
            subtitle: 'Find the perfect vendor for your event',
          ),
          Expanded(
            child: vendorProvider.isLoading && categories.isEmpty
                ? _buildSkeleton()
                : categories.isEmpty
                    ? const AppEmptyState(
                        icon: Icons.category_rounded,
                        title: 'No Categories Found',
                        subtitle: 'Vendor categories are not available yet.',
                      )
                    : AnimationLimiter(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final cat = categories[index];
                            final id = cat['id'].toString();
                            final name = cat['name'].toString();
                            return AnimationConfiguration.staggeredGrid(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              columnCount: 2,
                              child: ScaleAnimation(
                                child: FadeInAnimation(
                                  child: _categoryCard(
                                      context, id, name, index),
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

  Widget _categoryCard(
      BuildContext context, String id, String name, int index) {
    final colors = _gradientFor(index);
    final icon = _iconFor(name);

    return AnimatedPressable(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VendorListScreen(
            categoryId: id,
            categoryName: name,
            event: widget.event,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient:
              LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -12,
              bottom: -12,
              child: Icon(icon,
                  size: 72, color: Colors.white.withValues(alpha: 0.12)),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                  const Spacer(),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text('Browse →',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return GridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 1.0,
      children: List.generate(
        8,
        (_) => const SkeletonLoader(
            width: double.infinity,
            height: double.infinity,
            borderRadius: 20),
      ),
    );
  }
}
