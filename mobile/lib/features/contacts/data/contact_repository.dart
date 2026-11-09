import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../auth/data_auth_service.dart';

typedef ContactMap = Map<String, dynamic>;

abstract interface class ContactRepository {
  Future<List<ContactMap>> lister();
  Future<ContactMap> ajouter(ContactMap contactJson);
  Future<ContactMap> modifier(ContactMap contactJson);
  Future<void> supprimer(int id);
}

class RestRepository implements ContactRepository {
  static const base = '${AuthService.baseUrl}/personnes';

  Future<Map<String, String>> _headers() async => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${await AuthService.token() ?? ''}',
  };

  dynamic _decode(http.Response response) {
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 401) {
      AuthService.logout();
      throw Exception('Session expired. Sign in again.');
    }
    if (response.statusCode >= 400) {
      throw Exception(data is Map ? data['detail'] : 'Network error');
    }
    return data;
  }

  @override
  Future<List<ContactMap>> lister() async {
    final response = await http.get(Uri.parse(base), headers: await _headers());
    return (_decode(response) as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  @override
  Future<ContactMap> ajouter(ContactMap contactJson) async {
    final response = await http.post(
      Uri.parse(base),
      headers: await _headers(),
      body: jsonEncode(contactJson),
    );
    return Map<String, dynamic>.from(_decode(response) as Map);
  }

  @override
  Future<ContactMap> modifier(ContactMap contactJson) async {
    final response = await http.put(
      Uri.parse('$base/${contactJson['id']}'),
      headers: await _headers(),
      body: jsonEncode(contactJson),
    );
    return Map<String, dynamic>.from(_decode(response) as Map);
  }

  @override
  Future<void> supprimer(int id) async {
    final response = await http.delete(
      Uri.parse('$base/$id'),
      headers: await _headers(),
    );
    if (response.statusCode == 401) {
      AuthService.logout();
      throw Exception('Session expired. Sign in again.');
    }
    if (response.statusCode >= 400) {
      throw Exception('Delete failed');
    }
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
  Future<List<ContactMap>> lister() async {
    final rows = await (await _db).query('persons', orderBy: 'nom, prenom');
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  @override
  Future<ContactMap> ajouter(ContactMap contactJson) async {
    final values = Map<String, dynamic>.from(contactJson)..remove('id');
    final id = await (await _db).insert('persons', values);
    return {...values, 'id': id};
  }

  @override
  Future<ContactMap> modifier(ContactMap contactJson) async {
    final values = Map<String, dynamic>.from(contactJson)..remove('id');
    await (await _db).update(
      'persons',
      values,
      where: 'id=?',
      whereArgs: [contactJson['id']],
    );
    return contactJson;
  }

  @override
  Future<void> supprimer(int id) async {
    await (await _db).delete('persons', where: 'id=?', whereArgs: [id]);
  }
}
