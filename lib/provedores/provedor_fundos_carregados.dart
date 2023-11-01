import 'package:flutter/widgets.dart';
import 'package:super_fiis_flutter/dados/fundos_seguidos.dart';
import 'package:super_fiis_flutter/modelos/fundo.dart';
import 'package:super_fiis_flutter/repositorios/fundos_repositorio.dart';

class ProvedorFundosCarregados
    extends InheritedNotifier<ControladorProvedorFundosCarregados> {
  ProvedorFundosCarregados({Key? key, required Widget child})
      : super(
            key: key,
            child: child,
            notifier: ControladorProvedorFundosCarregados()) {
    notifier!.carregarFundos();
  }

  //ControladorProvedorFundos get controlador => notifier!;

  static ProvedorFundosCarregados? pegarDoContexto(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ProvedorFundosCarregados>();
  }

  static ControladorProvedorFundosCarregados? controlador(
      BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ProvedorFundosCarregados>()!
        .notifier!;
  }
}

class ControladorProvedorFundosCarregados extends ChangeNotifier {
  final _repositorio = FundosRepositorio();
  List<Fundo>? _fundos;
  bool _erro = false;

  bool get temErro => _erro;
  List<Fundo>? get fundos => _fundos?.map((e) => e).toList();

  get x => FundosSeguidos().fundos;

  carregarFundos() async {
    _erro = false;
    _fundos = null;
    notifyListeners();
    //await Future.delayed(Duration(seconds: 3));
    _fundos = await _repositorio.buscarTodos();
    if (_fundos == null) {
      _erro = true;
    }
    notifyListeners();
  }
}
