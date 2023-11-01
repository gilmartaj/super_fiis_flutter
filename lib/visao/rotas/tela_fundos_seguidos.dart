import 'package:flutter/material.dart';
import 'package:super_fiis_flutter/modelos/fundo.dart';
import 'package:super_fiis_flutter/provedores/provedor_fundos.dart';
import 'package:super_fiis_flutter/provedores/provedor_fundos_seguidos.dart';
import 'package:super_fiis_flutter/visao/rotas/tela_documentos_fundo.dart';

class TelaFundosSeguidos extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TelaFundosSeguidosState();
  }
}

class _TelaFundosSeguidosState extends State<TelaFundosSeguidos> {
  final controlador = ControladorTelaFundosSeguidos();
  PageStorageKey pageStorageKey = const PageStorageKey("TelaFundosSeguidos");

  @override
  Widget build(BuildContext context) {
    controlador.provedor = ProvedorFundosSeguidos.controlador(context)!;
    // TODO: implement build
    return Column(
      children: [
        Flexible(
            child: ProvedorFundosSeguidos.controlador(context)!.fundos.isEmpty
                ? Center(
                    child: Text("Nenhum fundo seguido"),
                  )
                : ListView.builder(
                    key: pageStorageKey,
                    itemCount: controlador.fundosFiltrados!.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(controlador.fundosFiltrados![index].codigo!),
                      subtitle:
                          Text(controlador.fundosFiltrados![index].cnpj ?? ""),
                      leading: GestureDetector(
                          child: Icon(Icons.notifications_active,
                              color: Color.fromARGB(220, 226, 180, 0)),
                          onTap: () => controlador.desinscrever(
                              controlador.fundosFiltrados![index])),
                      trailing: Icon(Icons.navigate_next_outlined),
                      onTap: () {
                        //_focusNode.unfocus();
                        _abrirTelaDocumentosFundo(
                            controlador.fundosFiltrados![index]);
                      },
                    ),
                  ))
      ],
    );
  }

  _abrirTelaDocumentosFundo(Fundo fundo) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => TelaDocumentosFundo(fundo: fundo),
    ));
  }
}

class ControladorTelaFundosSeguidos {
  late ControladorProvedorFundosSeguidos provedor;

  get fundosFiltrados => provedor.fundos;

  desinscrever(Fundo fundo) async {
    provedor.desinscrever(fundo.codigo!);
  }

  //List<Fundo>? get fundosSeguidos() =>
}
