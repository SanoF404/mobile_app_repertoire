import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ComparisonPage extends StatefulWidget {
  const ComparisonPage({super.key});

  @override
  State<ComparisonPage> createState() => _ComparisonPageState();
}

class _ComparisonPageState extends State<ComparisonPage> {
  List<Map<String, dynamic>> listeA = [];
  List<Map<String, dynamic>> listeB = [];
  List<Map<String, dynamic>> resultats = [];
  bool chargement = true;
  bool comparaisonFaite = false;
  String? erreur;

  @override
  void initState() {
    super.initState();
    chargerDonnees();
  }

  // Lit les deux fichiers JSON et convertit leur contenu en listes de Maps.
  Future<void> chargerDonnees() async {
    try {
      final jsonA = await rootBundle.loadString('assets/donnees/liste_a.json');
      final jsonB = await rootBundle.loadString('assets/donnees/liste_b.json');
      final donneesA = jsonDecode(jsonA) as List<dynamic>;
      final donneesB = jsonDecode(jsonB) as List<dynamic>;
      if (!mounted) return;
      setState(() {
        listeA = donneesA
            .map((element) => Map<String, dynamic>.from(element as Map))
            .toList();
        listeB = donneesB
            .map((element) => Map<String, dynamic>.from(element as Map))
            .toList();
        chargement = false;
      });
    } catch (exception) {
      if (!mounted) return;
      setState(() {
        erreur = 'Impossible de lire les fichiers JSON : $exception';
        chargement = false;
      });
    }
  }

  // Cherche une Map dans une liste en utilisant son identifiant.
  Map<String, dynamic>? trouverParId(
    List<Map<String, dynamic>> liste,
    dynamic id,
  ) {
    for (final element in liste) {
      if (element['id'] == id) return element;
    }
    return null;
  }

  // Vérifie que les clés et les valeurs des deux Maps sont les mêmes.
  bool mapsIdentiques(Map<String, dynamic> premiere, Map<String, dynamic> seconde) {
    if (premiere.length != seconde.length) return false;
    for (final cle in premiere.keys) {
      if (!seconde.containsKey(cle) || premiere[cle] != seconde[cle]) {
        return false;
      }
    }
    return true;
  }

  List<Map<String, dynamic>> trouverDifferences(
    Map<String, dynamic> premiere,
    Map<String, dynamic> seconde,
  ) {
    final differences = <Map<String, dynamic>>[];
    final cles = <String>{...premiere.keys, ...seconde.keys};
    for (final cle in cles) {
      if (premiere[cle] != seconde[cle] ||
          premiere.containsKey(cle) != seconde.containsKey(cle)) {
        differences.add({
          'cle': cle,
          'valeurA': premiere[cle],
          'valeurB': seconde[cle],
        });
      }
    }
    return differences;
  }

  void comparerListes() {
    final nouveauxResultats = <Map<String, dynamic>>[];

    for (final elementA in listeA) {
      final elementB = trouverParId(listeB, elementA['id']);
      if (elementB == null) {
        nouveauxResultats.add({
          'type': 'supprime',
          'element': elementA,
          'message': 'Présent dans la liste A seulement',
        });
      } else if (mapsIdentiques(elementA, elementB)) {
        nouveauxResultats.add({
          'type': 'identique',
          'element': elementA,
          'message': 'Identique dans les deux listes',
        });
      } else {
        nouveauxResultats.add({
          'type': 'different',
          'element': elementA,
          'autre': elementB,
          'differences': trouverDifferences(elementA, elementB),
          'message': 'Les valeurs diffèrent',
        });
      }
    }

    for (final elementB in listeB) {
      if (trouverParId(listeA, elementB['id']) == null) {
        nouveauxResultats.add({
          'type': 'ajoute',
          'element': elementB,
          'message': 'Présent dans la liste B seulement',
        });
      }
    }

    // jsonEncode affiche une version JSON lisible des résultats calculés.
    final resultatJson = jsonEncode(nouveauxResultats);
    final resultatDecode = jsonDecode(resultatJson) as List<dynamic>;
    setState(() {
      resultats = resultatDecode
          .map((element) => Map<String, dynamic>.from(element as Map))
          .toList();
      comparaisonFaite = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (chargement) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (erreur != null) {
      return Scaffold(body: Center(child: Text(erreur!)));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Comparaison de listes JSON')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Liste A',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          ...listeA.map((element) => _carteElement(element)),
          const SizedBox(height: 16),
          const Text(
            'Liste B',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          ...listeB.map((element) => _carteElement(element)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: comparerListes,
            icon: const Icon(Icons.compare_arrows),
            label: const Text('Comparer les listes'),
          ),
          if (comparaisonFaite) ...[
            const SizedBox(height: 20),
            const Text(
              'Résultats',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ...resultats.map((resultat) => _carteResultat(resultat)),
          ],
        ],
      ),
    );
  }

  Widget _carteElement(Map<String, dynamic> element) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Text(const JsonEncoder.withIndent('  ').convert(element)),
    ),
  );

  Widget _carteResultat(Map<String, dynamic> resultat) {
    final type = resultat['type'] as String;
    final couleur = switch (type) {
      'identique' => Colors.green,
      'different' => Colors.orange,
      'ajoute' => Colors.blue,
      _ => Colors.red,
    };
    final titre = switch (type) {
      'identique' => 'Identique',
      'different' => 'Différent',
      'ajoute' => 'Ajouté',
      _ => 'Supprimé',
    };

    return Card(
      child: ListTile(
        leading: Icon(Icons.circle, color: couleur, size: 16),
        title: Text('$titre — ${resultat['message']}'),
        subtitle: Text(_detailsResultat(resultat)),
      ),
    );
  }

  String _detailsResultat(Map<String, dynamic> resultat) {
    if (resultat['type'] != 'different') {
      return jsonEncode(resultat['element']);
    }
    final differences = resultat['differences'] as List<dynamic>;
    return differences.map((difference) {
      final cle = difference['cle'];
      final valeurA = difference['valeurA'] ?? '(clé absente)';
      final valeurB = difference['valeurB'] ?? '(clé absente)';
      return '$cle : A = $valeurA ; B = $valeurB';
    }).join('\n');
  }
}
