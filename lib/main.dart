import 'package:desafio_tecnico_2/main_widgets/book_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'storage_helper.dart';

final dio = Dio(); //TODO CLOSE CLIENT
List<Book> bookList = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDatabase();

  runApp(
    MaterialApp(
      title: "Desafio escribo 2",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
        textTheme: GoogleFonts.merriweatherTextTheme(),
      ),
      home: const BookLibrary(),
    ),
  );
}

Future getBooksFromApi() async {
  var apiRes = await dio.get("https://escribo.com/books.json");
  for (var item in apiRes.data) {
    var thisBook = Book(
      id: item["id"],
      title: item["title"],
      author: item["author"],
      coverUrl: item["cover_url"],
      downloadUrl: item["download_url"],
      isFavorite: await checkSavedData(item["id"], "bookmarks"),
      isDownloaded: await checkSavedData(item["id"], "downloaded"),
    );

    bookList.add(thisBook);
    await addBook(thisBook);
  }
  return apiRes.data;
}

//Não dá pra colocar o future direto no builder da lista porque senão ele vai
//dar rebuild duas vezes. Não sei direito como funciona, mas é de experiência kk
Future futureForListBuilder = getBooksFromApi();

class BookLibrary extends StatefulWidget {
  const BookLibrary({super.key});

  @override
  State<BookLibrary> createState() => _BookLibraryState();
}

class _BookLibraryState extends State<BookLibrary>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("E-BOOK READER"),
        centerTitle: true,
        backgroundColor: Colors.lightGreen,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50.0, left: 10.0, right: 10.0),
            child: FutureBuilder(
              future: futureForListBuilder,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: tabController,
                    children: [
                      showBooks(),
                      showFavorites(),
                      showAvailableOffline(),
                    ],
                  );
                } else {
                  return const Center(
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(
                        color: Colors.lightGreen,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          Row(
            children: [
              pageNavigator("Livros", 0),
              pageNavigator("Favoritos", 1),
              pageNavigator("Offline", 2)
            ],
          ),
        ],
      ),
    );
  }

  Widget pageNavigator(String text, int innerIndex) {
    return Container(
      margin: const EdgeInsets.all(3.0),
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
          color: tabController.index == innerIndex
              ? Colors.lightGreen[800]
              : Colors.lightGreen,
          borderRadius: BorderRadius.circular(10.0)),
      child: InkWell(
        onTap: () {
          setState(() {
            tabController.animateTo(innerIndex);
          });
        },
        child: Text(text),
      ),
    );
  }
}

showBooks() {
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
}

showFavorites() {
  return const Text("Favorites"); //TODO MAKE THAT
}

showAvailableOffline() {
  return const Text("Offline"); //TODO MAKE THAT
}
