import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../models/contact.dart';
import '../data/contact_repository.dart';

class DuplicatePhoneException implements Exception {}

class ContactsModel extends ChangeNotifier {
  ContactsModel(this.repo);

  final ContactRepository repo;
  List<Map<String, dynamic>> items = [];
  bool loading = false;
  String? error;

  Future<void> charger() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final response = await repo.lister();
      // A JSON encode/decode round trip keeps the in-memory collection JSON-safe.
      items = response
          .map((map) => jsonDecode(jsonEncode(map)) as Map<String, dynamic>)
          .toList();
    } catch (exception) {
      error = exception.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> ajouter(Contact contact) async {
    if (_telephoneExiste(contact.telephone)) throw DuplicatePhoneException();
    final jsonMap = _toJsonMap(contact);
    await repo.ajouter(jsonMap);
    await charger();
  }

  Future<void> modifier(Contact contact) async {
    if (_telephoneExiste(contact.telephone, saufId: contact.id)) {
      throw DuplicatePhoneException();
    }
    final jsonMap = _toJsonMap(contact);
    await repo.modifier(jsonMap);
    await charger();
  }

  Future<void> supprimer(int id) async {
    await repo.supprimer(id);
    await charger();
  }

  List<Map<String, dynamic>> chercher(String query) {
    final comparaison = query.trim().toLowerCase();
    if (comparaison.isEmpty) return List.of(items);
    final chiffresRecherche = _normaliserTelephone(comparaison);
    return items.where((jsonMap) {
      final contact = Contact.fromJson(jsonMap);
      final nomComplet = contact.nomComplet.toLowerCase();
      final telephone = contact.telephone.toLowerCase();
      final correspondanceTexte =
          nomComplet.contains(comparaison) ||
          contact.prenom.toLowerCase().contains(comparaison) ||
          contact.nom.toLowerCase().contains(comparaison) ||
          telephone.contains(comparaison);
      final correspondanceNumero =
          chiffresRecherche.isNotEmpty &&
          _normaliserTelephone(telephone).contains(chiffresRecherche);
      return correspondanceTexte || correspondanceNumero;
    }).toList();
  }

  bool _telephoneExiste(String telephone, {int? saufId}) {
    final numeroCompare = _normaliserTelephone(telephone);
    return items.any((jsonMap) {
      final memeContact = jsonMap['id'] == saufId;
      final memeNumero =
          _normaliserTelephone(jsonMap['telephone'] as String) == numeroCompare;
      return !memeContact && memeNumero;
    });
  }

  String _normaliserTelephone(String value) =>
      value.replaceAll(RegExp(r'[^0-9]'), '');

  Map<String, dynamic> _toJsonMap(Contact contact) =>
      jsonDecode(jsonEncode(contact.toJson())) as Map<String, dynamic>;
}
