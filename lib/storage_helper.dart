import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'main.dart';

//FEATURE SHARED PREFERENCES====================================================
addData(int id, String list, [bool isFavorite = false]) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> dataList = prefs.getStringList(list) ?? [];

  if(isFavorite){
    dataList.remove(id.toString());
  }else{
    dataList.add(id.toString());
  }

  prefs.setStringList(list, dataList);
}

//Ler dados salvos com shared preferences
checkSavedData(int id, String list) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> dataList = prefs.getStringList(list) ?? [];

  for (var favItem in dataList) {
    if (favItem == id.toString()) {
      return true;
    }
  }

  return false;
}

//FEATURE BOOK MISCELLANEOUS====================================================
//Contar tamanho da grid para os elementos
countSize(String list) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> dataList = prefs.getStringList(list) ?? [];

  return dataList.length;
}

//Pegar path de onde o livro foi salvo e nome
Future<String> getBookPath(int id) async {
  var dir = await getApplicationDocumentsDirectory();
  String path = "${dir.path}/$id.epub";

  return path;
}

//Baixar livro para o dispositivo
Future bookToDevice(String downloadUrl, int id, index) async {
  String path = await getBookPath(id);
  bookList[index].downloadLocation = path;

  await dio.download(downloadUrl, path);
  await addData(id, "downloaded");
  await addBook(bookList[index]);
  bookList[index].isDownloaded = true;
}

//TODO WORKING
//Pegar livros da API, caso database esteja vazio
Future getBooksFromApi() async {
  try {
    var apiRes = await dio.get("https://escribo.com/books.json");
    for (var book in apiRes.data) {
      var thisBook = Book(
        id: book["id"],
        title: book["title"],
        author: book["author"],
        coverUrl: book["cover_url"],
        downloadUrl: book["download_url"],
        isFavorite: await checkSavedData(book["id"], "bookmarks",),
        isDownloaded: await checkSavedData(book["id"], "downloaded"),
      );

      bookList.add(thisBook);
      await addBook(thisBook);
    }
    return apiRes.data;
  } on DioException catch (e) {
    throw Exception(e.message);
  }
}

//FEATURE SQFLITE DATABASE =====================================================
late Future<Database> database;
String tableCreation =
    """CREATE TABLE IF NOT EXISTS books(id INTEGER PRIMARY KEY, title TEXT, author TEXT, cover_url TEXT, download_url, download_location TEXT)""";

//Iniciar banco de dados
initDatabase() async {
  database = openDatabase(join(await getDatabasesPath(), "books.db"),
      onCreate: (db, version) {
    return db.execute(tableCreation);
  }, version: 1);
}

//Adicionar livro à tabela no armazenamento local
Future addBook(Book book) async {
  final db = await database;

  await db.insert(
    "books",
    book.mapBook(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

//TODO WORKING
//Pegar todos os livros salvos no banco de dados
Future getBooksFromDatabase() async{
  final db = await database;
  var tmp = await db.query("books");
  var bookMap = tmp.toList();

  for(var book in bookMap){
    var bdl = book["download_location"]; //book download location == bdl
    bookList.add(
      Book(id: book["id"] as int,
          title: book["title"] as String,
          author: book["author"] as String,
          coverUrl: book["cover_url"] as String,
          downloadUrl: book["download_url"] as String,
          isFavorite: await checkSavedData(book["id"] as int, "bookmarks"),
          isDownloaded: await checkSavedData(book["id"] as int, "downloaded"),
          downloadLocation: bdl != null ? bdl as String : null,
      )
    );
  }
  if(bookMap.isEmpty){
    return false;
  }

  return true;
}

//Classe principal que armazena as informações recebidas de https://escribo.com/books.json
class Book {
  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.downloadUrl,
    required this.isFavorite,
    required this.isDownloaded,
    this.downloadLocation,
  });

  int id;
  String title;
  String author;
  String coverUrl;
  String downloadUrl;
  bool isFavorite;
  bool isDownloaded;
  String? downloadLocation;

  Map<String, dynamic> mapBook() {
    return {
      "id": id,
      "title": title,
      "author": author,
      "cover_url": coverUrl,
      "download_url": downloadUrl,
      "download_location": downloadLocation,
    };
  }
}