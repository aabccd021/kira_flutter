library kira;

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int? value) {
    if (value == null) return 0;
    return value + 1;
  }
}
