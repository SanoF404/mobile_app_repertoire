import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_app/features/contacts/data/contact_repository.dart';
import 'package:repertoire_app/features/contacts/state/contacts_model.dart';
import 'package:repertoire_app/models/contact.dart';

class MemoryRepository implements ContactRepository {
  final List<Map<String, dynamic>> data = [
    {'id': 1, 'nom': 'Trabelsi', 'prenom': 'Sami', 'telephone': '98 123 456'},
    {'id': 2, 'nom': 'Gharbi', 'prenom': 'Leila', 'telephone': '22-456-789'},
  ];

  @override
  Future<List<Map<String, dynamic>>> lister() async => List.of(data);
  @override
  Future<Map<String, dynamic>> ajouter(Map<String, dynamic> value) async {
    final saved = {...value, 'id': data.length + 1};
    data.add(saved);
    return saved;
  }

  @override
  Future<Map<String, dynamic>> modifier(Map<String, dynamic> value) async {
    final index = data.indexWhere((item) => item['id'] == value['id']);
    data[index] = value;
    return value;
  }

  @override
  Future<void> supprimer(int id) async =>
      data.removeWhere((item) => item['id'] == id);
}

void main() {
  test('contacts stay in a JSON map list and search compares names and phone digits', () async {
    final model = ContactsModel(MemoryRepository());
    await model.charger();
    expect(model.items, isA<List<Map<String, dynamic>>>());
    expect(model.chercher('sAmI').single['prenom'], 'Sami');
    expect(model.chercher('22456789').single['prenom'], 'Leila');
  });

  test('adding compares normalized phone numbers before saving JSON', () async {
    final model = ContactsModel(MemoryRepository());
    await model.charger();
    await expectLater(
      model.ajouter(
        const Contact(nom: 'Autre', prenom: 'Sam', telephone: '+98-123-456'),
      ),
      throwsA(isA<DuplicatePhoneException>()),
    );
  });
}
