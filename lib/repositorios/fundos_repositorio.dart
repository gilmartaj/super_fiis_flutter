import 'dart:convert';

import 'package:super_fiis_flutter/modelos/fundo.dart';
import 'package:http/http.dart' as http;

class FundosRepositorio {
  static const String enderecoBase = "http://192.168.1.5:8080";

  Future<List<Fundo>?> buscarTodos() async {
    try {
      return (jsonDecode(
              (await http.get(Uri.parse("$enderecoBase/fundos/todos")))
                  .body) as List)
          .cast<Map<String, dynamic>>()
          .map((e) => Fundo.fromMap(e))
          .toList();
    } catch (e) {
      return null;
    }
  }
}
