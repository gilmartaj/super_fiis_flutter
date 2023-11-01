import 'dart:convert';

import 'package:super_fiis_flutter/modelos/fundo.dart';
import 'package:http/http.dart' as http;
import 'package:super_fiis_flutter/modelos/mensagem_notificacao.dart';
import 'package:super_fiis_flutter/modelos/tipo_mensagem_notificacao.dart';

class SincronizacaoRepositorio {
  static const String enderecoBase = "http://192.168.1.5:8080";

  Future<List<MensagemNotificacao>?> sincronizarNotificacoes(
      int inicio, int fim, List<String> topicos) async {
    try {
      return (jsonDecode((await http.post(
                  Uri.parse(
                      "$enderecoBase/sincronizarNotificacoes?inicio=$inicio&fim=$fim"),
                  body: jsonEncode({"topicos": topicos}),
                  headers: {
            "content-type": "application/json"
          }))
              .body) as List)
          .cast<List>()
          .map((e) => MensagemNotificacao(
              titulo: e[2],
              mensagem: e[3],
              dados: jsonDecode((e[4] as String).replaceAll("'", '"')),
              dataEHora: DateTime.now(),
              tipo: TipoMensagemNotificacao.documento))
          .toList();
    } catch (e) {
      return null;
    }
  }
}
