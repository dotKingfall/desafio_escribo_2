import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:desafio_tecnico_2/reader_helper.dart';
import 'package:desafio_tecnico_2/main.dart';
import '../storage_helper.dart';

class BookCard extends StatefulWidget {
  const BookCard(
      {super.key,
      required this.icId,
      required this.icIndex,
      required this.icTitle,
      required this.icAuthor,
      required this.icCoverUrl,
      required this.icDownloadUrl,
      required this.icIsFavorite,
      required this.icIsDownloaded,
      required this.icInnerContext});

  //ic precede essas aqui porque todas as variáveis de stful widget precisam ser
  // finais, é só um indicador de "(I)mmutable from (C)lass". Eles só servem
  // para atribuir valor às variáveis que estão no widget.
  final int icId;
  final int icIndex;
  final String icTitle;
  final String icAuthor;
  final String icCoverUrl;
  final String icDownloadUrl;
  final bool icIsFavorite;
  final bool icIsDownloaded;
  final BuildContext icInnerContext;

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  late List<Book> importantList;
  late int id;
  late int index;
  late String title;
  late String author;
  late String coverUrl;
  late String downloadUrl;
  late bool isFavorite;
  late bool isDownloaded;
  late BuildContext innerContext;

  @override
  void initState() {
    id = widget.icId;
    index = widget.icIndex;
    title = widget.icTitle;
    author = widget.icAuthor;
    coverUrl = widget.icCoverUrl;
    downloadUrl = widget.icDownloadUrl;
    isFavorite = widget.icIsFavorite;
    isDownloaded = widget.icIsDownloaded;
    innerContext = widget.icInnerContext;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        Card(
          child: InkWell(
            onTap: () async {
              if (!bookList[index].isDownloaded) {
                notifyDownload(context, downloadUrl, id, index);
                await bookToDevice(downloadUrl, id, index).then((value) {
                  bookList[index].isDownloaded = true;
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    openReader(context, id);
                  }
                });

              } else {
                openReader(context, id);
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 2.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: CachedNetworkImage(
                      imageUrl: coverUrl,
                      imageBuilder: (context, imageProvider) => Container(
                        height: 150,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5.0),
                          height: 25,
                          width: 25,
                          child: CircularProgressIndicator(
                            color: beautifulGreen,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.highlight_remove,
                        color: beautifulGreen,
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    infoText(title),
                    infoText(author),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: -2,
          child: IconButton(
            onPressed: () async {
              var tmp = bookList[index];
              await addData(id, "bookmarks", tmp.isFavorite);
              setState(() {
                tmp.isFavorite = !tmp.isFavorite;
              });
            },
            padding: EdgeInsets.zero,
            icon: Icon(
              Icons.bookmark,
              color: bookList[index].isFavorite ? Colors.redAccent : null,
              size: 29,
            ),
          ),
        ),
      ],
    );
  }
}

//Texto que mostra informações sobre o livro
Widget infoText(String info) {
  return Text(
    info,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    textAlign: TextAlign.center,
  );
}
