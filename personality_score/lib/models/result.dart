class Result {
  final String userUUID;
  final String resultsX;
  final int combinedTotalScore;
  final DateTime completionDate;
  final String finalCharacter;
  final String finalCharacterDescription;

  // Lebensbereiche
  final int selbstwerterhoehung;
  final int zielsetzung;
  final int weiterbildung;
  final int finanzen;
  final int karriere;
  final int fitness;
  final int energie;
  final int produktivitaet;
  final int stressmanagement;
  final int resilienz;
  final int innerCoreInnerChange;
  final int emotionen;
  final int glaubenssaetze;
  final int bindungBeziehungen;
  final int kommunikation;
  final int gemeinschaft;
  final int familie;
  final int netzwerk;
  final int dating;
  final int lebenssinn;
  final int umwelt;
  final int spiritualitaet;
  final int spenden;
  final int lebensplanung;
  final int selbstfuersorge;
  final int freizeit;
  final int spassFreude;
  final int gesundheit;

  Result({
    required this.userUUID,
    required this.resultsX,
    required this.combinedTotalScore,
    required this.completionDate,
    required this.finalCharacter,
    required this.finalCharacterDescription,
    required this.selbstwerterhoehung,
    required this.zielsetzung,
    required this.weiterbildung,
    required this.finanzen,
    required this.karriere,
    required this.fitness,
    required this.energie,
    required this.produktivitaet,
    required this.stressmanagement,
    required this.resilienz,
    required this.innerCoreInnerChange,
    required this.emotionen,
    required this.glaubenssaetze,
    required this.bindungBeziehungen,
    required this.kommunikation,
    required this.gemeinschaft,
    required this.familie,
    required this.netzwerk,
    required this.dating,
    required this.lebenssinn,
    required this.umwelt,
    required this.spiritualitaet,
    required this.spenden,
    required this.lebensplanung,
    required this.selbstfuersorge,
    required this.freizeit,
    required this.spassFreude,
    required this.gesundheit,
  });

  /// Erstellt eine `Result`-Instanz aus einer JSON-Karte
  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      userUUID: json['User-UUID'] as String,
      resultsX: json['ResultsX'] as String,
      combinedTotalScore: json['CombinedTotalScore'] as int,
      completionDate: DateTime.parse(json['CompletionDate'] as String),
      finalCharacter: json['FinalCharacter'] as String,
      finalCharacterDescription: json['FinalCharacterDescription'] as String,
      selbstwerterhoehung: json['Selbstwerterhoehung'] ?? 0,
      zielsetzung: json['Zielsetzung'] ?? 0,
      weiterbildung: json['Weiterbildung'] ?? 0,
      finanzen: json['Finanzen'] ?? 0,
      karriere: json['Karriere'] ?? 0,
      fitness: json['Fitness'] ?? 0,
      energie: json['Energie'] ?? 0,
      produktivitaet: json['Produktivitaet'] ?? 0,
      stressmanagement: json['Stressmanagement'] ?? 0,
      resilienz: json['Resilienz'] ?? 0,
      innerCoreInnerChange: json['InnerCoreInnerChange'] ?? 0,
      emotionen: json['Emotionen'] ?? 0,
      glaubenssaetze: json['Glaubenssaetze'] ?? 0,
      bindungBeziehungen: json['BindungBeziehungen'] ?? 0,
      kommunikation: json['Kommunikation'] ?? 0,
      gemeinschaft: json['Gemeinschaft'] ?? 0,
      familie: json['Familie'] ?? 0,
      netzwerk: json['Netzwerk'] ?? 0,
      dating: json['Dating'] ?? 0,
      lebenssinn: json['Lebenssinn'] ?? 0,
      umwelt: json['Umwelt'] ?? 0,
      spiritualitaet: json['Spiritualitaet'] ?? 0,
      spenden: json['Spenden'] ?? 0,
      lebensplanung: json['Lebensplanung'] ?? 0,
      selbstfuersorge: json['Selbstfuersorge'] ?? 0,
      freizeit: json['Freizeit'] ?? 0,
      spassFreude: json['SpassFreude'] ?? 0,
      gesundheit: json['Gesundheit'] ?? 0,
    );
  }

  /// Konvertiert eine `Result`-Instanz in eine JSON-Karte
  Map<String, dynamic> toJson() {
    return {
      'User-UUID': userUUID,
      'ResultsX': resultsX,
      'CombinedTotalScore': combinedTotalScore,
      'CompletionDate': completionDate.toIso8601String(),
      'FinalCharacter': finalCharacter,
      'FinalCharacterDescription': finalCharacterDescription,
      'Selbstwerterhoehung': selbstwerterhoehung,
      'Zielsetzung': zielsetzung,
      'Weiterbildung': weiterbildung,
      'Finanzen': finanzen,
      'Karriere': karriere,
      'Fitness': fitness,
      'Energie': energie,
      'Produktivitaet': produktivitaet,
      'Stressmanagement': stressmanagement,
      'Resilienz': resilienz,
      'InnerCoreInnerChange': innerCoreInnerChange,
      'Emotionen': emotionen,
      'Glaubenssaetze': glaubenssaetze,
      'BindungBeziehungen': bindungBeziehungen,
      'Kommunikation': kommunikation,
      'Gemeinschaft': gemeinschaft,
      'Familie': familie,
      'Netzwerk': netzwerk,
      'Dating': dating,
      'Lebenssinn': lebenssinn,
      'Umwelt': umwelt,
      'Spiritualitaet': spiritualitaet,
      'Spenden': spenden,
      'Lebensplanung': lebensplanung,
      'Selbstfuersorge': selbstfuersorge,
      'Freizeit': freizeit,
      'SpassFreude': spassFreude,
      'Gesundheit': gesundheit,
    };
  }
}
