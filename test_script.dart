import 'lib/models/big_decimal.dart';

void main() {
  var a = BigDecimal.tryParse('124240190.124240191');
  var b = BigDecimal.tryParse('-124240192');
  
  print('a = $a');
  print('b = $b');
  
  if (a != null && b != null) {
    print('a * b = ${a * b}');
    print('formatted = ${(a * b).toFormattedString()}');
  }
}
