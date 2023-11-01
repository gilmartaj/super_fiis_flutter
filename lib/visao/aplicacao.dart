import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:super_fiis_flutter/dados/historico_notificacoes.dart';
import 'package:super_fiis_flutter/dados/preferencias.dart';
import 'package:super_fiis_flutter/gerenciadores/gerenciador_favoritos.dart';
import 'package:super_fiis_flutter/modelos/mensagem_notificacao.dart';
import 'package:super_fiis_flutter/provedores/provedor_fundos.dart';
import 'package:super_fiis_flutter/provedores/provedor_fundos_carregados.dart';
import 'package:super_fiis_flutter/provedores/provedor_fundos_seguidos.dart';
import 'package:super_fiis_flutter/provedores/provedor_tema.dart';
import 'package:super_fiis_flutter/visao/rotas/tela_notificacoes.dart';
import 'package:super_fiis_flutter/visao/rotas/tela_principal.dart';

class Aplicacao extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProvedorTema(
      tema: (Preferencias().temaEscuroAtivado ?? true)
          ? ThemeData.dark()
          : ThemeData.light(),
      child: Builder(builder: (context) {
        return MaterialApp(
          theme: ProvedorTema.controlador(context)!.tema,
          home: Builder(builder: (context) {
            FirebaseMessaging.onMessageOpenedApp.listen(
              (event) {
                FirebaseMessaging.instance.getInitialMessage().then((value) {});
                FirebaseMessaging.instance.getInitialMessage().then((value) {});
                final notificacao = MensagemNotificacao(
                    titulo: event.notification?.title ?? "",
                    mensagem: event.notification?.body ?? "",
                    dataEHora: DateTime.now(),
                    dados: event.data);

                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => TelaNotificacoes(
                          notificacaoDeOrigem: notificacao,
                        )));
              },
            );

            return ProvedorFundosCarregados(
                child: Builder(
              builder: (context) => ProvedorFundosSeguidos(
                  child: TelaPrincipal(), context: context),
            ));
          }),
        );
      }),
    );
  }
}
