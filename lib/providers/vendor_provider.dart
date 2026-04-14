import 'package:flutter/material.dart';
import '../models/vendor.dart';

class VendorProvider with ChangeNotifier {
  final List<Vendor> _vendors = [
    // venue
    ...List.generate(10, (i) => Vendor(
      id: 'venue_₹i',
      name: [
        'Grand Imperial Ballroom', 'Lakeside Pavilion', 'Skyline Rooftop Garden', 
        'Heritage Manor House', 'Modern Glass House', 'Secret Garden Estate', 
        'Royal Palace Hall', 'Urban Loft Space', 'Crystal Banquet Hall', 'The Lighthouse Resort'
      ][i],
      category: VendorCategory.venue,
      price: 15000.0 + (i * 3000),
      rating: (4.5 + (i % 5) / 10).toStringAsFixed(1),
      imageUrl: 'https://images.unsplash.com/photo-${[
        '1519167758481-83f550bb49b3', '1469334031218-e382a71b716b', '1519741497674-611481863552',
        '1505944270255-bd2b89657434', '1520250497591-112f2f40a3f4', '1536331745242-9908a7350c33',
        '1516483638261-f4dbaf036963', '1519225421980-715cb0215aed', '1458007683879-47560d7e33c3', '1507525428034-b723cf961d3e'
      ][i]}',
      location: 'Area ${i + 1}, City Center')),
    // catering
    ...List.generate(10, (i) => Vendor(
      id: 'catering_₹i',
      name: [
        'Elite Gourmet Catering', 'Spice Fusion Kitchen', 'Continental Delights',
        'Traditional Flavors Co.', 'Healthy Bites Express', 'Ocean Fresh Seafood',
        'Rustic Grill Masters', 'Sweet Harmony Bakery', 'The Banquet Chefs', 'Global Cuisine Hub'
      ][i],
      category: VendorCategory.catering,
      price: 8000.0 + (i * 1200),
      rating: (4.2 + (i % 8) / 10).toStringAsFixed(1),
      imageUrl: 'https://images.unsplash.com/photo-${[
        '1555244162-803834f70033', '1504674900247-0877df9cc836', '1488477181946-6428a0291777',
        '1414235077428-338989a2e8c0', '1498837167922-ddd27525d352', '1519708227418-c8fd9a32b7a2',
        '1529193591184-b1d58b34ecdf', '1530103043960-91911a30592e', '1540189549336-e6e99c3679fe', '1504754524776-8f4f37790ca0'
      ][i]}',
      location: 'Food Block ${i + 1}, North Side')),
    // photography
    ...List.generate(10, (i) => Vendor(
      id: 'photo_₹i',
      name: [
        'Pixel Perfect Studios', 'Cinematic Frames', 'Natural Light Captures',
        'Vivid Memories Photo', 'Urban Lens Collective', 'The Wedding Storytellers',
        'Aesthetic Art Hub', 'Candid Moments Lab', 'Drone View Media', 'Legacy Portraits Co.'
      ][i],
      category: VendorCategory.photography,
      price: 5000.0 + (i * 800),
      rating: (4.6 + (i % 4) / 10).toStringAsFixed(1),
      imageUrl: 'https://images.unsplash.com/photo-${[
        '1537633552985-df8429e803ed', '1493863641943-9b68992a8d07', '1492691527719-9d1e07e534b4',
        '1516035069371-29a1b244cc32', '1513519245088-0e12902e5a38', '1452587925148-ce544e77e70d',
        '1471341971476-ae15ff5dd4ea', '1508674861872-a51e06c50c9b', '1511671782779-c97d3d27a1d4', '1521334885634-9d9221dd1f90'
      ][i]}',
      location: 'Studio Lane ${i + 1}, East District')),
    // decoration
    ...List.generate(10, (i) => Vendor(
      id: 'decor_₹i',
      name: [
        'Dream Decor Designers', 'Floral Fantasy Art', 'Elegant Events Decor',
        'Minimalist Magic Themes', 'Vintage Vibe Studios', 'Royal Bloom Stylists',
        'Modern Sparkle Decor', 'Nature Inspired Events', 'Luxury Glow Themes', 'Eco-Friendly Decor Co.'
      ][i],
      category: VendorCategory.decoration,
      price: 6000.0 + (i * 1500),
      rating: (4.4 + (i % 6) / 10).toStringAsFixed(1),
      imageUrl: 'https://images.unsplash.com/photo-${[
        '1511795409834-ef04bbd61622', '1519225421980-715cb0215aed', '1533174072545-7a4b6ad7a6c3',
        '1513519245088-0e12902e5a38', '1471967183320-ee018f6e114a', '1496417263034-38ec4f0b665a',
        '1504196606672-aef5c9cefc92', '1530103043960-91911a30592e', '1510076857177-7409249ba9ad', '1416872848652-05bc8ec49110'
      ][i]}',
      location: 'Decor Square ${i + 1}, South Street')),
    // lighting
    ...List.generate(10, (i) => Vendor(
      id: 'light_₹i',
      name: [
        'Bright Horizon Lights', 'Neon Night Glow', 'Elegant Ambience Lighting',
        'Stellar Event Lights', 'Pro Stage Lighting', 'Creative Beam Studios',
        'Luminous Events Co.', 'Flash Tech Lighting', 'Sleek Light Designs', 'Vibrant Glow Systems'
      ][i],
      category: VendorCategory.lighting,
      price: 4000.0 + (i * 600),
      rating: (4.3 + (i % 7) / 10).toStringAsFixed(1),
      imageUrl: 'https://images.unsplash.com/photo-${[
        '1504196606672-aef5c9cefc92', '1510076857177-7409249ba9ad', '1533174072545-7a4b6ad7a6c3',
        '1513519245088-0e12902e5a38', '1471967183320-ee018f6e114a', '1496417263034-38ec4f0b665a',
        '1511795409834-ef04bbd61622', '1519225421980-715cb0215aed', '1530103043960-91911a30592e', '1416872848652-05bc8ec49110'
      ][i]}',
      location: 'Industrial Park ${i + 1}, West Zone')),
    // music
    ...List.generate(10, (i) => Vendor(
      id: 'music_₹i',
      name: [
        'Melody Beats Band', 'DJ Spark & Co.', 'Classical Quartet Hub',
        'Jazz Quintet Collective', 'Pop Stars Live', 'Acoustic Soul Trio',
        'Rock Rebels Band', 'Electric Beats DJ', 'Symphony Orchestra Group', 'Tribal Rhythms Live'
      ][i],
      category: VendorCategory.music,
      price: 7000.0 + (i * 2000),
      rating: (4.7 + (i % 3) / 10).toStringAsFixed(1),
      imageUrl: 'https://images.unsplash.com/photo-${[
        '1514525253361-bee8d4a9cf2a', '1516280440614-37939bbacd81', '1511671782779-c97d3d27a1d4',
        '1511192336575-5a79af67a629', '1501386761578-eac5c94b800a', '1510915363354-94301569427e',
        '1521334885634-9d9221dd1f90', '1470225620780-dba8ba36b745', '1465847899034-d174fc591143', '1514525253361-bee8d4a9cf2a'
      ][i]}',
      location: 'Music District ${i + 1}, Midtown')),
    // printing
    ...List.generate(10, (i) => Vendor(
      id: 'print_₹i',
      name: [
        'Royal Print House', 'Color Splash Banners', 'Elite Invitations Co.',
        'Modern Print Solutions', 'Grand Signage Media', 'Precision Printing Hub',
        'Creative Cards Studio', 'Impact Banner House', 'Urban Print Collective', 'Luxury Invite Designers'
      ][i],
      category: VendorCategory.printing,
      price: 2000.0 + (i * 500),
      rating: (4.1 + (i % 9) / 10).toStringAsFixed(1),
      imageUrl: 'https://images.unsplash.com/photo-${[
        '1512486130939-2c4f79935e4f', '1562654501-a0cee0fd72d4', '1586075010620-2dca4b766850',
        '1572021335469-3171624c969c', '1504868584819-f8e905263543', '1524334228333-0f6db392f8a1',
        '1563986768609-322da13575f3', '1522202176988-66273c2fd55f', '1512486130939-2c4f79935e4f', '1562654501-a0cee0fd72d4'
      ][i]}',
      location: 'Print Hub ${i + 1}, North Plaza')),
    // security
    ...List.generate(10, (i) => Vendor(
      id: 'sec_₹i',
      name: [
        'Secure Guard Force', 'Elite Protection Services', 'Event Security Masters',
        'Safe Guard Pro', 'Ultimate Security Co.', 'Professional Watchmen Group',
        'Titan Guard Systems', 'Vanguard Security Lab', 'Assure Protection Hub', 'Guardian Event Security'
      ][i],
      category: VendorCategory.security,
      price: 10000.0 + (i * 2500),
      rating: (4.8 + (i % 2) / 10).toStringAsFixed(1),
      imageUrl: 'https://images.unsplash.com/photo-${[
        '1531297484001-80022131f5a1', '1584433144859-1fc3ab844153', '1557597774-9d273605dfa9',
        '1504221507732-5246c045949b', '1576091160550-2173bdd99802', '1454165833267-fe73c82d482a',
        '1521791136064-7986c29596ba', '1531297484001-80022131f5a1', '1584433144859-1fc3ab844153', '1557597774-9d273605dfa9'
      ][i]}',
      location: 'Safety Zone ${i + 1}, South Gate')),
    // stage
    ...List.generate(10, (i) => Vendor(
      id: 'stage_₹i',
      name: [
        'Grand Stage Crafters', 'Elite Podium Design', 'Spectacular Stages Co.',
        'Pro Set Designers', 'Modern Event Stages', 'Royal Platform Artists',
        'Creative Stage Tech', 'Iconic Set Builders', 'Dynamic Stage Hub', 'Master Stagecraft Co.'
      ][i],
      category: VendorCategory.stage,
      price: 12000.0 + (i * 3000),
      rating: (4.5 + (i % 5) / 10).toStringAsFixed(1),
      imageUrl: 'https://images.unsplash.com/photo-${[
        '1470225620780-dba8ba36b745', '1492684223066-81342ee5ff30', '1429962714451-bb934ccf42a5',
        '1501281668745-f7f57925c3b4', '1514525253361-bee8d4a9cf2a', '1459749411177-042180b7d744',
        '1486591978090-5838699bf495', '1470225620780-dba8ba36b745', '1492684223066-81342ee5ff30', '1429962714451-bb934ccf42a5'
      ][i]}',
      location: 'Event Grounds ${i + 1}, East Park')),
    // ledWall
    ...List.generate(10, (i) => Vendor(
      id: 'led_₹i',
      name: [
        'Crystal View LED Walls', 'Immersive Visual Walls', 'High-Def Display Hub',
        'Bright Pixel LED', 'Cinematic Backdrop Pro', 'Elite LED Solutions',
        'Pro Visual Tech', 'Stellar Backdrops Co.', 'Infinite Display Media', 'Master Visual LED'
      ][i],
      category: VendorCategory.ledWall,
      price: 20000.0 + (i * 5000),
      rating: (4.7 + (i % 3) / 10).toStringAsFixed(1),
      imageUrl: 'https://images.unsplash.com/photo-${[
        '1522202176988-66273c2fd55f', '1512486130939-2c4f79935e4f', '1504868584819-f8e905263543',
        '1572021335469-3171624c969c', '1562654501-a0cee0fd72d4', '1586075010620-2dca4b766850',
        '1522202176988-66273c2fd55f', '1512486130939-2c4f79935e4f', '1504868584819-f8e905263543', '1572021335469-3171624c969c'
      ][i]}',
      location: 'Tech Valley ${i + 1}, Industrial Zone')),
    // equipment
    ...List.generate(10, (i) => Vendor(
      id: 'equip_₹i',
      name: [
        'Elite Gear Rentals', 'Pro AV Solutions', 'Event Tech Rentals',
        'Grand Audio-Visual', 'Sound & Vision Hub', 'Techno Equipment Co.',
        'Precision Gear House', 'Master Rental Solutions', 'Ultimate Tech Hub', 'Pro Event Rentals'
      ][i],
      category: VendorCategory.equipment,
      price: 5000.0 + (i * 1000),
      rating: (4.2 + (i % 8) / 10).toStringAsFixed(1),
      imageUrl: 'https://images.unsplash.com/photo-${[
        '1492144534655-ae79c964c9d7', '1516280440614-37939bbacd81', '1511671782779-c97d3d27a1d4',
        '1511192336575-5a79af67a629', '1501386761578-eac5c94b800a', '1510915363354-94301569427e',
        '1521334885634-9d9221dd1f90', '1470225620780-dba8ba36b745', '1465847899034-d174fc591143', '1514525253361-bee8d4a9cf2a'
      ][i]}',
      location: 'Warehouse District ${i + 1}, West Bay')),
    // tent
    ...List.generate(10, (i) => Vendor(
      id: 'tent_₹i',
      name: [
        'Royal Canopy Tents', 'Grand Marquee Designs', 'Shelter & Seating Co.',
        'Elite Event Tentage', 'The Pavillion Group', 'Master Tent Makers',
        'Luxury Outdoor Covers', 'Pro Seating Solutions', 'Elegant Canopy Hub', 'Ultimate Tent Co.'
      ][i],
      category: VendorCategory.tent,
      price: 8000.0 + (i * 1500),
      rating: (4.4 + (i % 6) / 10).toStringAsFixed(1),
      imageUrl: 'https://images.unsplash.com/photo-${[
        '1533174072545-7a4b6ad7a6c3', '1416872848652-05bc8ec49110', '1511795409834-ef04bbd61622',
        '1519225421980-715cb0215aed', '1530103043960-91911a30592e', '1510076857177-7409249ba9ad',
        '1513519245088-0e12902e5a38', '1471967183320-ee018f6e114a', '1496417263034-38ec4f0b665a', '1504196606672-aef5c9cefc92'
      ][i]}',
      location: 'Open Plaza ${i + 1}, Outer Ring')),
    // makeup
    ...List.generate(10, (i) => Vendor(
      id: 'makeup_₹i',
      name: [
        'Elite Makeover Studios', 'Glow Beauty Bar', 'The Bridal Artists',
        'Radiant Glam Co.', 'Luxe Makeup Artistry', 'Pure Elegance Salon',
        'Velvet Finish Artists', 'Aura Beauty Hub', 'Iconic Makeover Lab', 'Supreme Glam Studios'
      ][i],
      category: VendorCategory.makeup,
      price: 3000.0 + (i * 800),
      rating: (4.9 + (i % 1) / 10).toStringAsFixed(1),
      imageUrl: 'https://images.unsplash.com/photo-${[
        '1522335789203-aabd1fc54bc9', '1487412720507-e7ab37603c6f', '1512496015851-a90fb38ba496',
        '1522337621163-549113fa1516', '1487412720507-e7ab37603c6f', '1512496015851-a90fb38ba496',
        '1522335789203-aabd1fc54bc9', '1487412720507-e7ab37603c6f', '1512496015851-a90fb38ba496', '1522337621163-549113fa1516'
      ][i]}',
      location: 'Beauty Row ${i + 1}, Uptown')),
    // Pending Vendors for Admin
    Vendor(
      id: 'pending_1',
      name: 'Elite Catering Services',
      category: VendorCategory.catering,
      price: 15000,
      rating: '4.8',
      imageUrl: 'https://images.unsplash.com/photo-1555244162-803834f70033',
      location: 'Downtown, Sector 5',
      status: VendorStatus.pending,
    ),
    Vendor(
      id: 'pending_2',
      name: 'Dream Decorators',
      category: VendorCategory.decoration,
      price: 12000,
      rating: '4.5',
      imageUrl: 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622',
      location: 'West side, Block B',
      status: VendorStatus.pending,
    ),
    Vendor(
      id: 'pending_3',
      name: 'Pro Focus Studio',
      category: VendorCategory.photography,
      price: 10000,
      rating: '4.9',
      imageUrl: 'https://images.unsplash.com/photo-1537633552985-df8429e803ed',
      location: 'East Park, Studio 10',
      status: VendorStatus.pending,
    ),
  ];

  List<Vendor> get vendors => _vendors;

  List<Vendor> get pendingVendors => _vendors.where((v) => v.status == VendorStatus.pending).toList();

  List<Vendor> getShortlistedVendors() {
    return _vendors.where((v) => v.isShortlisted).toList();
  }

  List<Vendor> getVendorsByCategory(VendorCategory category) {
    return _vendors.where((v) => v.category == category).toList();
  }

  void updateVendorStatus(String vendorId, VendorStatus status) {
    final index = _vendors.indexWhere((v) => v.id == vendorId);
    if (index != -1) {
      _vendors[index].status = status;
      notifyListeners();
    }
  }

  void toggleShortlist(String vendorId) {
    final index = _vendors.indexWhere((v) => v.id == vendorId);
    if (index != -1) {
      _vendors[index].isShortlisted = !_vendors[index].isShortlisted;
      notifyListeners();
    }
  }

  void bookVendor(String vendorId) {
    final index = _vendors.indexWhere((v) => v.id == vendorId);
    if (index != -1) {
      _vendors[index].isBooked = true;
      notifyListeners();
    }
  }
}
