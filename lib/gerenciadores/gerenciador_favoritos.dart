import 'package:flutter/material.dart';
/*import 'package:super_fiis_flutter/dados/fundos_seguidos.dart';

class GerenciadorFundosSeguidos
    extends InheritedNotifier<_NotificadorGerenciadorFundosSeguidos> {
  //final List<String> _fundosSeguidos = [];

  List<String> get fundosSeguidos =>
      FundosSeguidos().fundos; //_fundosSeguidos.map((e) => e).toList();

  seguir(String codigoFundo) async {
    //_fundosSeguidos.add(codigoFundo);
    await FundosSeguidos().seguirFundo(codigoFundo);
    notifier?.notificarOuvintes();
    return true;
  }

  desinscrever(String codigoFundo) async {
    //_fundosSeguidos.remove(codigoFundo);
    await FundosSeguidos().desinscreverFundo(codigoFundo);
    notifier?.notificarOuvintes();
    return true;
  }

  GerenciadorFundosSeguidos({Key? key, required Widget child})
      : super(
            key: key,
            child: child,
            notifier: _NotificadorGerenciadorFundosSeguidos()) {
    print('Novo gerenciador');
  }

  static GerenciadorFundosSeguidos? pegarDoContexto(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<GerenciadorFundosSeguidos>();
  }
}

class _NotificadorGerenciadorFundosSeguidos extends ChangeNotifier {
  notificarOuvintes() {
    notifyListeners();
  }
}
*/