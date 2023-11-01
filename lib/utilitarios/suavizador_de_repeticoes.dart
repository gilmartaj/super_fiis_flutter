import 'dart:async';

class SuavizadorDeRepeticoes {
  Timer? temporizador;
  Duration tempoEspera;

  SuavizadorDeRepeticoes(this.tempoEspera);

  executar(Function() funcao) {
    if (temporizador != null) temporizador!.cancel();
    temporizador = Timer(tempoEspera, () => funcao());
  }
}
