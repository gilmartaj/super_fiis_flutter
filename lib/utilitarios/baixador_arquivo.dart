import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:super_fiis_flutter/modelos/dados_baixar_arquivo.dart';

class BaixadorArquivo {
  Future<File> baixarArquivo(DadosBaixarArquivo dados, String diretorio,
      {bool substituir = true,
      Function(int, int?)? funcaoAlteracaoEstado}) async {
    //Completer<File> completer = Completer();
    File file = File("${diretorio}/${dados.nome}");
    if (!file.existsSync() || substituir) {
      print("Start download file from internet!");
      //const url =
      //   'https://fnet.bmfbovespa.com.br/fnet/publico/downloadDocumento?id=512943';
      //const filename = "arquivo.pdf";
      print(dados.endereco);
      var request = await HttpClient().getUrl(Uri.parse(dados.endereco))
        ..headers.set('Accept',
            'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8');
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response,
          onBytesReceived: funcaoAlteracaoEstado);
      //var dir = ;
      print("Download files");
      //print("${dir.path}/$filename");

      await file.writeAsBytes(bytes, flush: true);
    }
    print(file.path);
    //completer.complete(file);
    return file;
  }
}
