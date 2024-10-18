import 'package:flutter/material.dart';
import '../main.dart';
import '../main_widgets/book_card.dart';

showBooks() {
  return FutureBuilder(
    future: futureForListBuilder,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return Container(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 150.0,
              childAspectRatio: 1 / 2.25,
            ),
            shrinkWrap: true,
            itemCount: bookList.length,
            itemBuilder: (context, index) {
              var tmp = bookList[index];
              return BookCard(
                  icId: tmp.id,
                  icIndex: index,
                  icTitle: tmp.title,
                  icAuthor: tmp.author,
                  icCoverUrl: tmp.coverUrl,
                  icDownloadUrl: tmp.downloadUrl,
                  icIsFavorite: tmp.isFavorite,
                  icIsDownloaded: tmp.isDownloaded,
                  icInnerContext: context);
            },
          ),
        );
      } else if (snapshot.hasError) {
        return Center(
          child: Text("${snapshot.error}"),
        );
      } else {
        return Center(
          child: SizedBox(
            height: 50,
            width: 50,
            child: CircularProgressIndicator(
              color: beautifulGreen,
            ),
          ),
        );
      }
    },
  );
}
