import 'package:cached_network_image/cached_network_image.dart';
import 'package:desafio_tecnico_2/reader_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';
import 'database_helper.dart';

final dio = Dio();
List<Book> bookList = [];
List downloaded = []; //TODO TAKE DOWNLOADED BOOKS DATA FROM DATABASE

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

checkFavorite(int id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> bookmarks = prefs.getStringList("bookmarks") ?? [];

  for (var favItem in bookmarks) {
    if (favItem == id.toString()) {
      return true;
    }
  }

  return false;
}

checkDownloaded(int id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> downloaded = prefs.getStringList("downloaded") ?? [];

  for (var downloadedBook in downloaded) {
    if (downloadedBook == id.toString()) {
      return true;
    }
  }

  return false;
}

Future getBooksFromApi() async {
  var apiRes = await dio.get("https://escribo.com/books.json");
  for (var item in apiRes.data) {
    bookList.add(
      Book(
        id: item["id"],
        title: item["title"],
        author: item["author"],
        coverUrl: item["cover_url"],
        downloadUrl: item["download_url"],
        isFavorite: await checkFavorite(item["id"]),
        isDownloaded: await checkDownloaded(item["id"]),
      ),
    );
  }
  return apiRes.data;
}

Future<String> getBookPath(int id) async{
  var dir = await getApplicationDocumentsDirectory();
  String path = "${dir.path}/$id.epub";

  return path;
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
    tabController = TabController(length: 2, vsync: this);
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
              pageCard("Livros", 0),
              pageCard("Favoritos", 1),
            ],
          ),
        ],
      ),
    );
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
          return bookItem(tmp.id, index, tmp.coverUrl, tmp.title, tmp.author,
              tmp.downloadUrl, tmp.isFavorite, tmp.isDownloaded, context);
        },
      ),
    );
  }

  showFavorites() {
    return const Text("Favorites");
  }

  addFavorite(int id, bool isFavorite) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList("bookmarks") ?? [];

    if (isFavorite) {
      bookmarks.add(id.toString());
    } else {
      bookmarks.remove(id.toString());
    }

    prefs.setStringList("bookmarks", bookmarks);
  }

  addDownloaded(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> downloaded = prefs.getStringList("downloaded") ?? [];

    downloaded.add(id.toString());
    prefs.setStringList("downloaded", downloaded);
  }

  Future downloadBookToDevice(String downloadUrl, int id) async {
    String path = await getBookPath(id);
    await dio.download(downloadUrl,
        path); //TODO
    await addDownloaded(id);
  }

  Future deleteBookFromDevice() async{
    //
  } //TODO

  Widget pageCard(String text, int innerIndex) {
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

  Widget askToDownload(String url, int id, index, BuildContext context) {
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
              await downloadBookToDevice(url, id);
              bookList[index].isDownloaded = true; //TODO
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text("Baixar")), //TODO
      ],
    );
  }

  Widget askToRemove(String url, int id, BuildContext context) {
    return AlertDialog(
      title: const Text("Excluir livro"),
      content: const SingleChildScrollView(
        child: Text("Deseja excluir o livro baixado?"),
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancelar")),
        TextButton(
            onPressed: () async {}, //TODO
            child: const Text("Excluir")),
      ],
    );
  }

  Widget bookItem(int id, index, String cover, title, author, dUrl,
      bool favorite, downloaded, BuildContext context) {
    return Stack(
      children: [
        Card(
          child: InkWell(
            onTap: () async {
              if (!downloaded) {
                return showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      bookList[index].isDownloaded = true;
                      return askToDownload(dUrl, id, index, context);
                    });
              } else {
                VocsyEpub.setConfig(
                  themeColor: Theme.of(context).primaryColor,
                  identifier: id.toString(),
                  scrollDirection: EpubScrollDirection.VERTICAL,
                  enableTts: true,
                  nightMode: false,
                );

                VocsyEpub.locatorStream.listen((locator) {
                  print('LOCATOR: $locator'); //TODO REMOVE
                });

                String test = await getBookPath(id); //TODO
                print("TEST IS $test");

                VocsyEpub.open(test);
              }
            },
            onLongPress: () {}, //TODO EXCLUIR DOWNLOAD
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 2.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: CachedNetworkImage(
                      imageUrl: cover,
                      imageBuilder: (context, imageProvider) => Container(
                        height: 150,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => const Center(
                        child: SizedBox(
                          height: 25,
                          width: 25,
                          child: CircularProgressIndicator(
                            color: Colors.lightGreen,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.highlight_remove,
                        color: Colors.lightGreen,
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      author,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
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
              setState(() {
                tmp.isFavorite = !tmp.isFavorite;
              });
              await addFavorite(id, tmp.isFavorite);
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
