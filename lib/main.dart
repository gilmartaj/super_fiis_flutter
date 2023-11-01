import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_fiis_flutter/adaptadores/mensagem_notificacao_adaptador_hive.dart';
import 'package:super_fiis_flutter/dados/fundos_seguidos.dart';
import 'package:super_fiis_flutter/dados/historico_notificacoes.dart';
import 'package:super_fiis_flutter/dados/preferencias.dart';
import 'package:super_fiis_flutter/modelos/mensagem_notificacao.dart';
import 'package:super_fiis_flutter/modelos/tipo_mensagem_notificacao.dart';
import 'package:super_fiis_flutter/repositorios/fundos_repositorio.dart';
import 'package:super_fiis_flutter/repositorios/sincronizacao_repositorio.dart';
import 'package:super_fiis_flutter/utilitarios/suavizador_de_repeticoes.dart';
import 'package:super_fiis_flutter/visao/aplicacao.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

final chaveNavegadorDeTelas = GlobalKey<NavigatorState>();

void processarNotificacao(RemoteMessage event) async {
  print("mensagem background");
  Hive.initFlutter();
  //if (Hive.isBoxOpen("HistoricoNotificacoes")) {
  //  await HistoricoNotifiacoes().box.close();
  //}
  await HistoricoNotifiacoes.inicializar();
  print(HistoricoNotifiacoes().total);
  if (event.data.isNotEmpty) {
    if (event.data.containsKey("tipo") &&
        event.data["tipo"] == DescricaoTipoMensagemNotificacao.documento) {
      await HistoricoNotifiacoes().adicionar(MensagemNotificacao(
          titulo: event.notification?.title,
          mensagem: event.notification?.body,
          dataEHora: DateTime.now(),
          dados: event.data));
    }
  }
  //await HistoricoNotifiacoes().box.close();
}

class Sincronizacao {
  static const chaveUltimaSincronizacao = "ultimaSincronizacao";

  static final evitadorRepeticao =
      SuavizadorDeRepeticoes(const Duration(seconds: 2));

  static Future<void> sincronizarNotificacoes(int momento) async {
    //final momento = DateTime.timestamp().microsecondsSinceEpoch;
    SincronizacaoRepositorio sinc = SincronizacaoRepositorio();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final notificacoes = await sinc.sincronizarNotificacoes(
        prefs.getInt(chaveUltimaSincronizacao) ?? momento,
        momento,
        FundosSeguidos().fundos);
    if (notificacoes != null) {
      for (final not in notificacoes) {
        await HistoricoNotifiacoes().adicionar(not);
        exibirNotificacao(not);
        final ultimaSincronizacao = not.dataEHora?.microsecondsSinceEpoch;
        if (ultimaSincronizacao != null &&
            ultimaSincronizacao >
                (prefs.getInt(chaveUltimaSincronizacao) ??
                    ultimaSincronizacao)) {
          await prefs.setInt(chaveUltimaSincronizacao, ultimaSincronizacao);
        }
        print(not.titulo);
      }
    }
  }

  static Future<void> inicializacao(DateTime momento) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getInt(chaveUltimaSincronizacao) == null) {
      await prefs.setInt(
          chaveUltimaSincronizacao, momento.microsecondsSinceEpoch);
    }
  }
}

Future<void> inicializarPreferencias() async {
  await Preferencias.inicializar();
  Preferencias preferencias = Preferencias();
  preferencias.temaEscuroAtivado ??=
      WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
}

@pragma('vm:entry-point')
Future<void> processarNotificacoesEmSegundoPlano(RemoteMessage event) async {
  print("mensagem background");
  await Hive.initFlutter();
  Hive.registerAdapter(MensagemNotificacaoAdaptadorHive(), override: true);
  if (Hive.isBoxOpen("HistoricoNotificacoes")) {
    await HistoricoNotifiacoes().box.close();
  }
  await HistoricoNotifiacoes.inicializar();
  print(HistoricoNotifiacoes().total);

  await FundosSeguidos.inicializar();

  int momento = event.data.containsKey("momento_microsseg")
      ? (int.tryParse(event.data["momento_microsseg"]) ??
              DateTime.now().microsecondsSinceEpoch) -
          1
      : DateTime.now().microsecondsSinceEpoch;
  await Sincronizacao.sincronizarNotificacoes(momento);

  if (event.data.isNotEmpty) {
    if (event.data.containsKey("tipo") &&
        event.data["tipo"] == DescricaoTipoMensagemNotificacao.documento) {
      await HistoricoNotifiacoes().adicionar(MensagemNotificacao(
          titulo: event.notification?.title,
          mensagem: event.notification?.body,
          dataEHora: DateTime.now(),
          dados: event.data));
    }
  }
}

/*void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
    }
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
    );
}*/

Future<void> inicializarNotificacoes() async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    //onDidReceiveNotificationResponse: onDidReceiveNotificationResponse
  );
}

void exibirNotificacao(MensagemNotificacao notificacao) async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    'notificacoes', 'Notificações',
    channelDescription: 'Canal de Notificações do SupetFIIs',
    //importance: Importance.max,
    //priority: Priority.high,
    //playSound: false,
  );
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);
  await FlutterLocalNotificationsPlugin().show(
      (notificacao.dataEHora?.microsecondsSinceEpoch ?? 0) % 1000000,
      notificacao.titulo,
      notificacao.mensagem,
      notificationDetails,
      payload: jsonEncode(
        notificacao.dados,
      ));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  inicializarPreferencias();
  //inicializarNotificacoes();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  Hive.registerAdapter(MensagemNotificacaoAdaptadorHive(), override: true);
  //Hive.deleteBoxFromDisk("FundosSeguidos");
  await FundosSeguidos.inicializar();

  //if (await Hive.boxExists("HistoricoNotificacoes"))
  //Hive.deleteBoxFromDisk("HistoricoNotificacoes");
  await HistoricoNotifiacoes.inicializar();

  await Sincronizacao.inicializacao(DateTime.now());

  //var pns = PushNotificationService();
  //await pns.initialize();
  //print(await pns.getToken());
  await FirebaseMessaging.instance.getToken();
  FirebaseMessaging.onBackgroundMessage(processarNotificacoesEmSegundoPlano);
  FirebaseMessaging.onMessage.listen((event) async {
    if (event.data.isNotEmpty) {
      if (event.data.containsKey("tipo") &&
          event.data["tipo"] == DescricaoTipoMensagemNotificacao.documento) {
        final not = MensagemNotificacao(
            titulo: event.notification?.title,
            mensagem: event.notification?.body,
            dataEHora: DateTime.now(),
            dados: event.data);
        await HistoricoNotifiacoes().adicionar(not);
        exibirNotificacao(not);
      }
    }
  });

  //FirebaseMessaging.onMessageOpenedApp.listen((event) {Navigator.of(context)});

  WidgetsBinding.instance.addObserver(Mud());
  runApp(Aplicacao());
  //print((await FundosRepositorio().buscarTodos())?[0].codigo);
  Sincronizacao.sincronizarNotificacoes(DateTime.now().microsecondsSinceEpoch);
}

class Mud with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // TODO: implement didChangeAppLifecycleState
    print("Mud: " + state.toString());
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      await HistoricoNotifiacoes.inicializar();

      Sincronizacao.sincronizarNotificacoes(
          DateTime.now().microsecondsSinceEpoch);
    }
  }
}

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future initialize() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  Future<String?> getToken() async {
    String? token = await _fcm.getToken();
    print('Token: $token');
    return token;
  }
}
