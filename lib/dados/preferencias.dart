import 'package:shared_preferences/shared_preferences.dart';

class Preferencias {
  static Preferencias? _instancia;
  SharedPreferences _prefs;

  Preferencias._(this._prefs);

  static Future<void> inicializar() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _instancia = Preferencias._(prefs);
  }

  bool? get temaEscuroAtivado => _prefs.getBool("temaEscuroAtivado");
  set temaEscuroAtivado(bool? b) => _prefs.setBool("temaEscuroAtivado", b!);

  factory Preferencias() {
    return _instancia!;
  }
}
