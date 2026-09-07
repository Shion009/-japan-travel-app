import '../data/spot_extended_data.dart';

class Region {
  final String id;
  final String th;
  final String jp;

  Region({required this.id, required this.th, required this.jp});

  factory Region.fromJson(Map<String, dynamic> json) => Region(
        id: json['id'] as String,
        th: json['th'] as String,
        jp: json['jp'] as String,
      );
}

class SpotCategory {
  final String id;
  final String th;

  SpotCategory({required this.id, required this.th});

  factory SpotCategory.fromJson(Map<String, dynamic> json) => SpotCategory(
        id: json['id'] as String,
        th: json['th'] as String,
      );
}

class Spot {
  final String id;
  final String name;
  final String nameJp;
  final String region;
  final String category;
  final String season;
  final String blurb;
  final String detail;
  final String highlight;
  final String? imageUrl;

  // Extended travel info
  final String openingHours;
  final String fee;
  final String address;
  final String access;
  final String recommendedDuration;
  final String bestTime;
  final String tips;
  final List<String> activities;
  final double rating;
  final String coordinates;
  final String seasonalAdvice;

  Spot({
    required this.id,
    required this.name,
    required this.nameJp,
    required this.region,
    required this.category,
    required this.season,
    required this.blurb,
    required this.detail,
    required this.highlight,
    this.imageUrl,
    required this.openingHours,
    required this.fee,
    required this.address,
    required this.access,
    required this.recommendedDuration,
    required this.bestTime,
    required this.tips,
    required this.activities,
    required this.rating,
    required this.coordinates,
    required this.seasonalAdvice,
  });

  factory Spot.fromJson(Map<String, dynamic> json) {
    final spotId = json['id'].toString();
    final cat = json['category'] as String? ?? '';
    final seas = json['season'] as String? ?? '';
    final extra = getSpotExtraInfo(spotId, category: cat, season: seas);

    List<String> parsedActivities = extra.activities;
    if (json['activities'] is List) {
      parsedActivities = (json['activities'] as List).map((e) => e.toString()).toList();
    }

    return Spot(
      id: spotId,
      name: json['name'] as String,
      nameJp: json['nameJp'] as String,
      region: json['region'] as String,
      category: cat,
      season: seas,
      blurb: json['blurb'] as String,
      detail: json['detail'] as String,
      highlight: json['highlight'] as String,
      imageUrl: json['imageUrl'] as String?,
      openingHours: json['openingHours'] as String? ?? extra.openingHours,
      fee: json['fee'] as String? ?? extra.fee,
      address: json['address'] as String? ?? extra.address,
      access: json['access'] as String? ?? extra.access,
      recommendedDuration: json['recommendedDuration'] as String? ?? extra.recommendedDuration,
      bestTime: json['bestTime'] as String? ?? extra.bestTime,
      tips: json['tips'] as String? ?? extra.tips,
      activities: parsedActivities,
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : extra.rating,
      coordinates: json['coordinates'] as String? ?? extra.coordinates,
      seasonalAdvice: json['seasonalAdvice'] as String? ?? extra.seasonalAdvice,
    );
  }
}
