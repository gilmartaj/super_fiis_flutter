import 'dart:convert';

class DadosBaixarArquivo {
  String endereco;
  Map<String, String> cabecalhos;
  String nome;
  DadosBaixarArquivo(
      {required this.endereco, required this.cabecalhos, required this.nome});

  Map<String, dynamic> toMap() {
    return {
      'endereco': endereco,
      'cabecalhos': cabecalhos,
      'nome': nome,
    };
  }

  factory DadosBaixarArquivo.fromMap(Map<String, dynamic> map) {
    return DadosBaixarArquivo(
      endereco: map['endereco'] ?? '',
      cabecalhos: Map<String, String>.from(map['cabecalhos']),
      nome: map['nome'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory DadosBaixarArquivo.fromJson(String source) =>
      DadosBaixarArquivo.fromMap(json.decode(source));
}
