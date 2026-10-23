enum GameHardwareCompleteness {
  loose('loose', 'Loose'),
  cib('cib', 'CIB'),
  newSealed('new', 'New'),
  graded('graded', 'Graded');

  const GameHardwareCompleteness(this.value, this.label);
  final String value;
  final String label;
  static GameHardwareCompleteness? parse(Object? value) {
    if (value == null) return null;
    return values.firstWhere((tier) => tier.value == value,
        orElse: () =>
            throw FormatException('Invalid GameHardware completeness: $value'));
  }
}
