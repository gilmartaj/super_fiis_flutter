import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:super_fiis_flutter/gerenciadores/gerenciador_favoritos.dart';
import 'package:super_fiis_flutter/gerenciadores/gerenciador_fundos_carregados.dart';
import 'package:super_fiis_flutter/modelos/fundo.dart';
import 'package:super_fiis_flutter/provedores/provedor_fundos.dart';
import 'package:super_fiis_flutter/provedores/provedor_fundos_carregados.dart';
import 'package:super_fiis_flutter/provedores/provedor_fundos_seguidos.dart';
import 'package:super_fiis_flutter/repositorios/fundos_repositorio.dart';
import 'package:super_fiis_flutter/utilitarios/suavizador_de_repeticoes.dart';
import 'package:super_fiis_flutter/visao/componentes/barra_superior.dart';
import 'package:super_fiis_flutter/visao/rotas/tela_documentos_fundo.dart';

class TelaTodosFundos extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TelaTodosFundosState();
  }
}

class _TelaTodosFundosState extends State<TelaTodosFundos> {
  final controlador = _TelaTodosFundosControlador();
  FocusNode _focusNode = FocusNode();
  PageStorageKey pageStorageKey = const PageStorageKey("TelaTodosFundos");
  final controladorTextoFiltro = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //controlador.carregarFundos();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final provedor = ProvedorFundosCarregados.controlador(context)!;
      controlador.carregarFundos2(provedor.fundos, provedor.temErro);
      provedor.addListener(() {
        controlador.carregarFundos2(provedor.fundos, provedor.temErro);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    controlador.provedorFundosCarregados =
        ProvedorFundosCarregados.controlador(context)!;
    controlador.provedorFundosSeguidos =
        ProvedorFundosSeguidos.controlador(context)!;

    return SafeArea(
        child: Scaffold(
      body: ListenableBuilder(
        listenable: controlador,
        child: const Center(child: CircularProgressIndicator()),
        builder: (context, child) {
          if (controlador.fundos == null && !controlador.erro) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [CircularProgressIndicator()],
              ),
            );
          }
          if (controlador.erro) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Erro ao carregar fundos"),
                  ElevatedButton(
                      onPressed: () =>
                          ProvedorFundosCarregados.controlador(context)!
                              .carregarFundos(), //controlador.carregarFundos(),
                      child: const Text("Tentar novamente"))
                ],
              ),
            );
          }
          return Column(
            children: [
              Container(
                child: TextField(
                  controller: controladorTextoFiltro,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: controladorTextoFiltro.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                              ),
                              onPressed: () {
                                controladorTextoFiltro.clear();
                                controlador.filtrarFundos("");
                              },
                            )
                          : null,
                      border: OutlineInputBorder(),
                      hintText: "Pesquisar fundo..."),
                  autofocus: false,
                  focusNode: _focusNode,
                  onChanged: (value) => controlador.filtrarFundos(value),
                ),
              ),
              Flexible(
                  child: controlador.fundosFiltrados!.isEmpty
                      ? Center(
                          child: Text("Nenhum fundo encontrado"),
                        )
                      : RefreshIndicator(
                          onRefresh: () =>
                              ProvedorFundosCarregados.controlador(context)!
                                  .carregarFundos(),
                          child: ListView.builder(
                            key: pageStorageKey,
                            itemCount: controlador.fundosFiltrados!.length,
                            itemBuilder: (context, index) => ListTile(
                              title: Text(
                                  controlador.fundosFiltrados![index].codigo!),
                              subtitle: Text(
                                  controlador.fundosFiltrados![index].cnpj ??
                                      ""),
                              leading: GestureDetector(
                                  child: Container(
                                    color: Colors.transparent,
                                    width: 50,
                                    height: 50,
                                    child: controlador.fundosSeguidos.contains(
                                            controlador.fundosFiltrados![index])
                                        ? Icon(Icons.notifications_active,
                                            color: Color.fromARGB(
                                                220, 226, 180, 0))
                                        : Icon(Icons
                                            .notifications_active_outlined),
                                  ),
                                  onTap: () => controlador.alternarFavorito(
                                      controlador.fundosFiltrados![index])),
                              trailing: Icon(Icons.navigate_next_outlined),
                              onTap: () {
                                _focusNode.unfocus();
                                _abrirTelaDocumentosFundo(
                                    controlador.fundosFiltrados![index]);
                              },
                            ),
                          ),
                        ))
            ],
          );
        },
      ),
    ));
  }

  _abrirTelaDocumentosFundo(Fundo fundo) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => TelaDocumentosFundo(fundo: fundo),
    ));
  }
}

class _TelaTodosFundosControlador extends ChangeNotifier {
  final repositorio = FundosRepositorio();
  bool erro = false;
  List<Fundo>? fundos;
  List<Fundo>? fundosFiltrados;
  List<Fundo> favoritos = [];
  late ControladorProvedorFundosCarregados provedorFundosCarregados;
  late ControladorProvedorFundosSeguidos provedorFundosSeguidos;
  Map<String, SuavizadorDeRepeticoes> suavizadores = {};

  //_TelaTodosFundosControlador();

  List<Fundo> get fundosSeguidos {
    return provedorFundosSeguidos.fundos;
  }

  carregarFundos() async {
    erro = false;
    notifyListeners();
    //await Future.delayed(Duration(seconds: 3));
    fundos = fundosFiltrados = await repositorio.buscarTodos();
    if (fundos == null) {
      erro = true;
    }
    notifyListeners();
  }

  carregarFundos2(List<Fundo>? fundos, bool erro) async {
    this.erro = erro;
    //notifyListeners();
    //await Future.delayed(Duration(seconds: 3));
    this.fundos = fundosFiltrados = fundos;
    //if (this.fundos == null) {
    //  erro = true;
    //}
    notifyListeners();
  }

  filtrarFundos(String filtro) {
    fundosFiltrados = fundos!
        .where((fundo) => fundo.codigo!.contains(filtro.toUpperCase()))
        .toList();
    notifyListeners();
  }

  alternarFavorito(Fundo fundo) async {
    if (favoritos.contains(fundo)) {
      favoritos.remove(fundo);
      provedorFundosSeguidos.desinscrever(fundo.codigo!);
      if (!suavizadores.containsKey(fundo.codigo)) {
        suavizadores[fundo.codigo!] =
            SuavizadorDeRepeticoes(const Duration(milliseconds: 500));
      }
      suavizadores[fundo.codigo!]!.executar(() {
        FirebaseMessaging.instance.unsubscribeFromTopic(fundo.codigo!);
      });
    } else {
      favoritos.add(fundo);
      provedorFundosSeguidos.seguir(fundo.codigo!);
      if (!suavizadores.containsKey(fundo.codigo)) {
        suavizadores[fundo.codigo!] =
            SuavizadorDeRepeticoes(const Duration(milliseconds: 500));
      }
      suavizadores[fundo.codigo!]!.executar(() {
        FirebaseMessaging.instance.subscribeToTopic(fundo.codigo!);
      });
    }
    //notifyListeners();
  }
}
