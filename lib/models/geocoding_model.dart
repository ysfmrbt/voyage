class GeocodingResult {
  final List<CityLocation> results;
  final double generationtimeMs;

  GeocodingResult({required this.results, required this.generationtimeMs});

  factory GeocodingResult.fromJson(Map<String, dynamic> json) {
    return GeocodingResult(
      results:
          (json['results'] as List?)
              ?.map((e) => CityLocation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      generationtimeMs:
          (json['generationtime_ms'] is int)
              ? (json['generationtime_ms'] as int).toDouble()
              : json['generationtime_ms'] as double,
    );
  }
}

class CityLocation {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final int? elevation;
  final String? featureCode;
  final String? countryCode;
  final String? timezone;
  final int? population;
  final List<String>? postcodes;
  final String? country;
  final String? admin1;
  final String? admin2;
  final String? admin3;
  final String? admin4;

  CityLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.elevation,
    this.featureCode,
    this.countryCode,
    this.timezone,
    this.population,
    this.postcodes,
    this.country,
    this.admin1,
    this.admin2,
    this.admin3,
    this.admin4,
  });

  factory CityLocation.fromJson(Map<String, dynamic> json) {
    return CityLocation(
      id: json['id'] as int,
      name: json['name'] as String,
      latitude:
          (json['latitude'] is int)
              ? (json['latitude'] as int).toDouble()
              : json['latitude'] as double,
      longitude:
          (json['longitude'] is int)
              ? (json['longitude'] as int).toDouble()
              : json['longitude'] as double,
      elevation:
          json['elevation'] != null ? _parseIntOrNull(json['elevation']) : null,
      featureCode: json['feature_code'] as String?,
      countryCode: json['country_code'] as String?,
      timezone: json['timezone'] as String?,
      population:
          json['population'] != null
              ? _parseIntOrNull(json['population'])
              : null,
      postcodes: (json['postcodes'] as List?)?.map((e) => e as String).toList(),
      country: json['country'] as String?,
      admin1: json['admin1'] as String?,
      admin2: json['admin2'] as String?,
      admin3: json['admin3'] as String?,
      admin4: json['admin4'] as String?,
    );
  }

  // Helper method to safely parse an integer or null
  static int? _parseIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    return int.parse(value.toString());
  }

  // Helper method to get a formatted display name
  String get displayName {
    final parts = <String>[];
    if (name.isNotEmpty) {
      parts.add(name);
    }
    if (admin1 != null && admin1!.isNotEmpty && admin1 != name) {
      parts.add(admin1!);
    }
    if (country != null && country!.isNotEmpty) {
      parts.add(country!);
    }

    return parts.join(', ');
  }
}
