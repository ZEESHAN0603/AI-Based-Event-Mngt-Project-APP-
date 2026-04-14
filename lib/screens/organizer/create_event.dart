import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'vendor_categories.dart';
import '../../models/vendor.dart';
import '../../providers/vendor_provider.dart';
import 'package:provider/provider.dart';
import '../../widgets/glass_container.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _budgetController = TextEditingController();
  final _locationController = TextEditingController();
  final _guestsController = TextEditingController();
  String _selectedType = 'Wedding';
  DateTime _selectedDate = DateTime.now();
  final Set<String> _selectedServices = {};

  final List<String> _eventTypes = [
    'Wedding',
    'Birthday',
    'College Events',
    'Family Functions',
    'Indian Functions',
  ];

  final Map<String, List<Map<String, String>>> _recommendations = {
    'Wedding': [
      {'id': 'venue', 'name': 'Venue', 'desc': 'Find the perfect place'},
      {'id': 'catering', 'name': 'Catering', 'desc': 'Delicious food and drinks'},
      {'id': 'photography', 'name': 'Photography', 'desc': 'Capture every moment'},
      {'id': 'decoration', 'name': 'Decoration', 'desc': 'Beautiful theme & flowers'},
      {'id': 'makeup', 'name': 'Makeup', 'desc': 'Professional bridal makeup'},
      {'id': 'music', 'name': 'DJ / Music', 'desc': 'Live music and DJ sets'},
      {'id': 'lighting', 'name': 'Lighting Setup', 'desc': 'Ambient and stage lights'},
    ],
    'Birthday': [
      {'id': 'decoration', 'name': 'Decoration', 'desc': 'Balloons, banners & themes'},
      {'id': 'catering', 'name': 'Catering', 'desc': 'Cake, snacks and dinner'},
      {'id': 'photography', 'name': 'Photography', 'desc': 'Birthday memories'},
      {'id': 'music', 'name': 'DJ / Music', 'desc': 'Dance and party mix'},
    ],
    'Family Functions': [
      {'id': 'venue', 'name': 'Venue', 'desc': 'Family-friendly space'},
      {'id': 'catering', 'name': 'Catering', 'desc': 'Home-style buffet'},
      {'id': 'decoration', 'name': 'Decoration', 'desc': 'Subtle & elegant decor'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _updateRecommendations();
  }

  void _updateRecommendations() {
    _selectedServices.clear();
    final recs = _recommendations[_selectedType] ?? _recommendations['Family Functions']!;
    for (var rec in recs) {
      _selectedServices.add(rec['id']!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                _buildSectionTitle('Event Basics'),
                const SizedBox(height: 16),
                _buildTextField(_nameController, 'Event Name', 'e.g. Smith & Doe Wedding', Icons.title),
                const SizedBox(height: 16),
                _buildDropdownField(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_budgetController, 'Total Budget (₹)', 'e.g. 25000', Icons.attach_money, isNumber: true)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(_guestsController, 'Guests (Optional)', 'e.g. 500', Icons.people, isNumber: true)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(_locationController, 'Event Location', 'e.g. Chennai, India', Icons.location_on),
                const SizedBox(height: 16),
                _buildDatePicker(),
                const SizedBox(height: 32),
                _buildSectionTitle('Recommended Services'),
                const SizedBox(height: 8),
                Text('Based on your event type, we suggest:', style: TextStyle(fontSize: 13)),
                const SizedBox(height: 16),
                _buildServiceSelection(),
                const SizedBox(height: 32),
                _buildSectionTitle('Nearby Vendors'),
                const SizedBox(height: 16),
                _buildNearbyVendors(),
                const SizedBox(height: 40),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
      validator: (value) => !isNumber && (value == null || value.isEmpty) ? 'Please enter $label' : null,
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedType,
      decoration: InputDecoration(
        labelText: 'Event Type',
        prefixIcon: const Icon(Icons.category),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        fillColor: Theme.of(context).cardColor,
      ),
      items: _eventTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedType = value;
            _updateRecommendations();
          });
        }
      },
    );
  }

  Widget _buildDatePicker() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: const Text('Event Date'),
        subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
        leading: const Icon(Icons.calendar_today),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime.now(),
            lastDate: DateTime(2030),
          );
          if (picked != null) setState(() => _selectedDate = picked);
        },
      ),
    );
  }

  Widget _buildServiceSelection() {
    final recs = _recommendations[_selectedType] ?? _recommendations['Family Functions']!;
    return Column(
      children: recs.map((service) {
        final isSelected = _selectedServices.contains(service['id']);
        return GlassContainer(
          child: ListTile(
            leading: Checkbox(
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value!) _selectedServices.add(service['id']!);
                  else _selectedServices.remove(service['id']!);
                });
              },
            ),
            title: Text(service['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(service['desc']!, style: const TextStyle(fontSize: 12)),
            trailing: TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const VendorCategoriesScreen()));
              },
              child: const Text('View Vendors'),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNearbyVendors() {
    final location = _locationController.text.isEmpty ? 'your area' : _locationController.text;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Showing top-rated vendors in $location',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.15,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                width: 150,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-${index == 0 ? "1519167758481-83f550bb49b3" : "1555244162-803834f70033"}'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.3), BlendMode.darken),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Top Vendor ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                      const Row(
                        children: [
                          Icon(Icons.star, size: 10, color: Colors.amber),
                          Text(' 4.9', style: TextStyle(fontSize: 10, color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Event Created Successfully!')),
            );
            Navigator.pop(context);
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        child: const Text('Create Event', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}