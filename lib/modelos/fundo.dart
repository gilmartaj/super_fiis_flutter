class Fundo {
  String? codigo;
  String? cnpj;
  String? tipo;

  Fundo({this.codigo, this.cnpj, this.tipo});

  factory Fundo.fromMap(Map<String, dynamic> map) =>
      Fundo(codigo: map["codigo"], cnpj: map["cnpj"], tipo: map["tipo"]);
}
