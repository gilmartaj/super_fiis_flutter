import 'package:flutter/material.dart';

class BarraSuperior {
  BarraSuperior._();

  static AppBar construir({String? titulo, List<Widget>? botoesDireita}) {
    return AppBar(
      title: Text(titulo ?? "Super FIIs"),
      actions: botoesDireita
              ?.map<Widget>((e) => Container(
                    margin: EdgeInsets.only(right: 20),
                    child: e,
                  ))
              .toList() ??
          [],
    );
  }
}
