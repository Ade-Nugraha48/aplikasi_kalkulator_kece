// lib/features/calculator_t1/logic/big_decimal.dart

class BigDecimal implements Comparable<BigDecimal> {
  final BigInt unscaledValue;
  final int scale;

  const BigDecimal._(this.unscaledValue, this.scale);

  factory BigDecimal.fromBigInt(BigInt value, [int scale = 0]) {
    return BigDecimal._(value, scale)._normalize();
  }

  factory BigDecimal.fromInt(int value, [int scale = 0]) {
    return BigDecimal._(BigInt.from(value), scale)._normalize();
  }

  static final BigDecimal zero = BigDecimal.fromInt(0);
  static final BigDecimal one = BigDecimal.fromInt(1);
  static final BigDecimal ten = BigDecimal.fromInt(10);

  static BigDecimal? tryParse(String source) {
    try {
      return parse(source);
    } catch (_) {
      return null;
    }
  }

  static BigDecimal parse(String source) {
    String str = source.trim().replaceAll(' ', '');
    if (str.isEmpty) {
      throw const FormatException("String input kosong.");
    }

    str = str.replaceAll(',', '.');

    int expIndex = str.indexOf(RegExp(r'[eE]'));
    int exponent = 0;
    if (expIndex != -1) {
      String expStr = str.substring(expIndex + 1);
      exponent = int.parse(expStr);
      str = str.substring(0, expIndex);
    }

    int dotIndex = str.indexOf('.');
    int scale = 0;
    String unscaledStr = str;

    if (dotIndex != -1) {
      scale = str.length - dotIndex - 1;
      unscaledStr = str.replaceFirst('.', '');
    }

    BigInt unscaledValue = BigInt.parse(unscaledStr);

    int finalScale = scale - exponent;

    if (finalScale < 0) {
      unscaledValue = unscaledValue * BigInt.from(10).pow(-finalScale);
      finalScale = 0;
    }

    return BigDecimal._(unscaledValue, finalScale)._normalize();
  }

  BigDecimal _normalize() {
    if (unscaledValue == BigInt.zero) {
      return BigDecimal._(BigInt.zero, 0);
    }

    BigInt val = unscaledValue;
    int currentScale = scale;

    while (currentScale > 0 && (val % BigInt.from(10) == BigInt.zero)) {
      val ~/= BigInt.from(10);
      currentScale--;
    }

    return BigDecimal._(val, currentScale);
  }

  BigDecimal operator +(BigDecimal other) {
    int maxScale = scale > other.scale ? scale : other.scale;
    BigInt a = _alignScale(maxScale);
    BigInt b = other._alignScale(maxScale);
    return BigDecimal._(a + b, maxScale)._normalize();
  }

  BigDecimal operator -(BigDecimal other) {
    int maxScale = scale > other.scale ? scale : other.scale;
    BigInt a = _alignScale(maxScale);
    BigInt b = other._alignScale(maxScale);
    return BigDecimal._(a - b, maxScale)._normalize();
  }

  BigDecimal operator *(BigDecimal other) {
    BigInt unscaled = unscaledValue * other.unscaledValue;
    int newScale = scale + other.scale;
    return BigDecimal._(unscaled, newScale)._normalize();
  }

  BigDecimal divide(BigDecimal other, {int maxScale = 40}) {
    if (other.isZero) {
      throw ArgumentError("Pembagian dengan nol tidak diperbolehkan.");
    }
    if (isZero) return zero;

    BigInt num = unscaledValue;
    BigInt den = other.unscaledValue;

    int scaleDiff = scale - other.scale;
    int targetScale = maxScale;

    if (targetScale < scaleDiff) {
      targetScale = scaleDiff;
    }

    int extraZeros = targetScale - scaleDiff;

    if (extraZeros > 0) {
      num = num * BigInt.from(10).pow(extraZeros);
    } else if (extraZeros < 0) {
      den = den * BigInt.from(10).pow(-extraZeros);
    }

    BigInt quotient = num ~/ den;
    BigInt remainder = (num % den).abs();

    if (remainder * BigInt.two >= den.abs()) {
      if (num.sign == den.sign) {
        quotient += BigInt.one;
      } else {
        quotient -= BigInt.one;
      }
    }

    return BigDecimal._(quotient, targetScale)._normalize();
  }

  BigDecimal operator -() {
    return BigDecimal._(-unscaledValue, scale);
  }

  BigInt _alignScale(int targetScale) {
    if (scale == targetScale) return unscaledValue;
    int diff = targetScale - scale;
    return unscaledValue * BigInt.from(10).pow(diff);
  }

  bool get isZero => unscaledValue == BigInt.zero;
  bool get isNegative => unscaledValue.isNegative;
  bool get isInteger => scale == 0;

  BigInt toBigInt() {
    if (scale == 0) return unscaledValue;
    return unscaledValue ~/ BigInt.from(10).pow(scale);
  }

  double toDouble() {
    return double.parse(toString());
  }

  @override
  int compareTo(BigDecimal other) {
    int maxScale = scale > other.scale ? scale : other.scale;
    BigInt a = _alignScale(maxScale);
    BigInt b = other._alignScale(maxScale);
    return a.compareTo(b);
  }

  bool operator <(BigDecimal other) => compareTo(other) < 0;
  bool operator <=(BigDecimal other) => compareTo(other) <= 0;
  bool operator >(BigDecimal other) => compareTo(other) > 0;
  bool operator >=(BigDecimal other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BigDecimal && compareTo(other) == 0;
  }

  @override
  int get hashCode => Object.hash(unscaledValue, scale);

  @override
  String toString() {
    if (scale == 0) return unscaledValue.toString();

    String sign = unscaledValue.isNegative ? '-' : '';
    String str = unscaledValue.abs().toString();

    if (str.length <= scale) {
      str = str.padLeft(scale + 1, '0');
    }

    int dotPos = str.length - scale;
    String integerPart = str.substring(0, dotPos);
    String fractionalPart = str.substring(dotPos);

    return '$sign$integerPart.$fractionalPart';
  }

  String toFormattedString() {
    String raw = toString();
    List<String> parts = raw.split('.');
    String intPart = parts[0];

    bool isNeg = intPart.startsWith('-');
    if (isNeg) intPart = intPart.substring(1);

    StringBuffer formattedInt = StringBuffer();
    int len = intPart.length;
    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) {
        formattedInt.write('.');
      }
      formattedInt.write(intPart[i]);
    }

    String result = (isNeg ? '-' : '') + formattedInt.toString();
    if (parts.length > 1) {
      result += ',${parts[1]}';
    }
    return result;
  }
}
