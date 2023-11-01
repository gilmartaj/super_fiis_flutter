import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:super_fiis_flutter/provedores/provedor_tema.dart';
import 'package:super_fiis_flutter/utilitarios/suavizador_de_repeticoes.dart';
import 'package:super_fiis_flutter/visao/componentes/barra_superior.dart';

class TelaAjustes extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TelaAjustesState();
  }
}

class _TelaAjustesState extends State<TelaAjustes> {
  final suavizadorDeRepeticoes =
      SuavizadorDeRepeticoes(const Duration(milliseconds: 500));

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
        child: Scaffold(
      appBar: BarraSuperior.construir(titulo: "Ajustes"),
      body: Container(
          child: Column(
        children: [
          ExpansionTile(
            initiallyExpanded: true,
            textColor: ProvedorTema.controlador(context)!.temaEscuroAtivado
                ? Colors.white
                : Colors.black,
            title: Row(
              children: [
                Text(
                  "Notificações",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                /*Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  child: Switch(
                    value: true,
                    onChanged: (v) {},
                  ),
                )*/
              ],
            ),
            children: [
              SwitchListTile(
                  activeColor: Color.fromARGB(250, 50, 170, 240),
                  title: Text("Fatos relevantes"),
                  value: true,
                  onChanged: (v) {}),
              SwitchListTile(
                  activeColor: Color.fromARGB(250, 50, 170, 240),
                  title: Text("Relatórios gerenciais"),
                  value: true,
                  onChanged: (v) {}),
              SwitchListTile(
                  activeColor: Color.fromARGB(250, 50, 170, 240),
                  title: Text("Anúncios de rendimentos"),
                  value: true,
                  onChanged: (v) {}),
              SwitchListTile(
                  activeColor: Color.fromARGB(250, 50, 170, 240),
                  title: Text("Outras"),
                  value: true,
                  onChanged: (v) {})
            ],
          ),
          Divider(
            thickness: 1,
            color: Colors.black,
            height: 1,
          ),
          ListTile(
            title: Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Text("Limpar cache",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            subtitle: Text(
                "Elimina os arquivos armazenados na memória interna da aplicação.\nDocumentos salvos pelo usuário não são afetados."),
            onTap: () => suavizadorDeRepeticoes.executar(() async {
              try {
                final dir = await getApplicationCacheDirectory();
                await dir.delete(recursive: true);
                /*ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
                    content: Text("O cache do SuperFIIs está limpo"),
                    actions: [Icon(Icons.foggy)]));*/
                /*for (var f in dir.listSync()) {
                  await f.delete(recursive: true);
                }*/
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:
                      Center(child: Text("O cache do SuperFIIs está limpo")),
                  duration: Duration(seconds: 1),
                ));
                //await Future.delayed(Duration(seconds: 1));
                //ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              } catch (e) {}
            }),
            minVerticalPadding: 15,
          ),
          Divider(
            thickness: 1,
            color: Colors.black,
            height: 1,
          ),
        ],
      )),
    ));
  }
}
