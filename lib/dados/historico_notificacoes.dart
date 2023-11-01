import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:super_fiis_flutter/modelos/mensagem_notificacao.dart';

class HistoricoNotifiacoes {
  static HistoricoNotifiacoes? instancia;

  late LazyBox<MensagemNotificacao> _box;
  static final observavel1 = ValueNotifier<bool>(false);
  int _novas;

  HistoricoNotifiacoes._(this._box, this._novas) {
    print("ccc");
    _box.listenable().addListener(() {
      observavel1.value = !observavel1.value;
    });
  }

  static inicializar() async {
    if (Hive.isBoxOpen("HistoricoNotificacoes")) {
      await HistoricoNotifiacoes().box.close();
    }
    final box =
        await Hive.openLazyBox<MensagemNotificacao>("HistoricoNotificacoes");
    if (box.isEmpty) {
      box.add(MensagemNotificacao(dados: {"novas": 0}));
    }
    instancia =
        HistoricoNotifiacoes._(box, (await box.get(0))?.dados?["novas"] ?? 0);
    observavel1.value = !observavel1.value;
  }

  Listenable get observavel => HistoricoNotifiacoes.observavel1;

  int get total => _box.length - 1;

  int get novas => _novas;

  Future<void> adicionar(MensagemNotificacao notificacao) async {
    await _box.add(notificacao);
    _atualizarNovas(novas + 1);
  }

  Future<MensagemNotificacao?> ler(int indice) async {
    return _box.getAt(indice + 1);
  }

  Future<void> marcarComoLida(int indice) async {
    int i = indice + 1;
    _box.putAt(i, (await _box.getAt(i))!..clicada = true);
  }

  Future<void> buscarEMarcarComoLida(MensagemNotificacao mensagem) async {
    for (int i = _box.length - 1; i > 0; i--) {
      MensagemNotificacao? mn = await _box.getAt(i);
      if (mn != null &&
          mn.titulo == mensagem.titulo &&
          mn.mensagem == mensagem.mensagem &&
          mapEquals(mn.dados, mensagem.dados)) {
        mn.clicada = true;
        _box.putAt(i, mn);
        break;
      }
    }
  }

  void observarEm(Function() observador) {
    observavel.addListener(observador);
  }

  void removerObservador(Function() observador) {
    observavel.removeListener(observador);
  }

  _atualizarNovas(int novas) async {
    _novas = novas;
    _box.putAt(0, MensagemNotificacao(dados: {"novas": novas}));
  }

  limparNovas() async {
    if (novas != 0) {
      await _atualizarNovas(0);
    }
  }

  LazyBox<MensagemNotificacao> get box => _box;

  factory HistoricoNotifiacoes() {
    return instancia!;
  }
}

/*class HistoricoNotifiacoesReverso extends HistoricoNotifiacoes {
  HistoricoNotifiacoesReverso(LazyBox<MensagemNotificacao> box) : super._(box);

  @override
  Future<MensagemNotificacao?> ler(int indice) async {
    return box.getAt(box.length - indice - 1);
  }

  @override
  Future<void> marcarComoLida(int indice) async {
    final i = box.length - indice - 1;
    box.putAt(i, (await box.getAt(i))!..clicada = true);
  }
}*/
