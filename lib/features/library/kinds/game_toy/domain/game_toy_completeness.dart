enum GameToyCompleteness {
  loose('loose', 'Loose'),
  newSealed('new', 'New');

  const GameToyCompleteness(this.value, this.label);
  final String value;
  final String label;
  static GameToyCompleteness? parse(Object? value) {
    if (value == null) return null;
    return values.firstWhere((tier) => tier.value == value,
        orElse: () =>
            throw FormatException('Invalid GameToy completeness: $value'));
  }
}
