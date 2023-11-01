enum TipoMensagemNotificacao {
  documento(1, "documento"),
  provento(2, "provento"),
  informacao(3, "informacao"),
  noticacaoAplicacao(0, "notificacaoAplicacao");

  final int identificador;
  final String descricao;

  const TipoMensagemNotificacao(this.identificador, this.descricao);

  factory TipoMensagemNotificacao.aPartirDoIdentificador(int i) {
    switch (i) {
      case 1:
        return TipoMensagemNotificacao.documento;
      case 2:
        return TipoMensagemNotificacao.provento;
      case 3:
        return TipoMensagemNotificacao.informacao;
      case 4:
        return TipoMensagemNotificacao.noticacaoAplicacao;
      default:
        throw ExcecaoTipoMensagemNotificacaoDesconhecido(i);
    }
  }
}

class ExcecaoTipoMensagemNotificacaoDesconhecido implements Exception {
  final int identificadorDesconhecido;
  ExcecaoTipoMensagemNotificacaoDesconhecido(this.identificadorDesconhecido);
}

class DescricaoTipoMensagemNotificacao {
  static const String documento = "documento";
}
