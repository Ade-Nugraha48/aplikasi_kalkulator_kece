// ignore_for_file: avoid_print
import 'package:postgres/postgres.dart';

void main() async {
  print(ConnectionSettings(sslMode: SslMode.disable));
  print(Sql.named('SELECT * FROM users WHERE username = @u AND password = @p'));
}
