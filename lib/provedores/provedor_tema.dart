import 'package:flutter/material.dart';
import 'package:super_fiis_flutter/dados/preferencias.dart';

class ProvedorTema extends InheritedNotifier<ControladorProvedorTema> {
  ProvedorTema({Key? key, required ThemeData tema, required Widget child})
      : super(key: key, child: child, notifier: ControladorProvedorTema(tema));

  static ProvedorTema? pegarDoContexto(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ProvedorTema>();
  }

  static ControladorProvedorTema? controlador(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ProvedorTema>()!
        .notifier!;
  }
}

class ControladorProvedorTema extends ChangeNotifier {
  ThemeData tema;

  ControladorProvedorTema(this.tema);

  bool get temaEscuroAtivado => tema.brightness == Brightness.dark;

  void alterarTema() {
    if (tema.brightness == Brightness.light) {
      tema = ThemeData.dark(); //tema.copyWith(brightness: Brightness.dark);
    } else {
      tema = ThemeData.light(); //tema.copyWith(brightness: Brightness.light);
    }
    Preferencias().temaEscuroAtivado = (tema == ThemeData.dark());
    notifyListeners();
  }
}
