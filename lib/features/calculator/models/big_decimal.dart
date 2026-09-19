/// ============================================================================
/// FILE: lib/features/calculator/models/big_decimal.dart
/// FUNGSI: Class high-precision decimal yang didukung oleh BigInt native Dart.
/// MANAJEMEN HANDLES: Model untuk FR-T1-01 (Big Integer / High Precision Arithmetic)
/// LOKASI LOGIC: Operasi aritmatika presisi tinggi (+, -, *, /) tanpa overflow.
/// ============================================================================

class BigDecimal implements Comparable<BigDecimal> {
  final BigInt _unscaled;
  final int _scale;

  BigDecimal._(this._unscaled, this._scale);

  factory BigDecimal(BigInt unscaled, int scale) {
    if (unscaled == BigInt.zero) {
      return BigDecimal._(BigInt.zero, 0);
    }
    int currentScale = scale;
    BigInt currentUnscaled = unscaled;

    while (currentScale > 0 && (currentUnscaled % BigInt.from(10) == BigInt.zero)) {
      currentUnscaled = currentUnscaled ~/ BigInt.from(10);
      currentScale--;
    }

    return BigDecimal._(currentUnscaled, currentScale);
  }

  static final BigDecimal zero = BigDecimal._(BigInt.zero, 0);
  static final BigDecimal one = BigDecimal._(BigInt.one, 0);

  factory BigDecimal.fromInt(int value) => BigDecimal(BigInt.from(value), 0);
  factory BigDecimal.fromBigInt(BigInt value) => BigDecimal(value, 0);

  BigInt get unscaled => _unscaled;
  int get scale => _scale;

  bool get isZero => _unscaled == BigInt.zero;
  bool get isNegative => _unscaled < BigInt.zero;

  bool get isInteger {
    if (_scale == 0) return true;
    BigInt divisor = _pow10(_scale);
    return (_unscaled % divisor) == BigInt.zero;
  }

  BigInt toBigInt() {
    if (_scale == 0) return _unscaled;
    return _unscaled ~/ _pow10(_scale);
  }

  static BigDecimal? tryParse(String input) {
    String str = input.trim();
    if (str.isEmpty) return null;

    if (str.contains(',') && str.contains('.')) {
      str = str.replaceAll(',', '');
    } else if (str.contains(',')) {
      str = str.replaceAll(',', '.');
    }

    int eIndex = str.indexOf(RegExp(r'[eE]'));
    int exponentShift = 0;
    if (eIndex != -1) {
      String expStr = str.substring(eIndex + 1);
      str = str.substring(0, eIndex);
      int? expVal = int.tryParse(expStr);
      if (expVal == null) return null;
      exponentShift = expVal;
    }

    bool isNeg = false;
    if (str.startsWith('-')) {
      isNeg = true;
      str = str.substring(1);
    } else if (str.startsWith('+')) {
      str = str.substring(1);
    }

    if (str.isEmpty) return null;

    List<String> parts = str.split('.');
    if (parts.length > 2) return null;

    String intPart = parts[0];
    String decPart = parts.length == 2 ? parts[1] : '';

    if (!RegExp(r'^\d*$').hasMatch(intPart) || !RegExp(r'^\d*$').hasMatch(decPart)) {
      return null;
    }

    if (intPart.isEmpty && decPart.isEmpty) return null;
    if (intPart.isEmpty) intPart = '0';

    int scale = decPart.length - exponentShift;
    String combinedDigits = intPart + decPart;
    BigInt? unscaled = BigInt.tryParse(combinedDigits);
    if (unscaled == null) return null;

    if (isNeg) {
      unscaled = -unscaled;
    }

    if (scale < 0) {
      unscaled = unscaled * _pow10(-scale);
      scale = 0;
    }

    return BigDecimal(unscaled, scale);
  }

  BigDecimal operator +(BigDecimal other) {
    int targetScale = _scale > other._scale ? _scale : other._scale;
    BigInt aScaled = _unscaled * _pow10(targetScale - _scale);
    BigInt bScaled = other._unscaled * _pow10(targetScale - other._scale);
    return BigDecimal(aScaled + bScaled, targetScale);
  }

  BigDecimal operator -(BigDecimal other) {
    int targetScale = _scale > other._scale ? _scale : other._scale;
    BigInt aScaled = _unscaled * _pow10(targetScale - _scale);
    BigInt bScaled = other._unscaled * _pow10(targetScale - other._scale);
    return BigDecimal(aScaled - bScaled, targetScale);
  }

  BigDecimal operator -() {
    return BigDecimal(-_unscaled, _scale);
  }

  BigDecimal operator *(BigDecimal other) {
    return BigDecimal(_unscaled * other._unscaled, _scale + other._scale);
  }

  BigDecimal divide(BigDecimal divisor, {int maxScale = 50}) {
    if (divisor.isZero) {
      throw ArgumentError('Error! Tidak bisa dibagi dengan nol.');
    }

    int requiredScale = (_scale > divisor._scale ? _scale : divisor._scale) + maxScale;
    int shift = requiredScale + divisor._scale - _scale;

    BigInt numerator = _unscaled;
    if (shift >= 0) {
      numerator = numerator * _pow10(shift);
    } else {
      numerator = numerator ~/ _pow10(-shift);
    }

    BigInt resultUnscaled = numerator ~/ divisor._unscaled;
    return BigDecimal(resultUnscaled, requiredScale);
  }

  @override
  int compareTo(BigDecimal other) {
    int targetScale = _scale > other._scale ? _scale : other._scale;
    BigInt aScaled = _unscaled * _pow10(targetScale - _scale);
    BigInt bScaled = other._unscaled * _pow10(targetScale - other._scale);
    return aScaled.compareTo(bScaled);
  }

  bool operator <(BigDecimal other) => compareTo(other) < 0;
  bool operator >(BigDecimal other) => compareTo(other) > 0;
  bool operator <=(BigDecimal other) => compareTo(other) <= 0;
  bool operator >=(BigDecimal other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BigDecimal && compareTo(other) == 0;
  }

  @override
  int get hashCode => Object.hash(_unscaled, _scale);

  @override
  String toString() {
    if (_unscaled == BigInt.zero) return '0';

    bool isNeg = _unscaled < BigInt.zero;
    String digits = (_unscaled.abs()).toString();

    if (_scale == 0) {
      return (isNeg ? '-' : '') + digits;
    }

    if (digits.length <= _scale) {
      String leadingZeroes = '0' * (_scale - digits.length + 1);
      digits = leadingZeroes + digits;
    }

    int splitIndex = digits.length - _scale;
    String intStr = digits.substring(0, splitIndex);
    String decStr = digits.substring(splitIndex);

    return '${isNeg ? '-' : ''}$intStr.$decStr';
  }

  String toFormattedString() {
    String raw = toString();
    if (raw.contains('Exception') || raw.contains('Error')) return raw;

    List<String> parts = raw.split('.');
    String intPart = parts[0];
    String decPart = parts.length > 1 ? parts[1] : '';

    bool isNeg = intPart.startsWith('-');
    if (isNeg) {
      intPart = intPart.substring(1);
    }

    StringBuffer formattedInt = StringBuffer();
    int len = intPart.length;
    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) {
        formattedInt.write('.');
      }
      formattedInt.write(intPart[i]);
    }

    String result = '${isNeg ? '-' : ''}$formattedInt';
    if (decPart.isNotEmpty) {
      result += ',$decPart';
    }
    return result;
  }

  static BigInt _pow10(int exponent) {
    if (exponent <= 0) return BigInt.one;
    BigInt base = BigInt.from(10);
    BigInt result = BigInt.one;
    int exp = exponent;
    while (exp > 0) {
      if (exp % 2 == 1) result *= base;
      base *= base;
      exp ~/= 2;
    }
    return result;
  }
}
