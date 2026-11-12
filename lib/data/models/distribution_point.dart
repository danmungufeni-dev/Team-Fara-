class DistributionPoint {
  final String id;
  final String name;
  final String category;
  final double rating;
  final int reviewCount;
  final double distanceMeters;
  final int walkingTimeMinutes;
  final String address;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final bool isVerified;
  final String openHours;
  final String phone;
  final bool hasFemaleCaretaker;
  final bool hasPrivateCubicle;
  final bool hasWheelchairRamp;
  final bool hasFreeWater;
  final int stockDayPads;
  final int stockOvernightPads;
  final int stockReusableKits;
  final int stockDiscreetBags;
  final String discretionLevel;

  const DistributionPoint({
    required this.id,
    required this.name,
    required this.category,
    this.rating = 4.9,
    this.reviewCount = 128,
    required this.distanceMeters,
    required this.walkingTimeMinutes,
    required this.address,
    this.city = 'Kampala',
    this.country = 'Uganda',
    required this.latitude,
    required this.longitude,
    this.isVerified = true,
    this.openHours = 'Open • Closes 5:00 PM',
    this.phone = '+256 701 442 890',
    this.hasFemaleCaretaker = true,
    this.hasPrivateCubicle = true,
    this.hasWheelchairRamp = true,
    this.hasFreeWater = true,
    this.stockDayPads = 65,
    this.stockOvernightPads = 32,
    this.stockReusableKits = 10,
    this.stockDiscreetBags = 84,
    this.discretionLevel = '100% Confidential',
  });

  int get totalStock =>
      stockDayPads + stockOvernightPads + stockReusableKits;

  bool get isAvailable => totalStock > 0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'rating': rating,
        'review_count': reviewCount,
        'distance_meters': distanceMeters,
        'walking_time_minutes': walkingTimeMinutes,
        'address': address,
        'city': city,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
        'is_verified': isVerified,
        'open_hours': openHours,
        'phone': phone,
        'has_female_caretaker': hasFemaleCaretaker,
        'has_private_cubicle': hasPrivateCubicle,
        'has_wheelchair_ramp': hasWheelchairRamp,
        'has_free_water': hasFreeWater,
        'stock_day_pads': stockDayPads,
        'stock_overnight_pads': stockOvernightPads,
        'stock_reusable_kits': stockReusableKits,
        'stock_discreet_bags': stockDiscreetBags,
        'discretion_level': discretionLevel,
      };

  factory DistributionPoint.fromJson(Map<String, dynamic> json) =>
      DistributionPoint(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
        reviewCount: (json['review_count'] ?? json['reviewCount']) as int? ?? 128,
        distanceMeters: ((json['distance_meters'] ?? json['distanceMeters']) as num?)?.toDouble() ?? 850.0,
        walkingTimeMinutes: (json['walking_time_minutes'] ?? json['walkingTimeMinutes']) as int? ?? 11,
        address: json['address'] as String? ?? 'Kampala Central',
        city: json['city'] as String? ?? 'Kampala',
        country: json['country'] as String? ?? 'Uganda',
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0.3136,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 32.5811,
        isVerified: (json['is_verified'] ?? json['isVerified']) as bool? ?? true,
        openHours: (json['open_hours'] ?? json['openHours']) as String? ?? 'Open • Closes 5:00 PM',
        phone: json['phone'] as String? ?? '+256 701 442 890',
        hasFemaleCaretaker: (json['has_female_caretaker'] ?? json['hasFemaleCaretaker']) as bool? ?? true,
        hasPrivateCubicle: (json['has_private_cubicle'] ?? json['hasPrivateCubicle']) as bool? ?? true,
        hasWheelchairRamp: (json['has_wheelchair_ramp'] ?? json['hasWheelchairRamp']) as bool? ?? true,
        hasFreeWater: (json['has_free_water'] ?? json['hasFreeWater']) as bool? ?? true,
        stockDayPads: (json['stock_day_pads'] ?? json['stockDayPads']) as int? ?? 65,
        stockOvernightPads: (json['stock_overnight_pads'] ?? json['stockOvernightPads']) as int? ?? 32,
        stockReusableKits: (json['stock_reusable_kits'] ?? json['stockReusableKits']) as int? ?? 10,
        stockDiscreetBags: (json['stock_discreet_bags'] ?? json['stockDiscreetBags']) as int? ?? 84,
        discretionLevel: (json['discretion_level'] ?? json['discretionLevel']) as String? ?? '100% Confidential',
      );
}
