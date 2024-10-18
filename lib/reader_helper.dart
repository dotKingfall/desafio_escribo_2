import 'package:desafio_tecnico_2/storage_helper.dart';
import 'package:flutter/material.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';

//Alert dialog pedindo autorização para baixar lviro no dispositivo.
Future notifyDownload(BuildContext context, String url, int id, index) async{
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return const Dialog(
          child: SizedBox(
            height: 100,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("Seu livro está baixando! :)"),
                  SizedBox(
                    height: 10,
                    width: 100,
                    child: LinearProgressIndicator(),
                  ),
                ],
              ),
            ),
          ),
        );
      });
}

//Abrir leitor de epub
openReader(BuildContext context, int id) async{
  String path = await getBookPath(id);

  VocsyEpub.setConfig(
    themeColor: Colors.lightGreen,
    identifier: id.toString(),
    scrollDirection: EpubScrollDirection.VERTICAL,
    enableTts: true,
    nightMode: false,
  );

  VocsyEpub.locatorStream.listen((locator) {
    debugPrint('LOCATOR: $locator');
  });

  //VocsyEpub.open(path);
  VocsyEpub.open(path);
}
