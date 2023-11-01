import 'package:hive/hive.dart';
import 'package:super_fiis_flutter/modelos/mensagem_notificacao.dart';
import 'package:super_fiis_flutter/modelos/tipo_mensagem_notificacao.dart';

class MensagemNotificacaoAdaptadorHive
    extends TypeAdapter<MensagemNotificacao> {
  @override
  MensagemNotificacao read(BinaryReader leitor) {
    // TODO: implement read
    MensagemNotificacao notificacao = MensagemNotificacao();
    int identificadorTipo = leitor.readInt();
    if (identificadorTipo > -100) {
      try {
        notificacao.tipo =
            TipoMensagemNotificacao.aPartirDoIdentificador(identificadorTipo);
      } on ExcecaoTipoMensagemNotificacaoDesconhecido {
        //Se for um erro de deste tipo, simplesmente é ignorado
      }
    }
    notificacao.titulo = leitor.readString();
    notificacao.mensagem = leitor.readString();
    int dataEHoraMicrossegundos = leitor.readInt();
    if (dataEHoraMicrossegundos > -100)
      notificacao.dataEHora =
          DateTime.fromMicrosecondsSinceEpoch(dataEHoraMicrossegundos);
    notificacao.dados = leitor.readMap().cast<String, dynamic>();
    notificacao.clicada = leitor.readBool();
    return notificacao;
  }

  @override
  // TODO: implement typeId
  int get typeId => 33;

  @override
  void write(BinaryWriter escritor, MensagemNotificacao notificacao) {
    // TODO: implement write
    escritor.writeInt(notificacao.tipo?.identificador ?? -100);
    escritor.writeString(notificacao.titulo ?? "");
    escritor.writeString(notificacao.mensagem ?? "");
    escritor.writeInt(notificacao.dataEHora?.microsecondsSinceEpoch ?? -100);
    escritor.writeMap(notificacao.dados ?? <String, dynamic>{});
    escritor.writeBool(notificacao.clicada);
  }
}
