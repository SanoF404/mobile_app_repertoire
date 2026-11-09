class Contact {
  const Contact({
    this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
  });
  final int? id;
  final String nom;
  final String prenom;
  final String telephone;
  String get nomComplet => '$prenom $nom';
  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
    id: json['id'] as int?,
    nom: json['nom'] as String,
    prenom: json['prenom'] as String,
    telephone: json['telephone'] as String,
  );
  Map<String, Object?> toJson() => {
    'id': id,
    'nom': nom,
    'prenom': prenom,
    'telephone': telephone,
  };
}
