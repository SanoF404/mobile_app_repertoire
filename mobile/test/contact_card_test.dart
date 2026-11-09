import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_app/models/contact.dart';
import 'package:repertoire_app/features/contacts/widgets/contact_card.dart';

void main() {
  testWidgets('ContactCard displays a contact name and phone', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ContactCard(
            contact: Contact(
              nom: 'Trabelsi',
              prenom: 'Sami',
              telephone: '98123456',
            ),
          ),
        ),
      ),
    );
    expect(find.text('Sami Trabelsi'), findsOneWidget);
    expect(find.text('98123456'), findsOneWidget);
  });
}
