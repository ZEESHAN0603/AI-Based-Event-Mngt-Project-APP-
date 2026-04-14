import 'package:flutter/material.dart';
import '../../widgets/design_system.dart';
import '../../widgets/synora_header.dart';

class VendorProfileScreen extends StatefulWidget {
  const VendorProfileScreen({super.key});

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  bool _isEditing = false;
  
  final _nameController = TextEditingController(text: 'Elite Catering Services');
  final _categoryController = TextEditingController(text: 'Professional Caterers');
  final _locationController = TextEditingController(text: 'Mumbai, India');
  final _pricingController = TextEditingController(text: 'Starting from ₹1,000/Plate');
  final _descriptionController = TextEditingController(text: 'We provide premium catering services for weddings, corporate events, and private parties with a focus on taste and hygiene.');

  final List<String> _portfolioImages = [
    'https://images.unsplash.com/photo-1555244162-803834f70033',
    'https://images.unsplash.com/photo-1594132225294-db29211d8d9f',
    'https://images.unsplash.com/photo-1547820121-6f0923069158',
    'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1',
    'https://images.unsplash.com/photo-1504674900247-0877df9cc836',
    'https://images.unsplash.com/photo-1441986300917-64674bd600d8',
  ];

  void _toggleEdit() {
    setState(() {
      if (_isEditing) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!')));
      }
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleEdit,
        label: Text(_isEditing ? 'Save Profile' : 'Edit Profile'),
        icon: Icon(_isEditing ? Icons.save_outlined : Icons.edit_outlined),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SynoraHeader(
            title: 'Vendor Profile',
            subtitle: 'Your business presence',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 32),
                  _buildEditableField('Business Name', _nameController, Icons.business_outlined),
                  _buildEditableField('Category', _categoryController, Icons.category_outlined),
                  _buildEditableField('Location', _locationController, Icons.location_on_outlined),
                  _buildEditableField('Pricing', _pricingController, Icons.attach_money_outlined),
                  const Text('About Us', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _isEditing 
                      ? GlassCard(
                          child: TextField(
                            controller: _descriptionController,
                            maxLines: 4,
                            decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(16)),
                          ),
                        )
                      : GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            _descriptionController.text,
                            style: TextStyle(fontSize: 14, height: 1.6),
                          ),
                        ),
                  const SizedBox(height: 32),
                    const Text('Portfolio Grid', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildPortfolioGrid(),
                    const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(width: 2),
            ),
            child: SynoraAvatar(name: _nameController.text, size: 80),
          ),
          if (_isEditing)
            Positioned(
              bottom: 0,
              right: 0,
              child: AnimatedPressable(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                  child: const Icon(Icons.camera_alt_outlined, size: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPortfolioGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemCount: _portfolioImages.length,
      itemBuilder: (context, index) {
        return AnimatedPressable(
          onTap: () {},
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(_portfolioImages[index], fit: BoxFit.cover),
          ),
        );
      },
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          _isEditing 
            ? GlassCard(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    prefixIcon: Icon(icon, size: 20, ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              )
            : Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, size: 18),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      controller.text,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
        ],
      ),
    );
  }
}
