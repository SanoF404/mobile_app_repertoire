String? validateTelephone(String value) {
  if (!RegExp(r'^\+?[0-9 ()-]{6,20}$').hasMatch(value.trim())) {
    return 'Numéro invalide';
  }
  return null;
}
