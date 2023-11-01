import 'package:super_fiis_flutter/modelos/tipo_mensagem_notificacao.dart';

class MensagemNotificacao {
  TipoMensagemNotificacao? tipo;
  String? titulo;
  String? mensagem;
  DateTime? dataEHora;
  Map<String, dynamic>? dados;
  bool clicada;

  MensagemNotificacao(
      {this.tipo,
      this.titulo,
      this.mensagem = "",
      this.dataEHora,
      this.dados,
      this.clicada = false});

  /*Map<String, dynamic> toMap() {
    return {
      //'tipo': tipo?.toMap(),
      'titulo': titulo,
      'mensagem': mensagem,
      'dataEHora': dataEHora?.millisecondsSinceEpoch,
      'dados': dados,
      'clicada': clicada,
    };
  }

  factory MensagemNotificacao.fromMap(Map<String, dynamic> map) {
    return MensagemNotificacao(
      //map['tipo'] != null ? TipoMensagemNotificacao.fromMap(map['tipo']) : null,
      titulo: map['titulo'],
      mensagem: map['mensagem'],
      dataEHora: map['dataEHora'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dataEHora'])
          : null,
      dados: Map<String, dynamic>.from(map['dados']),
      clicada: map['clicada'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory MensagemNotificacao.fromJson(String source) =>
      MensagemNotificacao.fromMap(json.decode(source));
}*/
}
