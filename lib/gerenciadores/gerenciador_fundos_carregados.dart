/*import 'package:flutter/material.dart';
import 'package:super_fiis_flutter/gerenciadores/notificador.dart';
import 'package:super_fiis_flutter/modelos/fundo.dart';
import 'package:super_fiis_flutter/repositorios/fundos_repositorio.dart';

class GerenciadorFundosCarregados extends InheritedNotifier<Notificador> {
  final _controlador = _GerenciadorFundosCarregados();

  get temErro => _controlador.erro;
  get fundosCarregados => _controlador.fundos?.map((e) => e).toList();

  GerenciadorFundosCarregados({Key? key, required Widget child})
      : super(key: key, child: child, notifier: Notificador()) {
    carregar();
  }

  static GerenciadorFundosCarregados? pegarDoContexto(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<GerenciadorFundosCarregados>();
  }

  carregar() async {
    _controlador.erro = false;
    notifier!.notificarOuvintes();
    await _controlador.carregarFundos();
    notifier!.notificarOuvintes();
  }
}

class _GerenciadorFundosCarregados {
  final repositorio = FundosRepositorio();
  List<Fundo>? fundos;
  bool erro = false;

  carregarFundos() async {
    erro = false;
    //await Future.delayed(Duration(seconds: 3));
    fundos = await repositorio.buscarTodos();
    if (fundos == null) {
      erro = true;
    }
  }
}*/

/*
class ProvedorFundos extends InheritedNotifier<ControladorProvedorFundos> { 

  ProvedorFundos({Key? key, required Widget child})
      : super(key: key, child: child, notifier: ControladorProvedorFundos()) {
    notifier!.carregar();
  }
  
  ControladorProvedorFundos get controlador => notifier!;

  static ProvedorFundos? pegarDoContexto(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ProvedorFundos>();
  }

}

class ControladorProvedorFundos extends ChangeNotifier{
  final _repositorio = FundosRepositorio();
  List<Fundo>? _fundos;
  bool _erro = false;

  bool get temErro => _erro;
  get fundosCarregados => _fundos?.map((e) => e).toList();

  carregarFundos() async {
    _erro = false;
    notifyListeners();
    //await Future.delayed(Duration(seconds: 3));
    _fundos = await _repositorio.buscarTodos();
    if (_fundos == null) {
      _erro = true;
    }
    notifyListeners();
    }
}
*/