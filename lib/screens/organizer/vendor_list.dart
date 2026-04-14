import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../../providers/vendor_provider.dart';
import '../../models/vendor.dart';
import '../../widgets/design_system.dart';
import '../../widgets/synora_header.dart';
import '../vendors/vendor_detail_screen.dart';

class VendorListScreen extends StatelessWidget {
  final VendorCategory category;

  const VendorListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final vendorProvider = context.watch<VendorProvider>();
    final vendors = vendorProvider.getVendorsByCategory(category);

    return Scaffold(
      body: Column(
        children: [
          SynoraHeader(
            title: '${category.name} Vendors',
            subtitle: 'Recommended experts for your event',
          ),
          Expanded(
            child: FutureBuilder(
              future: Future.delayed(const Duration(milliseconds: 800)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: 4,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: GlassCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SkeletonLoader(width: double.infinity, height: 180, borderRadius: 24),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SkeletonLoader(width: MediaQuery.of(context).size.width * 0.6, height: 20),
                                  const SizedBox(height: 8),
                                  SkeletonLoader(width: MediaQuery.of(context).size.width * 0.4, height: 14),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                
                return vendors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64),
                            const SizedBox(height: 16),
                            const Text('No vendors found for this category.', style: TextStyle()),
                          ],
                        ),
                      )
                    : AnimationLimiter(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: vendors.length,
                          itemBuilder: (context, index) {
                            final vendor = vendors[index];
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: _buildVendorCard(context, vendor, vendorProvider),
                                ),
                              ),
                            );
                          },
                        ),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorCard(BuildContext context, vendor, vendorProvider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: AnimatedPressable(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VendorDetailScreen(
                vendor: {
                  'name': vendor.name,
                  'location': vendor.location,
                  'price': 'Starting at ₹${vendor.price}',
                  'imageUrl': vendor.imageUrl,
                  'rating': vendor.rating,
                },
              ),
            ),
          );
        },
        child: GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: Image.network(
                      vendor.imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 180,
                        child: const Icon(Icons.broken_image, size: 48),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GlassCard(
                      blur: 10,
                      opacity: 0.2,
                      padding: const EdgeInsets.all(4),
                      borderRadius: BorderRadius.circular(12),
                      child: IconButton(
                        icon: Icon(
                          vendor.isShortlisted ? Icons.favorite : Icons.favorite_border,
                          size: 20,
                        ),
                        onPressed: () => vendorProvider.toggleShortlist(vendor.id),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            vendor.rating,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Text(
                            'Starting at ₹${vendor.price}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendor.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          vendor.location,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
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
}
