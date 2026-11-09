import 'package:flutter/material.dart';

import '../../../models/contact.dart';

class ContactCard extends StatelessWidget {
  const ContactCard({super.key, required this.contact, this.onTap});
  final Contact contact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: CircleAvatar(
      child: Text(
        contact.prenom.isEmpty ? '?' : contact.prenom[0].toUpperCase(),
      ),
    ),
    title: Text(contact.nomComplet),
    subtitle: Text(contact.telephone),
    onTap: onTap,
  );
}
