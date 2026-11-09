import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_app/models/contact.dart';
import 'package:repertoire_app/features/contacts/domain/contact_validator.dart';

void main() {
  test('contact JSON round trip keeps all fields', () {
    final contact = Contact.fromJson({
      'id': 7,
      'nom': 'Trabelsi',
      'prenom': 'Sami',
      'telephone': '98123456',
    });
    expect(contact.nomComplet, 'Sami Trabelsi');
    expect(contact.toJson(), {
      'id': 7,
      'nom': 'Trabelsi',
      'prenom': 'Sami',
      'telephone': '98123456',
    });
  });

  test('telephone validator accepts a valid number', () {
    expect(validateTelephone('98 123 456'), isNull);
  });

  test('telephone validator rejects letters', () {
    expect(validateTelephone('98ab'), isNotNull);
  });
}
