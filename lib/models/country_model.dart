class CountryModel {
  final String name;
  final List<String> topLevelDomain;
  final String alpha2Code;
  final String alpha3Code;
  final List<String> callingCodes;
  final String? capital;
  final List<String> altSpellings;
  final String? subregion;
  final String? region;
  final int population;
  final List<double> latlng;
  final String? demonym;
  final double? area;
  final double? gini;
  final List<String> timezones;
  final List<String> borders;
  final String? nativeName;
  final String? numericCode;
  final Flags flags;
  final List<Currency> currencies;
  final List<Language> languages;
  final Map<String, String> translations;
  final String? flag;
  final List<RegionalBloc> regionalBlocs;
  final String? cioc;
  final bool independent;

  CountryModel({
    required this.name,
    required this.topLevelDomain,
    required this.alpha2Code,
    required this.alpha3Code,
    required this.callingCodes,
    this.capital,
    required this.altSpellings,
    this.subregion,
    this.region,
    required this.population,
    required this.latlng,
    this.demonym,
    this.area,
    this.gini,
    required this.timezones,
    required this.borders,
    this.nativeName,
    this.numericCode,
    required this.flags,
    required this.currencies,
    required this.languages,
    required this.translations,
    this.flag,
    required this.regionalBlocs,
    this.cioc,
    required this.independent,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      name: json['name'] as String,
      topLevelDomain:
          json['topLevelDomain'] != null
              ? List<String>.from(json['topLevelDomain'])
              : [],
      alpha2Code: json['alpha2Code'] as String,
      alpha3Code: json['alpha3Code'] as String,
      callingCodes:
          json['callingCodes'] != null
              ? List<String>.from(json['callingCodes'])
              : [],
      capital: json['capital'] as String?,
      altSpellings:
          json['altSpellings'] != null
              ? List<String>.from(json['altSpellings'])
              : [],
      subregion: json['subregion'] as String?,
      region: json['region'] as String?,
      population: json['population'] as int,
      latlng:
          json['latlng'] != null
              ? List<double>.from(
                json['latlng'].map((x) => x is int ? x.toDouble() : x),
              )
              : [],
      demonym: json['demonym'] as String?,
      area:
          json['area'] != null
              ? (json['area'] is int
                  ? (json['area'] as int).toDouble()
                  : json['area'] as double)
              : null,
      gini:
          json['gini'] != null
              ? (json['gini'] is int
                  ? (json['gini'] as int).toDouble()
                  : json['gini'] as double)
              : null,
      timezones:
          json['timezones'] != null ? List<String>.from(json['timezones']) : [],
      borders:
          json['borders'] != null ? List<String>.from(json['borders']) : [],
      // Utiliser directement la valeur sans conversion pour préserver les caractères spéciaux
      nativeName: json['nativeName'] as String?,
      numericCode: json['numericCode'] as String?,
      flags:
          json['flags'] != null
              ? Flags.fromJson(json['flags'])
              : Flags(svg: '', png: ''),
      currencies:
          json['currencies'] != null
              ? List<Currency>.from(
                json['currencies'].map((x) => Currency.fromJson(x)),
              )
              : [],
      languages:
          json['languages'] != null
              ? List<Language>.from(
                json['languages'].map((x) => Language.fromJson(x)),
              )
              : [],
      translations:
          json['translations'] != null
              ? Map<String, String>.from(json['translations'])
              : {},
      flag: json['flag'] as String?,
      regionalBlocs:
          json['regionalBlocs'] != null
              ? List<RegionalBloc>.from(
                json['regionalBlocs'].map((x) => RegionalBloc.fromJson(x)),
              )
              : [],
      cioc: json['cioc'] as String?,
      independent: json['independent'] as bool,
    );
  }
}

class Flags {
  final String svg;
  final String png;

  Flags({required this.svg, required this.png});

  factory Flags.fromJson(Map<String, dynamic> json) {
    return Flags(
      svg: json['svg'] as String? ?? '',
      png: json['png'] as String? ?? '',
    );
  }
}

class Currency {
  final String code;
  final String name;
  final String symbol;

  Currency({required this.code, required this.name, required this.symbol});

  factory Currency.fromJson(Map<String, dynamic> json) {
    // Utiliser directement les valeurs sans conversion pour préserver les caractères spéciaux
    return Currency(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
    );
  }
}

class Language {
  final String iso639_1;
  final String iso639_2;
  final String name;
  final String nativeName;

  Language({
    required this.iso639_1,
    required this.iso639_2,
    required this.name,
    required this.nativeName,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    // Utiliser directement les valeurs sans conversion pour préserver les caractères spéciaux
    return Language(
      iso639_1: json['iso639_1'] as String? ?? '',
      iso639_2: json['iso639_2'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nativeName: json['nativeName'] as String? ?? '',
    );
  }
}

class RegionalBloc {
  final String acronym;
  final String name;
  final List<String>? otherNames;

  RegionalBloc({required this.acronym, required this.name, this.otherNames});

  factory RegionalBloc.fromJson(Map<String, dynamic> json) {
    // Utiliser directement les valeurs sans conversion pour préserver les caractères spéciaux
    return RegionalBloc(
      acronym: json['acronym'] as String? ?? '',
      name: json['name'] as String? ?? '',
      otherNames:
          json['otherNames'] != null
              ? List<String>.from(json['otherNames'])
              : null,
    );
  }
}
