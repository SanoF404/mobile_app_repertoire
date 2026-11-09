import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/locale_model.dart';
import '../../../features/auth/data_auth_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/contact.dart';
import '../state/contacts_model.dart';
import '../domain/contact_validator.dart';
import '../widgets/contact_card.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});
  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ContactsModel>().charger();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _edit([Contact? contact]) async {
    final strings = AppLocalizations.of(context)!;
    final firstName = TextEditingController(text: contact?.prenom ?? '');
    final lastName = TextEditingController(text: contact?.nom ?? '');
    final phone = TextEditingController(text: contact?.telephone ?? '');
    final formKey = GlobalKey<FormState>();
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(contact == null ? strings.addContact : strings.edit),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: firstName,
                decoration: InputDecoration(labelText: strings.firstName),
                validator: (value) => value == null || value.trim().isEmpty
                    ? strings.firstName
                    : null,
              ),
              TextFormField(
                controller: lastName,
                decoration: InputDecoration(labelText: strings.lastName),
                validator: (value) => value == null || value.trim().isEmpty
                    ? strings.lastName
                    : null,
              ),
              TextFormField(
                controller: phone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: strings.phone),
                validator: (value) => validateTelephone(value ?? '') == null
                    ? null
                    : strings.invalidPhone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => formKey.currentState!.validate()
                ? Navigator.pop(dialogContext, true)
                : null,
            child: Text(strings.save),
          ),
        ],
      ),
    );

    if (saved == true && mounted) {
      final value = Contact(
        id: contact?.id,
        prenom: firstName.text.trim(),
        nom: lastName.text.trim(),
        telephone: phone.text.trim(),
      );
      try {
        final model = context.read<ContactsModel>();
        if (contact == null) {
          await model.ajouter(value);
        } else {
          await model.modifier(value);
        }
      } catch (error) {
        if (mounted) _showError(error);
      }
    }
    firstName.dispose();
    lastName.dispose();
    phone.dispose();
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error is DuplicatePhoneException
              ? AppLocalizations.of(context)!.duplicatePhone
              : error.toString().replaceFirst('Exception: ', ''),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(Contact contact) async {
    final strings = AppLocalizations.of(context)!;
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(strings.confirmDelete),
            content: Text(contact.nomComplet),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(strings.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(strings.delete),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final model = context.watch<ContactsModel>();
    final contacts = model
        .chercher(_search.text)
        .map(Contact.fromJson)
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.appTitle),
        actions: [
          IconButton(
            tooltip: strings.retry,
            onPressed: model.charger,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: strings.language,
            onPressed: context.read<LocaleModel>().toggle,
            icon: const Icon(Icons.language),
          ),
          IconButton(
            tooltip: strings.logout,
            onPressed: () async {
              await AuthService.logout();
              if (context.mounted) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (_) => false);
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _edit,
        icon: const Icon(Icons.person_add_alt_1),
        label: Text(strings.addContact),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: strings.search,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          if (model.loading) const LinearProgressIndicator(),
          if (model.error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(model.error!, textAlign: TextAlign.center),
                  TextButton(
                    onPressed: model.charger,
                    child: Text(strings.retry),
                  ),
                ],
              ),
            ),
          Expanded(
            child: model.loading && model.items.isEmpty
                ? const SizedBox.shrink()
                : contacts.isEmpty
                ? Center(
                    child: Text(
                      _search.text.isEmpty ? strings.empty : strings.noResults,
                    ),
                  )
                : ListView.builder(
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return Dismissible(
                        key: ValueKey(contact.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) => _confirmDelete(contact),
                        onDismissed: (_) async {
                          try {
                            await model.supprimer(contact.id!);
                          } catch (error) {
                            if (mounted) _showError(error);
                          }
                        },
                        child: ContactCard(
                          contact: contact,
                          onTap: () => showDialog<void>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: Text(contact.nomComplet),
                              content: Text(contact.telephone),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: Text(strings.close),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(dialogContext);
                                    _edit(contact);
                                  },
                                  child: Text(strings.edit),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
