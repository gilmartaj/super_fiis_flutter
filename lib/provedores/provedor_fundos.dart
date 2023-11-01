import 'package:flutter/widgets.dart';
import 'package:super_fiis_flutter/dados/fundos_seguidos.dart';
import 'package:super_fiis_flutter/modelos/fundo.dart';
import 'package:super_fiis_flutter/repositorios/fundos_repositorio.dart';

/*class ProvedorFundos extends InheritedNotifier<ControladorProvedorFundos> {
  ProvedorFundos({Key? key, required Widget child})
      : super(key: key, child: child, notifier: ControladorProvedorFundos()) {
    notifier!.carregarFundos();
  }

  //ControladorProvedorFundos get controlador => notifier!;

  static ProvedorFundos? pegarDoContexto(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ProvedorFundos>();
  }

  static ControladorProvedorFundos? controlador(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ProvedorFundos>()!
        .notifier!;
  }
}

class ControladorProvedorFundos extends ChangeNotifier {
  final _repositorio = FundosRepositorio();
  List<Fundo>? _fundos;
  bool _erro = false;

  bool get temErro => _erro;
  List<Fundo>? get fundosCarregados => _fundos?.map((e) => e).toList();
  List<Fundo> get fundosSeguidos =>
      fundosCarregados
          ?.where((fundo) => FundosSeguidos().fundos.contains(fundo.codigo!))
          .toList() ??
      [];

  get x => FundosSeguidos().fundos;

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

  seguir(String codigoFundo) async {
    //_fundosSeguidos.add(codigoFundo);
    await FundosSeguidos().seguirFundo(codigoFundo);
    notifyListeners();
    return true;
  }

  desinscrever(String codigoFundo) async {
    //_fundosSeguidos.remove(codigoFundo);
    await FundosSeguidos().desinscreverFundo(codigoFundo);
    notifyListeners();
    return true;
  }
}
*/