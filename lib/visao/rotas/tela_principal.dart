import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:install_plugin/install_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:super_fiis_flutter/dados/historico_notificacoes.dart';
import 'package:super_fiis_flutter/gerenciadores/gerenciador_fundos_carregados.dart';
import 'package:super_fiis_flutter/modelos/dados_baixar_arquivo.dart';
import 'package:super_fiis_flutter/modelos/mensagem_notificacao.dart';
import 'package:super_fiis_flutter/provedores/provedor_fundos.dart';
import 'package:super_fiis_flutter/provedores/provedor_fundos_carregados.dart';
import 'package:super_fiis_flutter/provedores/provedor_tema.dart';
import 'package:super_fiis_flutter/utilitarios/baixador_arquivo.dart';
import 'package:super_fiis_flutter/visao/componentes/indicador_de_progresso.dart';
import 'package:super_fiis_flutter/visao/rotas/tela_ajustes.dart';
import 'package:super_fiis_flutter/visao/rotas/tela_fundos_seguidos.dart';
import 'package:super_fiis_flutter/visao/rotas/tela_notificacoes.dart';
import 'package:super_fiis_flutter/visao/rotas/tela_todos_fundos.dart';

class TelaPrincipal extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TelaPrincipalState();
  }
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  final controlador = _ControladorTelaPrincipal();
  final controladorPaginas = PageController();
  int paginaAtual = 0;
  final TelaTodosFundos telaTodosFundos = TelaTodosFundos();
  final TelaFundosSeguidos telaFundosSeguidos = TelaFundosSeguidos();

  void verificarSeFoiAbertoDeUmaNotificacaoLocal() async {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await FlutterLocalNotificationsPlugin()
            .getNotificationAppLaunchDetails();
    final notificationResponse =
        notificationAppLaunchDetails?.notificationResponse;
    if (notificationResponse != null) {
      final payload = jsonDecode(notificationResponse.payload ?? "{}");
      if (notificationResponse.payload != null) {
        debugPrint('notification payload: $payload');
      }

      final notificacao = MensagemNotificacao(
          titulo: "tituko",
          mensagem: "mensagem",
          dataEHora: DateTime.now(),
          dados: payload);

      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => TelaNotificacoes(
                notificacaoDeOrigem: notificacao,
              )));
    }
  }

  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final payload = jsonDecode(notificationResponse.payload ?? "{}");
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
    }

    final notificacao = MensagemNotificacao(
        titulo: "tituko",
        mensagem: "mensagem",
        dataEHora: DateTime.now(),
        dados: payload);

    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TelaNotificacoes(
              notificacaoDeOrigem: notificacao,
            )));
    //await Navigator.push(
    //  context,
    // MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
    //);
  }

  Future<void> inicializarNotificacoes() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    inicializarNotificacoes();
    /*WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      GerenciadorFundosCarregados.pegarDoContexto(context)!.carregar();
    });*/
    FirebaseMessaging.onMessage.listen((event) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Notificação recebida")));
      controlador.adicionarNotificacao();
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final event = await FirebaseMessaging.instance.getInitialMessage();
      if (event != null) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => TelaNotificacoes(
              notificacaoDeOrigem: MensagemNotificacao(
                  titulo: event.notification?.title,
                  mensagem: event.notification?.body,
                  dataEHora: DateTime.now(),
                  dados: event.data)),
        ));

////////////////////////////////

        final NotificationAppLaunchDetails? notificationAppLaunchDetails =
            await FlutterLocalNotificationsPlugin()
                .getNotificationAppLaunchDetails();
        final notificationResponse =
            notificationAppLaunchDetails?.notificationResponse;
        if (notificationResponse != null) {
          final payload = jsonDecode(notificationResponse.payload ?? "{}");
          if (notificationResponse.payload != null) {
            debugPrint('notification payload: $payload');
          }

          final notificacao = MensagemNotificacao(
              titulo: "tituko",
              mensagem: "mensagem",
              dataEHora: DateTime.now(),
              dados: payload);

          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => TelaNotificacoes(
                    notificacaoDeOrigem: notificacao,
                  )));
        }
      }
    });
  }

  bool _temaEscuro = false;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final provedorFundosCarregados =
        ProvedorFundosCarregados.controlador(context)!;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Super FIIs"),
          actions: [
            /*GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => TelaNotificacoes(),
                ));
                controlador.noticacoesNaoLidas = 0;
              },
              child: Container(
                color: Colors.transparent,
                margin: EdgeInsets.only(right: 30, top: 15),
                child: ListenableBuilder(
                  listenable: controlador,
                  builder: (context, child) => Badge(
                    offset: Offset(0, 5),
                    child: Icon(Icons.notifications),
                    //backgroundColor: Colors.blue,
                    isLabelVisible: controlador.noticacoesNaoLidas > 0,
                    label: Text(
                      "${controlador.noticacoesNaoLidas}",
                      style: TextStyle(letterSpacing: 0, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),*/
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => TelaNotificacoes(),
                ));
                HistoricoNotifiacoes().limparNovas();
                controlador.noticacoesNaoLidas = 0;
              },
              child: Container(
                color: Colors.transparent,
                margin: EdgeInsets.only(right: 30, top: 15),
                child: ListenableBuilder(
                  listenable: HistoricoNotifiacoes().observavel,
                  builder: (context, child) => Container(
                    margin: EdgeInsets.only(top: 2),
                    child: Stack(
                      children: [
                        Container(
                            //margin: EdgeInsets.only(top: 5),
                            child: Icon(Icons.notifications)),
                        controlador.noticacoesNaoLidas <= 0
                            ? Container()
                            : SizedBox(
                                width: 25,
                                height: 25,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(right: 2),
                                      padding: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.red),
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        heightFactor: 1,
                                        widthFactor: 1,
                                        child: Text(
                                          controlador.noticacoesNaoLidas < 100
                                              ? "${controlador.noticacoesNaoLidas}"
                                              : "99+",
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontFamily: "monospaced"),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        drawer: ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85),
          child: Drawer(
            child: ListView(
              children: [
                /*DrawerHeader(
                  child: Container(
                      child: Center(
                    child: Text(
                      "Super FIIs",
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  )),
                  decoration: BoxDecoration(color: Colors.blue),
                ),*/
                Container(
                  color: Theme.of(context).primaryColor,
                  child: ListTile(
                      title: Text(
                    "Super FIIs",
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  )),
                ),
                ListTile(
                  title: Text("Ajustes"),
                  leading: Icon(Icons.build_outlined),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => TelaAjustes(),
                  )),
                ),
                ListTile(
                  title: Text("Contato"),
                  leading: Icon(Icons.email_outlined),
                ),
                ListTile(
                  title: Text("Sobre"),
                  leading: Icon(Icons.info_outlined),
                ),
                ListTile(
                  title: Text("Tema Escuro"),
                  leading: Icon(
                      ProvedorTema.controlador(context)!.temaEscuroAtivado
                          ? Icons.nightlight_outlined
                          : Icons.wb_sunny_outlined),
                  trailing: Switch(
                      //inactiveThumbColor: Colors.blue,
                      activeColor: Color.fromARGB(250, 50, 170, 240),
                      value:
                          ProvedorTema.controlador(context)!.temaEscuroAtivado,
                      onChanged: (v) =>
                          ProvedorTema.controlador(context)!.alterarTema()),
                ),
                ListTile(
                  title: Text("Verificar atualizações"),
                  leading: Icon(Icons.update_outlined),
                  tileColor: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  iconColor: Colors.white,
                  onTap: () async {
                    Navigator.of(context).pop();
                    final arq = await BaixadorArquivo().baixarArquivo(
                        DadosBaixarArquivo(
                            endereco: "http://192.168.1.10:8080/apk",
                            cabecalhos: {},
                            nome: "superfiisapp.apk"),
                        (await getTemporaryDirectory()).path,
                        funcaoAlteracaoEstado: _atualizarSituacaoDescarga);
                    await Future.delayed(Duration(seconds: 5));
                    final permissao =
                        await Permission.requestInstallPackages.request();
                    if (permissao.isGranted) {
                      InstallPlugin.install(arq.path);
                    }
                  },
                )
              ],
            ),
          ),
        ),
        body: provedorFundosCarregados.fundos == null &&
                !provedorFundosCarregados.temErro
            ? IndicadorDeProgresso()
            : PageView(
                children: [telaTodosFundos, telaFundosSeguidos],
                controller: controladorPaginas,
                onPageChanged: (value) => setState(() {
                  paginaAtual = value;
                }),
              ),
        bottomNavigationBar: provedorFundosCarregados.fundos == null
            ? null
            : BottomNavigationBar(
                selectedItemColor: Colors.blue,
                onTap: (value) {
                  controladorPaginas.animateToPage(paginaAtual = value,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.linear);
                },
                currentIndex: paginaAtual,
                items: const [
                    BottomNavigationBarItem(
                        icon: Icon(Icons.home), label: "Todos"),
                    BottomNavigationBarItem(
                        icon: Icon(
                          Icons.star,
                        ),
                        label: "Seguidos")
                  ]),
      ),
    );
  }

  _atualizarSituacaoDescarga(int baixados, int? total) async {
    if (total != null) {
      await Future.delayed(Duration(milliseconds: 500));
      double percentualBaixado = baixados / total * 100;
      //print(percentualBaixado = baixados / total);
      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
      print("$baixados -> $total");
      ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
          key: UniqueKey(),
          content: Text("Baixando..."),
          actions: [Text("${percentualBaixado.toInt()}%")]));
      setState(() {});
    }
  }
}

class _ControladorTelaPrincipal extends ChangeNotifier {
  int _noticacoesNaoLidas = 0;

  int get noticacoesNaoLidas => HistoricoNotifiacoes().novas;

  set noticacoesNaoLidas(int n) {
    _noticacoesNaoLidas = n;
    notifyListeners();
  }

  adicionarNotificacao() {
    _noticacoesNaoLidas++;
    notifyListeners();
  }
}
