// lib/widgets/detailed_result_ui.dart

import 'package:flutter/material.dart';
import '../models/result.dart'; // Passe den Pfad entsprechend deinem Projekt an

// Definiere die Hauptbereiche und ihre Unterbereiche
const Map<String, List<String>> LIFE_AREA_MAP_DART = {
  "Selbstwerterhöhung": [
    "Selbstwerterhoehung",
    "Zielsetzung",
    "Weiterbildung",
    "Finanzen",
    "Karriere",
    "Fitness"
  ],
  "Energie": [
    "Energie",
    "Produktivitaet",
    "Stressmanagement",
    "Resilienz"
  ],
  "Inner Core, Inner Change": [
    "InnerCoreInnerChange",
    "Emotionen",
    "Glaubenssaetze"
  ],
  "Bindung & Beziehungen": [
    "BindungBeziehungen",
    "Kommunikation",
    "Gemeinschaft",
    "Familie",
    "Netzwerk",
    "Dating"
  ],
  "Lebenssinn": [
    "Lebenssinn",
    "Umwelt",
    "Spiritualitaet",
    "Spenden",
    "Lebensplanung",
    "Selbstfuersorge",
    "Freizeit",
    "SpassFreude",
    "Gesundheit"
  ],
};

// Widget zur Darstellung der detaillierten Ergebnisse
Widget buildDetailedResultUI(Result detailedResult, int index) {
  return Padding(
    padding: const EdgeInsets.all(16.0), // Größeres Padding
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: LIFE_AREA_MAP_DART.entries.map((entry) {
        String mainArea = entry.key;
        List<String> subAreas = entry.value;

        // Liste der validen Sub-Areas mit deren Prozentwerten
        List<Widget> subAreaWidgets = [];
        double totalSum = 0;
        double totalCount = 0;

        for (String subArea in subAreas) {
          int sum = _getLebensbereichSum(detailedResult, subArea);
          int count = _getLebensbereichCount(detailedResult, subArea);

          if (count <= 0) continue; // Überspringe Sub-Areas mit count <= 0

          double percentage = (sum / count) * 10;
          totalSum += sum;
          totalCount += count;

          subAreaWidgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    subArea,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (subAreaWidgets.isEmpty) {
          return SizedBox.shrink(); // Keine Sub-Areas mit count > 0
        }

        // Gesamtprozent für den Hauptbereich
        double totalPercentage = (totalSum / totalCount) * 10;

        return Card(
          color: Color(0xFFF2EEE5), // Verwende die mittlere Farbe
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Padding innerhalb der Karte
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hauptbereich Titel und Gesamtprozent
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      mainArea,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    Text(
                      '${totalPercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                // Liste der Sub-Areas mit ihren Prozentwerten
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: subAreaWidgets,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ),
  );
}

// Hilfsfunktionen zur Berechnung der Summe und des Counts pro Lebensbereich
int _getLebensbereichSum(Result detailedResult, String subArea) {
  // Implementiere die Logik zur Ermittlung der Summe basierend auf dem SubArea
  // Beispiel:
  switch (subArea) {
    case "Selbstwerterhoehung":
      return detailedResult.selbstwerterhoehungSum;
    case "Zielsetzung":
      return detailedResult.zielsetzungSum;
    case "Weiterbildung":
      return detailedResult.weiterbildungSum;
    case "Finanzen":
      return detailedResult.finanzenSum;
    case "Karriere":
      return detailedResult.karriereSum;
    case "Fitness":
      return detailedResult.fitnessSum;
    case "Energie":
      return detailedResult.energieSum;
    case "Produktivitaet":
      return detailedResult.produktivitaetSum;
    case "Stressmanagement":
      return detailedResult.stressmanagementSum;
    case "Resilienz":
      return detailedResult.resilienzSum;
    case "InnerCoreInnerChange":
      return detailedResult.innerCoreInnerChangeSum;
    case "Emotionen":
      return detailedResult.emotionenSum;
    case "Glaubenssaetze":
      return detailedResult.glaubenssaetzeSum;
    case "BindungBeziehungen":
      return detailedResult.bindungBeziehungenSum;
    case "Kommunikation":
      return detailedResult.kommunikationSum;
    case "Gemeinschaft":
      return detailedResult.gemeinschaftSum;
    case "Familie":
      return detailedResult.familieSum;
    case "Netzwerk":
      return detailedResult.netzwerkSum;
    case "Dating":
      return detailedResult.datingSum;
    case "Lebenssinn":
      return detailedResult.lebenssinnSum;
    case "Umwelt":
      return detailedResult.umweltSum;
    case "Spiritualitaet":
      return detailedResult.spiritualitaetSum;
    case "Spenden":
      return detailedResult.spendenSum;
    case "Lebensplanung":
      return detailedResult.lebensplanungSum;
    case "Selbstfuersorge":
      return detailedResult.selbstfuersorgeSum;
    case "Freizeit":
      return detailedResult.freizeitSum;
    case "SpassFreude":
      return detailedResult.spassFreudeSum;
    case "Gesundheit":
      return detailedResult.gesundheitSum;
    default:
      return 0;
  }
}

int _getLebensbereichCount(Result detailedResult, String subArea) {
  // Implementiere die Logik zur Ermittlung des Counts basierend auf dem SubArea
  // Beispiel:
  switch (subArea) {
    case "Selbstwerterhoehung":
      return detailedResult.selbstwerterhoehungCount;
    case "Zielsetzung":
      return detailedResult.zielsetzungCount;
    case "Weiterbildung":
      return detailedResult.weiterbildungCount;
    case "Finanzen":
      return detailedResult.finanzenCount;
    case "Karriere":
      return detailedResult.karriereCount;
    case "Fitness":
      return detailedResult.fitnessCount;
    case "Energie":
      return detailedResult.energieCount;
    case "Produktivitaet":
      return detailedResult.produktivitaetCount;
    case "Stressmanagement":
      return detailedResult.stressmanagementCount;
    case "Resilienz":
      return detailedResult.resilienzCount;
    case "InnerCoreInnerChange":
      return detailedResult.innerCoreInnerChangeCount;
    case "Emotionen":
      return detailedResult.emotionenCount;
    case "Glaubenssaetze":
      return detailedResult.glaubenssaetzeCount;
    case "BindungBeziehungen":
      return detailedResult.bindungBeziehungenCount;
    case "Kommunikation":
      return detailedResult.kommunikationCount;
    case "Gemeinschaft":
      return detailedResult.gemeinschaftCount;
    case "Familie":
      return detailedResult.familieCount;
    case "Netzwerk":
      return detailedResult.netzwerkCount;
    case "Dating":
      return detailedResult.datingCount;
    case "Lebenssinn":
      return detailedResult.lebenssinnCount;
    case "Umwelt":
      return detailedResult.umweltCount;
    case "Spiritualitaet":
      return detailedResult.spiritualitaetCount;
    case "Spenden":
      return detailedResult.spendenCount;
    case "Lebensplanung":
      return detailedResult.lebensplanungCount;
    case "Selbstfuersorge":
      return detailedResult.selbstfuersorgeCount;
    case "Freizeit":
      return detailedResult.freizeitCount;
    case "SpassFreude":
      return detailedResult.spassFreudeCount;
    case "Gesundheit":
      return detailedResult.gesundheitCount;
    default:
      return 0;
  }
}
