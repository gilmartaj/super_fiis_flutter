import 'dart:convert';

import 'package:super_fiis_flutter/modelos/dados_baixar_arquivo.dart';
import 'package:super_fiis_flutter/modelos/documento.dart';
import 'package:super_fiis_flutter/modelos/fundo.dart';
import 'package:http/http.dart' as http;

class DocumentosRepositorio {
  static const String enderecoBase = "http://192.168.1.5:8080";

  Future<List<Documento>?> buscarPorFundo(Fundo fundo,
      {int pagina = 0, int tamanhoPagina = 10}) async {
    try {
      return (jsonDecode((await http.get(Uri.parse(
                  "$enderecoBase/documentos/${fundo.cnpj}?pagina=$pagina&tamanhoPagina=$tamanhoPagina")))
              .body) as List)
          .cast<Map<String, dynamic>>()
          .map((e) => Documento.fromMap(e))
          .toList();
    } catch (e) {
      return null;
    }
  }

  Future<DadosBaixarArquivo?> buscarDadosDescarga(Documento documento) async {
    try {
      return DadosBaixarArquivo.fromMap(jsonDecode((await http.get(Uri.parse(
              "$enderecoBase/documentos/enderecoDescargaPDF/${documento.identificador}")))
          .body));
    } catch (e) {
      return null;
    }
  }
}
