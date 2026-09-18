// lib/features/calculator_t1/logic/calculator_service.dart
import 'big_decimal.dart';
import 'calculation_result.dart';

class KalkulatorService {
  final List<String> _tokens = [];

  void tambahInput(String input) {
    String trimmed = input.trim();
    if (trimmed.isEmpty) return;

    RegExp tokenRegExp = RegExp(r'(\d+(?:[\.,]\d+)?(?:[eE][+-]?\d+)?|[\+\-\*/\(\)])');
    Iterable<RegExpMatch> matches = tokenRegExp.allMatches(trimmed);

    for (Match m in matches) {
      String item = m.group(0)!;
      _prosesSingleItem(item);
    }
  }

  void _prosesSingleItem(String item) {
    bool isOp = _isOperator(item);
    bool isParen = item == '(' || item == ')';
    BigDecimal? val = BigDecimal.tryParse(item);

    if (isOp) {
      if (_tokens.isEmpty) {
        if (item == '-' || item == '+') {
          _tokens.add('0');
          _tokens.add(item);
        }
      } else if (_isOperator(_tokens.last)) {
        _tokens[_tokens.length - 1] = item;
      } else {
        _tokens.add(item);
      }
    } else if (isParen) {
      _tokens.add(item);
    } else if (val != null) {
      if (_tokens.isNotEmpty && !_isOperator(_tokens.last) && _tokens.last != '(') {
        _tokens.add('+');
      }
      _tokens.add(val.toString());
    }
  }

  bool hapusTerakhir() {
    if (_tokens.isNotEmpty) {
      _tokens.removeLast();
      return true;
    }
    return false;
  }

  void reset() {
    _tokens.clear();
  }

  void setEkspresi(List<String> newTokens) {
    _tokens.clear();
    _tokens.addAll(newTokens);
  }

  bool get apakahKosong => _tokens.isEmpty;

  String get teksEkspresi {
    if (_tokens.isEmpty) return '';
    return _tokens.join(' ');
  }

  HasilKalkulasi hitung() {
    if (_tokens.isEmpty) return HasilKalkulasi.gagal('Ekspresi masih kosong.');

    List<String> expr = List.from(_tokens);
    while (expr.isNotEmpty && _isOperator(expr.last)) {
      expr.removeLast();
    }

    if (expr.isEmpty) return HasilKalkulasi.gagal('Ekspresi belum lengkap.');

    try {
      BigDecimal result = _evaluateTokens(expr);
      return HasilKalkulasi.sukses(result);
    } catch (e) {
      return HasilKalkulasi.gagal(
        e.toString().replaceAll('Exception: ', '').replaceAll('ArgumentError: ', ''),
      );
    }
  }

  static bool _isOperator(String token) {
    return token == '+' || token == '-' || token == '*' || token == '/';
  }

  static int _precedence(String op) {
    if (op == '+' || op == '-') return 1;
    if (op == '*' || op == '/') return 2;
    return 0;
  }

  static BigDecimal _evaluateTokens(List<String> tokens) {
    List<BigDecimal> values = [];
    List<String> ops = [];

    int i = 0;
    while (i < tokens.length) {
      String t = tokens[i];

      if (t == '(') {
        ops.add(t);
        i++;
      } else if (t == ')') {
        while (ops.isNotEmpty && ops.last != '(') {
          _applyOp(values, ops.removeLast());
        }
        if (ops.isEmpty || ops.last != '(') {
          throw const FormatException('Format ekspresi tidak valid (tanda kurung tidak seimbang).');
        }
        ops.removeLast();
        i++;
      } else if (_isOperator(t)) {
        bool isUnary = (i == 0 || _isOperator(tokens[i - 1]) || tokens[i - 1] == '(');
        if (isUnary) {
          if (t == '-') {
            if (i + 1 < tokens.length) {
              BigDecimal? nextVal = BigDecimal.tryParse(tokens[i + 1]);
              if (nextVal != null) {
                values.add(-nextVal);
                i += 2;
                continue;
              }
            }
            values.add(BigDecimal.zero);
          } else if (t == '+') {
            i++;
            continue;
          }
        }

        while (ops.isNotEmpty && ops.last != '(' && _precedence(ops.last) >= _precedence(t)) {
          _applyOp(values, ops.removeLast());
        }
        ops.add(t);
        i++;
      } else {
        BigDecimal? num = BigDecimal.tryParse(t);
        if (num == null) throw FormatException('Angka tidak valid: "$t"');
        values.add(num);
        i++;
      }
    }

    while (ops.isNotEmpty) {
      if (ops.last == '(' || ops.last == ')') {
        throw const FormatException('Format ekspresi tidak valid (tanda kurung tidak seimbang).');
      }
      _applyOp(values, ops.removeLast());
    }

    if (values.length != 1) throw const FormatException('Format ekspresi tidak valid.');
    return values.first;
  }

  static void _applyOp(List<BigDecimal> values, String op) {
    if (values.length < 2) throw const FormatException('Format ekspresi tidak lengkap.');
    BigDecimal b = values.removeLast();
    BigDecimal a = values.removeLast();

    switch (op) {
      case '+':
        values.add(a + b);
        break;
      case '-':
        values.add(a - b);
        break;
      case '*':
        values.add(a * b);
        break;
      case '/':
        if (b.isZero) throw ArgumentError('Error! Tidak bisa dibagi dengan nol.');
        values.add(a.divide(b, maxScale: 50));
        break;
      default:
        throw FormatException('Operator tidak dikenal: "$op"');
    }
  }
}
