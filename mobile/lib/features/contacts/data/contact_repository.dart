import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import '../../auth/data_auth_service.dart';
import '../../../models/contact.dart';

abstract interface class ContactRepository {
  Future<List<Contact>> lister();
  Future<Contact> ajouter(Contact contact);
  Future<Contact> modifier(Contact contact);
  Future<void> supprimer(int id);
}

class RestRepository implements ContactRepository {
  static const base = '${AuthService.baseUrl}/personnes';
  Future<Map<String, String>> _headers() async => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${await AuthService.token() ?? ''}',
  };
  dynamic _decode(http.Response r) {
    final data = jsonDecode(utf8.decode(r.bodyBytes));
    if (r.statusCode == 401) {
      AuthService.logout();
      throw Exception('Session expirÃƒÂ©e, reconnectez-vous');
    }
    if (r.statusCode >= 400) {
      throw Exception(data is Map ? data['detail'] : 'Erreur rÃƒÂ©seau');
    }
    return data;
  }

  @override
  Future<List<Contact>> lister() async {
    final r = await http.get(Uri.parse(base), headers: await _headers());
    return (_decode(r) as List)
        .map((e) => Contact.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Contact> ajouter(Contact c) async {
    final r = await http.post(
      Uri.parse(base),
      headers: await _headers(),
      body: jsonEncode(c.toJson()),
    );
    return Contact.fromJson(_decode(r) as Map<String, dynamic>);
  }

  @override
  Future<Contact> modifier(Contact c) async {
    final r = await http.put(
      Uri.parse('$base/${c.id}'),
      headers: await _headers(),
      body: jsonEncode(c.toJson()),
    );
    return Contact.fromJson(_decode(r) as Map<String, dynamic>);
  }

  @override
  Future<void> supprimer(int id) async {
    final r = await http.delete(
      Uri.parse('$base/$id'),
      headers: await _headers(),
    );
    if (r.statusCode == 401) throw Exception('Session expirÃƒÂ©e');
    if (r.statusCode >= 400) throw Exception('Suppression impossible');
  }
}

class SqliteRepository implements ContactRepository {
  Future<Database> get _db async => openDatabase(
    p.join(await getDatabasesPath(), 'peopleo.db'),
    version: 1,
    onCreate: (db, _) => db.execute(
      'CREATE TABLE persons(id INTEGER PRIMARY KEY AUTOINCREMENT, nom TEXT NOT NULL, prenom TEXT NOT NULL, telephone TEXT NOT NULL UNIQUE)',
    ),
  );
  @override
  Future<List<Contact>> lister() async {
    final rows = await (await _db).query('persons', orderBy: 'nom, prenom');
    return rows
        .map(
          (r) => Contact(
            id: r['id'] as int?,
            nom: r['nom'] as String,
            prenom: r['prenom'] as String,
            telephone: r['telephone'] as String,
          ),
        )
        .toList();
  }

  @override
  Future<Contact> ajouter(Contact c) async {
    final id = await (await _db).insert('persons', c.toJson()..remove('id'));
    return Contact(
      id: id,
      nom: c.nom,
      prenom: c.prenom,
      telephone: c.telephone,
    );
  }

  @override
  Future<Contact> modifier(Contact c) async {
    await (await _db).update(
      'persons',
      c.toJson()..remove('id'),
      where: 'id=?',
      whereArgs: [c.id],
    );
    return c;
  }

  @override
  Future<void> supprimer(int id) async {
    await (await _db).delete('persons', where: 'id=?', whereArgs: [id]);
  }
}
