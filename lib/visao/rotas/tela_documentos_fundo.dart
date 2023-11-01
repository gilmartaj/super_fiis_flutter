import 'package:flutter/material.dart';
import 'package:super_fiis_flutter/modelos/documento.dart';
import 'package:super_fiis_flutter/modelos/fundo.dart';
import 'package:super_fiis_flutter/repositorios/documentos_repositorio.dart';
import 'package:super_fiis_flutter/visao/componentes/indicador_de_progresso.dart';
import 'package:super_fiis_flutter/visao/rotas/tela_exibir_documento_pdf.dart';

import '../componentes/barra_superior.dart';

class TelaDocumentosFundo extends StatefulWidget {
  Fundo fundo;

  TelaDocumentosFundo({required this.fundo, super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TelaDocumentosFundoState();
  }
}

class _TelaDocumentosFundoState extends State<TelaDocumentosFundo> {
  final controlador = _TelaDocumentosFundoControlador();
  final controladorRolagem = ScrollController();
  final chavePosicaoPagina = const PageStorageKey("PaginaFundos");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    controladorRolagem.addListener(() {
      if (controladorRolagem.position.pixels >=
          controladorRolagem.position.maxScrollExtent)
        controlador.carregarNovaPagina(widget.fundo);
      print("Final da página");
    });

    controlador.carregarDocumentos(widget.fundo);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
        child: Scaffold(
      appBar: BarraSuperior.construir(
          titulo: "${widget.fundo.codigo} - Documentos"),
      body: ListenableBuilder(
        listenable: controlador,
        child: const Center(child: IndicadorDeProgresso()),
        builder: (context, child) {
          if (controlador.documentos == null && !controlador.erro) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [IndicadorDeProgresso()],
              ),
            );
          }
          if (controlador.erro) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Erro ao carregar documentos"),
                  ElevatedButton(
                      onPressed: () =>
                          controlador.carregarDocumentos(widget.fundo),
                      child: const Text("Tentar novamente"))
                ],
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  key: chavePosicaoPagina,
                  controller: controladorRolagem,
                  itemCount: controlador.documentos!.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(controlador.documentos![index].titulo!),
                    subtitle: Text(controlador.documentos![index].data ?? ""),
                    //leading: const Icon(Icons.star, color: Colors.amber),
                    trailing: const Icon(Icons.navigate_next_outlined),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => TelaExibirDocumentoPdf(
                            documento: controlador.documentos![index]),
                      ));
                    },
                  ),
                ),
              ),
              if (controlador.estaCarregandoNovaPagina)
                const CircularProgressIndicator()
            ],
          );
        },
      ),
    ));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controladorRolagem.dispose();
  }
}

class _TelaDocumentosFundoControlador extends ChangeNotifier {
  final repositorio = DocumentosRepositorio();
  bool erro = false;
  List<Documento>? documentos;
  int _pagina = 0;
  bool _carregandoNovaPagina = false;

  get estaCarregandoNovaPagina => _carregandoNovaPagina;

  carregarDocumentos(Fundo fundo) async {
    erro = false;
    notifyListeners();
    documentos = await repositorio.buscarPorFundo(fundo, tamanhoPagina: 20);
    if (documentos == null) {
      erro = true;
    }
    notifyListeners();
  }

  carregarNovaPagina(Fundo fundo) async {
    //erro = false;
    if (_pagina < 0) return;
    _carregandoNovaPagina = true;
    notifyListeners();
    final novosDocumentos = await repositorio.buscarPorFundo(fundo,
        pagina: _pagina + 1, tamanhoPagina: 20);
    if (novosDocumentos != null) {
      if (novosDocumentos.isNotEmpty) {
        documentos!.addAll(novosDocumentos);
        _pagina++;
      } else {
        _pagina = -10;
      }
    }
    _carregandoNovaPagina = false;
    notifyListeners();
  }
}
