import 'package:desafio_tecnico_2/storage_helper.dart';
import 'package:flutter/material.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';
import 'main.dart';

//Alert dialog pedindo autorização para baixar lviro no dispositivo.
Future askToDownload(BuildContext context, String url, int id, index) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Baixar livro"),
          content: const SingleChildScrollView(
            child: Text("Antes que possa ler o livro, é necessário baixá-lo"),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancelar")),

            TextButton(
                onPressed: () async {
                  await bookToDevice(url, id).then((value) {
                    bookList[index].isDownloaded = true;
                  });

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    openReader(context, id);
                  }
                },
                child: const Text("Baixar")),
          ],
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

  VocsyEpub.open(path);
}
