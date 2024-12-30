import 'dart:convert';

class Result {
  final String userUUID;
  final String resultsX;
  final double combinedTotalScore;
  final DateTime? completionDate;
  final String? finalCharacter;
  final String? finalCharacterDescription;

  // Lebensbereiche: Summe und Count
  final int selbstwerterhoehungSum;
  final int selbstwerterhoehungCount;
  final int zielsetzungSum;
  final int zielsetzungCount;
  final int weiterbildungSum;
  final int weiterbildungCount;
  final int finanzenSum;
  final int finanzenCount;
  final int karriereSum;
  final int karriereCount;
  final int fitnessSum;
  final int fitnessCount;
  final int energieSum;
  final int energieCount;
  final int produktivitaetSum;
  final int produktivitaetCount;
  final int stressmanagementSum;
  final int stressmanagementCount;
  final int resilienzSum;
  final int resilienzCount;
  final int innerCoreInnerChangeSum;
  final int innerCoreInnerChangeCount;
  final int emotionenSum;
  final int emotionenCount;
  final int glaubenssaetzeSum;
  final int glaubenssaetzeCount;
  final int bindungBeziehungenSum;
  final int bindungBeziehungenCount;
  final int kommunikationSum;
  final int kommunikationCount;
  final int gemeinschaftSum;
  final int gemeinschaftCount;
  final int familieSum;
  final int familieCount;
  final int netzwerkSum;
  final int netzwerkCount;
  final int datingSum;
  final int datingCount;
  final int lebenssinnSum;
  final int lebenssinnCount;
  final int umweltSum;
  final int umweltCount;
  final int spiritualitaetSum;
  final int spiritualitaetCount;
  final int spendenSum;
  final int spendenCount;
  final int lebensplanungSum;
  final int lebensplanungCount;
  final int selbstfuersorgeSum;
  final int selbstfuersorgeCount;
  final int freizeitSum;
  final int freizeitCount;
  final int spassFreudeSum;
  final int spassFreudeCount;
  final int gesundheitSum;
  final int gesundheitCount;

  Result({
    required this.userUUID,
    required this.resultsX,
    required this.combinedTotalScore,
    required this.completionDate,
    required this.finalCharacter,
    required this.finalCharacterDescription,
    required this.selbstwerterhoehungSum,
    required this.selbstwerterhoehungCount,
    required this.zielsetzungSum,
    required this.zielsetzungCount,
    required this.weiterbildungSum,
    required this.weiterbildungCount,
    required this.finanzenSum,
    required this.finanzenCount,
    required this.karriereSum,
    required this.karriereCount,
    required this.fitnessSum,
    required this.fitnessCount,
    required this.energieSum,
    required this.energieCount,
    required this.produktivitaetSum,
    required this.produktivitaetCount,
    required this.stressmanagementSum,
    required this.stressmanagementCount,
    required this.resilienzSum,
    required this.resilienzCount,
    required this.innerCoreInnerChangeSum,
    required this.innerCoreInnerChangeCount,
    required this.emotionenSum,
    required this.emotionenCount,
    required this.glaubenssaetzeSum,
    required this.glaubenssaetzeCount,
    required this.bindungBeziehungenSum,
    required this.bindungBeziehungenCount,
    required this.kommunikationSum,
    required this.kommunikationCount,
    required this.gemeinschaftSum,
    required this.gemeinschaftCount,
    required this.familieSum,
    required this.familieCount,
    required this.netzwerkSum,
    required this.netzwerkCount,
    required this.datingSum,
    required this.datingCount,
    required this.lebenssinnSum,
    required this.lebenssinnCount,
    required this.umweltSum,
    required this.umweltCount,
    required this.spiritualitaetSum,
    required this.spiritualitaetCount,
    required this.spendenSum,
    required this.spendenCount,
    required this.lebensplanungSum,
    required this.lebensplanungCount,
    required this.selbstfuersorgeSum,
    required this.selbstfuersorgeCount,
    required this.freizeitSum,
    required this.freizeitCount,
    required this.spassFreudeSum,
    required this.spassFreudeCount,
    required this.gesundheitSum,
    required this.gesundheitCount,
  });

  /// Erstellt eine `Result`-Instanz aus einer JSON-Karte
  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      userUUID: json['User-UUID'] as String,
      resultsX: json['ResultsX'] as String,
      combinedTotalScore: (json['CombinedTotalScore'] as num).toDouble(),
      completionDate: json['CompletionDate'] != null
          ? DateTime.parse(cleanDateString(json['CompletionDate'] as String))
          : null,
      finalCharacter: json['FinalCharacter'] as String?,
      finalCharacterDescription: json['FinalCharacterDescription'] as String?,
      selbstwerterhoehungSum: json['Selbstwerterhoehung']?['Sum'] ?? 0,
      selbstwerterhoehungCount: json['Selbstwerterhoehung']?['Count'] ?? 0,
      zielsetzungSum: json['Zielsetzung']?['Sum'] ?? 0,
      zielsetzungCount: json['Zielsetzung']?['Count'] ?? 0,
      weiterbildungSum: json['Weiterbildung']?['Sum'] ?? 0,
      weiterbildungCount: json['Weiterbildung']?['Count'] ?? 0,
      finanzenSum: json['Finanzen']?['Sum'] ?? 0,
      finanzenCount: json['Finanzen']?['Count'] ?? 0,
      karriereSum: json['Karriere']?['Sum'] ?? 0,
      karriereCount: json['Karriere']?['Count'] ?? 0,
      fitnessSum: json['Fitness']?['Sum'] ?? 0,
      fitnessCount: json['Fitness']?['Count'] ?? 0,
      energieSum: json['Energie']?['Sum'] ?? 0,
      energieCount: json['Energie']?['Count'] ?? 0,
      produktivitaetSum: json['Produktivitaet']?['Sum'] ?? 0,
      produktivitaetCount: json['Produktivitaet']?['Count'] ?? 0,
      stressmanagementSum: json['Stressmanagement']?['Sum'] ?? 0,
      stressmanagementCount: json['Stressmanagement']?['Count'] ?? 0,
      resilienzSum: json['Resilienz']?['Sum'] ?? 0,
      resilienzCount: json['Resilienz']?['Count'] ?? 0,
      innerCoreInnerChangeSum: json['InnerCoreInnerChange']?['Sum'] ?? 0,
      innerCoreInnerChangeCount: json['InnerCoreInnerChange']?['Count'] ?? 0,
      emotionenSum: json['Emotionen']?['Sum'] ?? 0,
      emotionenCount: json['Emotionen']?['Count'] ?? 0,
      glaubenssaetzeSum: json['Glaubenssaetze']?['Sum'] ?? 0,
      glaubenssaetzeCount: json['Glaubenssaetze']?['Count'] ?? 0,
      bindungBeziehungenSum: json['BindungBeziehungen']?['Sum'] ?? 0,
      bindungBeziehungenCount: json['BindungBeziehungen']?['Count'] ?? 0,
      kommunikationSum: json['Kommunikation']?['Sum'] ?? 0,
      kommunikationCount: json['Kommunikation']?['Count'] ?? 0,
      gemeinschaftSum: json['Gemeinschaft']?['Sum'] ?? 0,
      gemeinschaftCount: json['Gemeinschaft']?['Count'] ?? 0,
      familieSum: json['Familie']?['Sum'] ?? 0,
      familieCount: json['Familie']?['Count'] ?? 0,
      netzwerkSum: json['Netzwerk']?['Sum'] ?? 0,
      netzwerkCount: json['Netzwerk']?['Count'] ?? 0,
      datingSum: json['Dating']?['Sum'] ?? 0,
      datingCount: json['Dating']?['Count'] ?? 0,
      lebenssinnSum: json['Lebenssinn']?['Sum'] ?? 0,
      lebenssinnCount: json['Lebenssinn']?['Count'] ?? 0,
      umweltSum: json['Umwelt']?['Sum'] ?? 0,
      umweltCount: json['Umwelt']?['Count'] ?? 0,
      spiritualitaetSum: json['Spiritualitaet']?['Sum'] ?? 0,
      spiritualitaetCount: json['Spiritualitaet']?['Count'] ?? 0,
      spendenSum: json['Spenden']?['Sum'] ?? 0,
      spendenCount: json['Spenden']?['Count'] ?? 0,
      lebensplanungSum: json['Lebensplanung']?['Sum'] ?? 0,
      lebensplanungCount: json['Lebensplanung']?['Count'] ?? 0,
      selbstfuersorgeSum: json['Selbstfuersorge']?['Sum'] ?? 0,
      selbstfuersorgeCount: json['Selbstfuersorge']?['Count'] ?? 0,
      freizeitSum: json['Freizeit']?['Sum'] ?? 0,
      freizeitCount: json['Freizeit']?['Count'] ?? 0,
      spassFreudeSum: json['SpassFreude']?['Sum'] ?? 0,
      spassFreudeCount: json['SpassFreude']?['Count'] ?? 0,
      gesundheitSum: json['Gesundheit']?['Sum'] ?? 0,
      gesundheitCount: json['Gesundheit']?['Count'] ?? 0,
    );
  }

  /// Konvertiert eine `Result`-Instanz in eine JSON-Karte
  Map<String, dynamic> toJson() {
    return {
      'User-UUID': userUUID,
      'ResultsX': resultsX,
      'CombinedTotalScore': combinedTotalScore,
      'CompletionDate': completionDate?.toIso8601String(),
      'FinalCharacter': finalCharacter,
      'FinalCharacterDescription': finalCharacterDescription,
      'Selbstwerterhoehung': {'Sum': selbstwerterhoehungSum, 'Count': selbstwerterhoehungCount},
      'Zielsetzung': {'Sum': zielsetzungSum, 'Count': zielsetzungCount},
      'Weiterbildung': {'Sum': weiterbildungSum, 'Count': weiterbildungCount},
      'Finanzen': {'Sum': finanzenSum, 'Count': finanzenCount},
      'Karriere': {'Sum': karriereSum, 'Count': karriereCount},
      'Fitness': {'Sum': fitnessSum, 'Count': fitnessCount},
      'Energie': {'Sum': energieSum, 'Count': energieCount},
      'Produktivitaet': {'Sum': produktivitaetSum, 'Count': produktivitaetCount},
      'Stressmanagement': {'Sum': stressmanagementSum, 'Count': stressmanagementCount},
      'Resilienz': {'Sum': resilienzSum, 'Count': resilienzCount},
      'InnerCoreInnerChange': {'Sum': innerCoreInnerChangeSum, 'Count': innerCoreInnerChangeCount},
      'Emotionen': {'Sum': emotionenSum, 'Count': emotionenCount},
      'Glaubenssaetze': {'Sum': glaubenssaetzeSum, 'Count': glaubenssaetzeCount},
      'BindungBeziehungen': {'Sum': bindungBeziehungenSum, 'Count': bindungBeziehungenCount},
      'Kommunikation': {'Sum': kommunikationSum, 'Count': kommunikationCount},
      'Gemeinschaft': {'Sum': gemeinschaftSum, 'Count': gemeinschaftCount},
      'Familie': {'Sum': familieSum, 'Count': familieCount},
      'Netzwerk': {'Sum': netzwerkSum, 'Count': netzwerkCount},
      'Dating': {'Sum': datingSum, 'Count': datingCount},
      'Lebenssinn': {'Sum': lebenssinnSum, 'Count': lebenssinnCount},
      'Umwelt': {'Sum': umweltSum, 'Count': umweltCount},
      'Spiritualitaet': {'Sum': spiritualitaetSum, 'Count': spiritualitaetCount},
      'Spenden': {'Sum': spendenSum, 'Count': spendenCount},
      'Lebensplanung': {'Sum': lebensplanungSum, 'Count': lebensplanungCount},
      'Selbstfuersorge': {'Sum': selbstfuersorgeSum, 'Count': selbstfuersorgeCount},
      'Freizeit': {'Sum': freizeitSum, 'Count': freizeitCount},
      'SpassFreude': {'Sum': spassFreudeSum, 'Count': spassFreudeCount},
      'Gesundheit': {'Sum': gesundheitSum, 'Count': gesundheitCount},
    };
  }
}

String cleanDateString(String dateStr) {
  // Entfernt die zusätzlichen Millisekunden und das "+" vor "Z"
  return dateStr.replaceAllMapped(
    RegExp(r'(\.\d{6})?\+00:00Z$'),
        (match) => 'Z',
  );
}
