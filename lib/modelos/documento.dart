import 'package:super_fiis_flutter/modelos/fundo.dart';

class Documento {
  String? identificador;
  Fundo? fundo;
  String? titulo;
  String? extensao;
  String? data;

  Documento(
      {this.identificador, this.fundo, this.titulo, this.extensao, this.data});

  factory Documento.fromMap(Map<String, dynamic> map) => Documento(
      identificador: map["identificador"].toString(),
      titulo: map["titulo"],
      extensao: map["extensao"],
      data: map["data"]);
}
