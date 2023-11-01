import 'package:flutter/material.dart';

class Notificador extends ChangeNotifier {
  notificarOuvintes() {
    notifyListeners();
  }
}
