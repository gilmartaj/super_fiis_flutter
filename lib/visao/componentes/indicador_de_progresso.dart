import 'package:flutter/material.dart';

class IndicadorDeProgresso extends StatefulWidget {
  final double? progresso;

  const IndicadorDeProgresso({super.key, this.progresso});
  //const IndicadorDeProgresso.indeterminado({super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _IndicadorDeProgressoState();
  }
}

class _IndicadorDeProgressoState extends State<IndicadorDeProgresso> {
  static const double tamanho = 100;
  static const double tamanhoFonte = 30;
  static const double tamanhoBorda = 10;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (widget.progresso != null) {
      return Stack(children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Padding(
                  padding: EdgeInsets.only(bottom: 50),
                  child: Text(
                      "${(widget.progresso! * 100).toStringAsFixed(0)}%",
                      style: const TextStyle(fontSize: tamanhoFonte))),
            )
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: SizedBox(
                width: tamanho,
                height: tamanho,
                child: CircularProgressIndicator(
                  value: widget.progresso,
                  strokeWidth: tamanhoBorda,
                ),
              ),
            ),
            SizedBox(
              height: 60,
              child: Center(
                  child: Text(
                "Carregando",
                style: TextStyle(fontSize: 20),
              )),
            )
          ],
        ),
      ]);
    }
    return Stack(children: [
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: SizedBox(
              width: tamanho,
              height: tamanho,
              child: CircularProgressIndicator(strokeWidth: tamanhoBorda),
            ),
          ),
          SizedBox(
            height: 60,
            child: Center(
                child: Text(
              "Carregando",
              style: TextStyle(fontSize: 20),
            )),
          )
        ],
      )
    ]);
  }
}
