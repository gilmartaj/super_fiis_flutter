import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:super_fiis_flutter/dados/historico_notificacoes.dart';
import 'package:super_fiis_flutter/modelos/documento.dart';
import 'package:super_fiis_flutter/modelos/mensagem_notificacao.dart';
import 'package:super_fiis_flutter/visao/componentes/barra_superior.dart';
import 'package:super_fiis_flutter/visao/rotas/tela_exibir_documento_pdf.dart';

class TelaNotificacoes extends StatefulWidget {
  final MensagemNotificacao? notificacaoDeOrigem;

  TelaNotificacoes({this.notificacaoDeOrigem});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TelaNotificacoesState();
  }
}

class _TelaNotificacoesState extends State<TelaNotificacoes> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    HistoricoNotifiacoes().observarEm(_atualizarEstado);
    WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) => HistoricoNotifiacoes().limparNovas());
    if (widget.notificacaoDeOrigem != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) {
          Timer(
              Duration(seconds: 2),
              () => HistoricoNotifiacoes()
                  .buscarEMarcarComoLida(widget.notificacaoDeOrigem!));
          if ((widget.notificacaoDeOrigem!.dados?.containsKey("tipo") ??
                  false) &&
              widget.notificacaoDeOrigem!.dados!["tipo"] == "documento") {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => TelaExibirDocumentoPdf(
                      documento:
                          Documento.fromMap(widget.notificacaoDeOrigem!.dados!),
                    )));
          }
        },
      );
    }
  }

  _atualizarEstado() {
    setState(() {});

    Future.doWhile(() async {
      try {
        HistoricoNotifiacoes().limparNovas();
        return false;
      } catch (e) {
        await Future.delayed(const Duration(milliseconds: 100));
        return true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //HistoricoNotifiacoes.inicializar();
    // TODO: implement build
    return SafeArea(
      child: Scaffold(
        appBar: BarraSuperior.construir(titulo: "Notificações"),
        body: ListView.builder(
          itemCount: HistoricoNotifiacoes().total,
          itemBuilder: (context, index) {
            return FutureBuilder<MensagemNotificacao?>(
              future: HistoricoNotifiacoes()
                  .ler(HistoricoNotifiacoes().total - index - 1),
              builder: (context, snapshot) {
                print(index);
                //if (snapshot.hasData)
                DateTime? dt = snapshot.data?.dataEHora;

                return ListTile(
                  onTap: () async {
                    if (snapshot.data?.dados != null) {}
                    if (!(snapshot.data?.clicada ?? true))
                      await Future.microtask(() => setState(() {
                            HistoricoNotifiacoes().marcarComoLida(
                                HistoricoNotifiacoes().total - index - 1);
                          }));
                    if ((snapshot.data!.dados?.containsKey("tipo") ?? false) &&
                        snapshot.data!.dados!["tipo"] == "documento") {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => TelaExibirDocumentoPdf(
                                documento:
                                    Documento.fromMap(snapshot.data!.dados!),
                              )));
                    }
                  },
                  tileColor: snapshot.data?.clicada ?? true
                      ? Theme.of(context).canvasColor
                      : Theme.of(context).highlightColor,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snapshot.data?.titulo ?? "",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        //"\u{01F4B0} Rendimento: R\$0,10\n\u{01F4C5} Data-base: 10/10/2023\n\u{01F4B8} Data de pagamento: 15/10/2023",
                        snapshot.data?.mensagem ?? "",
                        style: TextStyle(fontWeight: FontWeight.normal),
                      )
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Text(snapshot.data?.mensagem ?? "-"),
                      if (dt != null)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text("${dt.day.toString().padLeft(2, '0')}"
                              "/${dt.month.toString().padLeft(2, '0')}"
                              "/${dt.year}"),
                        )
                    ],
                  ),
                  isThreeLine: true,
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    HistoricoNotifiacoes().removerObservador(_atualizarEstado);
    super.dispose();
  }
}

class _ControladorTelaNotificacoes extends ChangeNotifier {}
