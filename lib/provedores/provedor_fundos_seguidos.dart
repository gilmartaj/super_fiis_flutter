import 'package:flutter/widgets.dart';
import 'package:super_fiis_flutter/dados/fundos_seguidos.dart';
import 'package:super_fiis_flutter/modelos/fundo.dart';
import 'package:super_fiis_flutter/provedores/provedor_fundos.dart';
import 'package:super_fiis_flutter/provedores/provedor_fundos_carregados.dart';
import 'package:super_fiis_flutter/repositorios/fundos_repositorio.dart';

class ProvedorFundosSeguidos
    extends InheritedNotifier<ControladorProvedorFundosSeguidos> {
  ProvedorFundosSeguidos(
      {Key? key, required Widget child, required BuildContext context})
      : super(
            key: key,
            child: child,
            notifier: ControladorProvedorFundosSeguidos(
                ProvedorFundosCarregados.controlador(context)!));

  //ControladorProvedorFundos get controlador => notifier!;

  static ProvedorFundosSeguidos? pegarDoContexto(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ProvedorFundosSeguidos>();
  }

  static ControladorProvedorFundosSeguidos? controlador(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ProvedorFundosSeguidos>()!
        .notifier!;
  }
}

class ControladorProvedorFundosSeguidos extends ChangeNotifier {
  final ControladorProvedorFundosCarregados provedor;
  ControladorProvedorFundosSeguidos(this.provedor);

  List<Fundo> get fundos =>
      provedor.fundos
          ?.where((fundo) => FundosSeguidos().fundos.contains(fundo.codigo!))
          .toList() ??
      [];

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
