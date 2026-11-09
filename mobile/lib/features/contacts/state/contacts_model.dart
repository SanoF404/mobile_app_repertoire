import 'package:flutter/foundation.dart';

import '../data/contact_repository.dart';
import '../../../models/contact.dart';

class ContactsModel extends ChangeNotifier {
  ContactsModel(this.repo);
  final ContactRepository repo;
  List<Contact> items = [];
  bool loading = false;
  String? error;
  Future<void> charger() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      items = await repo.lister();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> ajouter(Contact c) async {
    await repo.ajouter(c);
    await charger();
  }

  Future<void> modifier(Contact c) async {
    await repo.modifier(c);
    await charger();
  }

  Future<void> supprimer(Contact c) async {
    if (c.id != null) {
      await repo.supprimer(c.id!);
      await charger();
    }
  }

  List<Contact> chercher(String q) {
    final v = q.toLowerCase().trim();
    return items
        .where(
          (c) =>
              c.nomComplet.toLowerCase().contains(v) || c.telephone.contains(v),
        )
        .toList();
  }
}
