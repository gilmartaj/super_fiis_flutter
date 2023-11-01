import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:lecle_downloads_path_provider/constants/downloads_directory_type.dart';
import 'package:lecle_downloads_path_provider/lecle_downloads_path_provider.dart';
import 'package:path_provider/path_provider.dart';

import 'package:super_fiis_flutter/modelos/dados_baixar_arquivo.dart';
import 'package:super_fiis_flutter/modelos/documento.dart';
import 'package:super_fiis_flutter/repositorios/documentos_repositorio.dart';
import 'package:super_fiis_flutter/utilitarios/baixador_arquivo.dart';
import 'package:super_fiis_flutter/utilitarios/suavizador_de_repeticoes.dart';
import 'package:super_fiis_flutter/visao/componentes/barra_superior.dart';
import 'package:super_fiis_flutter/visao/componentes/indicador_de_progresso.dart';
import 'package:permission_handler/permission_handler.dart';

class TelaExibirDocumentoPdf extends StatefulWidget {
  final Documento documento;
  const TelaExibirDocumentoPdf({
    Key? key,
    required this.documento,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TelaExibirDocumentoPdfState();
  }
}

class _TelaExibirDocumentoPdfState extends State<TelaExibirDocumentoPdf> {
  final controlador = _TelaExibirDocumentoPdfControlador();

  final suavizadorDeRepeticoes =
      SuavizadorDeRepeticoes(const Duration(milliseconds: 500));

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controlador.carregarArquivo(widget.documento);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
        child: Scaffold(
      appBar: BarraSuperior.construir(
          titulo: widget.documento.titulo,
          botoesDireita: [
            ListenableBuilder(
                listenable: controlador,
                builder: (context, child) {
                  if (controlador.arquivo != null) {
                    return IconButton(
                      icon: const Icon(Icons.file_download),
                      onPressed: controlador.baixando
                          ? () {}
                          : () {
                              suavizadorDeRepeticoes.executar(() {
                                if (controlador.baixando) return;

                                _exibirMensagemFlutuante(
                                    'Salvando arquivo em downloads...');
                                controlador.salvarEmDownloads(
                                    "${widget.documento.titulo}",
                                    "pdf",
                                    (caminhoArquivo) => _exibirMensagemFlutuante(
                                        "${caminhoArquivo.split('/').last} salvo em Downloads"),
                                    () => _exibirMensagemFlutuante(
                                        'Erro ao salvar o arquivo ${widget.documento.titulo}.pdf em Downloads'));
                              });
                            },
                    );
                  }
                  return Container();
                })
          ]),
      body: ListenableBuilder(
        listenable: controlador,
        child: const Center(child: CircularProgressIndicator()),
        builder: (context, child) {
          if (controlador.arquivo == null && !controlador.erro) {
            return IndicadorDeProgresso(
                progresso: controlador.percentualBaixado);
          }
          if (controlador.erro) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Erro ao carregar documento"),
                  ElevatedButton(
                      onPressed: () =>
                          controlador.carregarArquivo(widget.documento),
                      child: const Text("Tentar novamente"))
                ],
              ),
            );
          }
          return PDFView(
            filePath: controlador.arquivo!.path,
            enableSwipe: true,
            swipeHorizontal: false,
            pageFling: false,
            autoSpacing: false,
            pageSnap: false,
            //fitPolicy: FitPolicy.BOTH,
            onError: (error) => controlador.notificarErro(),
          );
        },
      ),
    ));
  }

  _exibirMensagemFlutuante(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.black87,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            texto,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    ));
  }
}

class _TelaExibirDocumentoPdfControlador extends ChangeNotifier {
  final repositorio = DocumentosRepositorio();
  bool erro = false;
  File? arquivo;
  double? percentualBaixado;
  bool _baixando = false;

  get baixando => _baixando;

  _atualizarSituacaoDescarga(int baixados, int? total) {
    if (total != null) {
      percentualBaixado = baixados / total;
      //print(percentualBaixado = baixados / total);
      //print("$baixados -> $total");
      notifyListeners();
    }
  }

  notificarErro() {
    percentualBaixado = null;
    erro = true;
    notifyListeners();
  }

  Future<DadosBaixarArquivo?> _carregarDadosDescarga(
      Documento documento) async {
    if (documento.extensao == "pdf") {
      return DadosBaixarArquivo(
          endereco:
              "https://fnet.bmfbovespa.com.br/fnet/publico/downloadDocumento?id=${documento.identificador}",
          cabecalhos: {
            "Accept":
                "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8"
          },
          nome: "${documento.identificador}.${documento.extensao}");
    }
    return (await repositorio.buscarDadosDescarga(documento))!;
  }

  carregarArquivo(Documento documento) async {
    try {
      final diretorio = (await getApplicationCacheDirectory()).path;
      File arquivo = File("${diretorio}/${documento.identificador}.pdf");
      if (erro) {
        erro = false;
        notifyListeners();
        if (await arquivo.exists()) {
          await arquivo.delete();
        }
      } else {
        erro = false;
        notifyListeners();
      }
      if (arquivo.existsSync()) {
        this.arquivo = arquivo;
      } else {
        final dadosArquivo = (await _carregarDadosDescarga(documento))!;
        //..nome = "${documento.identificador}.${documento.extensao}";
        this.arquivo = await BaixadorArquivo().baixarArquivo(
            dadosArquivo,
            // DadosBaixarArquivo(
            //     endereco:
            //         "https://fnet.bmfbovespa.com.br/fnet/publico/downloadDocumento?id=${documento.identificador}",

            //     cabecalhos: {
            //       "Accept":
            //           "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8"
            //     },
            //     nome: "${documento.identificador}.pdf"),
            (await getApplicationCacheDirectory()).path,
            substituir: false,
            funcaoAlteracaoEstado: _atualizarSituacaoDescarga);
      }
      notifyListeners();
    } catch (e) {
      erro = true;
      notifyListeners();
      rethrow;
    }
  }

  Future<String> gerarCaminhoDocumento(
      String nomeOriginal, String extensao, String diretorio) async {
    File arquivoDestino = File("$diretorio/$nomeOriginal.$extensao");
    int numero = 0;
    while (await arquivoDestino.exists()) {
      arquivoDestino = File("$diretorio/$nomeOriginal(${++numero}).$extensao");
    }
    return arquivoDestino.path;
  }

  salvarEmDownloads(String nome, String extensao, Function(String) sucesso,
      Function() erro) async {
    if (_baixando) return;
    _baixando = true;
    try {
      Map<Permission, PermissionStatus> permissoes = await [
        Permission.storage,
        Permission.manageExternalStorage,
      ].request();

      if ((permissoes[Permission.storage]?.isGranted ?? false) ||
          (permissoes[Permission.manageExternalStorage]?.isGranted ?? false)) {
        //await Permission.manageExternalStorage.request();
        //var permissao = await Permission.manageExternalStorage.status;
        //var permissao = await Permission.storage.status;
        final caminhoDownloads =
            (await DownloadsPath.downloadsDirectory())?.path;
        if (caminhoDownloads != null) {
          String caminhoArquivo = await gerarCaminhoDocumento(
              nome.replaceAll("/", "-"), extensao, caminhoDownloads);
          await arquivo!.copy(caminhoArquivo);
          sucesso(caminhoArquivo);
          _baixando = false;
          return;
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    erro();
    _baixando = false;
  }
}
