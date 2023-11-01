import 'package:hive/hive.dart';

class FundosSeguidos {
  static FundosSeguidos? instancia;

  late Box<bool> box;

  FundosSeguidos._();

  static inicializar() async {
    instancia = FundosSeguidos._();
    instancia!.box = await Hive.openBox("FundosSeguidos");
  }

  Future<bool> alternarSituacao(String codigo) async {
    if (box.containsKey(codigo)) {
      await box.delete(codigo);
      return false;
    }
    await box.put(codigo, true);
    return true;
  }

  seguirFundo(String codigo) async {
    await box.put(codigo, true);
  }

  desinscreverFundo(String codigo) async {
    if (box.containsKey(codigo)) {
      await box.delete(codigo);
    }
  }

  bool eSeguido(String codigo) {
    return box.containsKey(codigo);
  }

  List<String> get fundos =>
      List.from(box.keys); // box.keys.toList().cast<String>();

  factory FundosSeguidos() {
    return instancia!;
  }
}
