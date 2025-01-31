import 'package:flutter/material.dart';
import 'package:desafio_tecnico_2/main.dart';
import '../main_widgets/book_card.dart';
import '../storage_helper.dart';
import 'livros.dart';

List<Book> favoriteBooks = [];

showFav() {
  for(Book book in bookList){
    if(book.isFavorite && !favoriteBooks.contains(book)){favoriteBooks.add(book);}
  }
  favoriteBooks.removeWhere((book) => !book.isFavorite);

  if(bookList.isNotEmpty && favoriteBooks.isNotEmpty){
    return FutureBuilder(
      future: futureForGridBuilder,
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
              itemCount: favoriteBooks.length,
              itemBuilder: (context, index) {
                var tmp = favoriteBooks[index];
                return BookCard(
                    icId: tmp.id,
                    icIndex: bookList.indexOf(tmp),
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
        }
        else if (snapshot.hasError) {
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
  else if(bookList.isNotEmpty && favoriteBooks.isEmpty){
    return const Center(child: Text("Nenhum favorito adicionado!"),);
  }
  else{
    return const Center(child: Text("Carregando..."),);
  }
}
