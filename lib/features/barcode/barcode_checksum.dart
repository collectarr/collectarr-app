/// Technical retail barcode checksum shared by kind-owned resolvers.
bool isValidRetailBarcode(String value) {
  if (value.length case 8 || 12 || 13 || 14) {
    if (!RegExp(r'^\d+$').hasMatch(value)) return false;
    final digits = value.codeUnits.map((unit) => unit - 48).toList();
    var sum = 0;
    for (var index = digits.length - 2; index >= 0; index--) {
      final distanceFromCheck = digits.length - 1 - index;
      sum += digits[index] * (distanceFromCheck.isOdd ? 3 : 1);
    }
    final checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit == digits.last;
  }
  return false;
}

bool isValidIsbn(String value) {
  if (value.length == 10) {
    if (!RegExp(r'^\d{9}[\dX]$').hasMatch(value)) return false;
    var sum = 0;
    for (var index = 0; index < 10; index++) {
      final digit =
          value.codeUnitAt(index) == 88 ? 10 : value.codeUnitAt(index) - 48;
      sum += digit * (10 - index);
    }
    return sum % 11 == 0;
  }
  if (value.length == 13 && RegExp(r'^\d{13}$').hasMatch(value)) {
    var sum = 0;
    for (var index = 0; index < 12; index++) {
      sum += (value.codeUnitAt(index) - 48) * (index.isEven ? 1 : 3);
    }
    return (10 - (sum % 10)) % 10 == value.codeUnitAt(12) - 48;
  }
  return false;
}
