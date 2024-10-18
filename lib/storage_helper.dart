import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'main.dart';

//FEATURE SHARED PREFERENCES====================================================
addData(int id, String list, [var isFavorite]) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> dataList = prefs.getStringList(list) ?? [];

  if (isFavorite == true) {
    dataList.remove(id.toString());
  }

  dataList.add(id.toString());
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

//FEATURE BOOK OPERATIONS=======================================================
//Pegar path de onde o livro foi salvo e nome
Future<String> getBookPath(int id) async {
  var dir = await getApplicationDocumentsDirectory();
  String path = "${dir.path}/$id.epub";

  return path;
}

//Baixar livro para o dispositivo
Future bookToDevice(String downloadUrl, int id) async {
  String path = await getBookPath(id);

  await dio.download(downloadUrl, path);
  await addData(id, "downloaded");
}

//FEATURE SQFLITE DATABASE =====================================================
late Future<Database> database;
String tableCreation =
    """CREATE TABLE IF NOT EXISTS books(id INTEGER PRIMARY KEY, title TEXT, author TEXT, cover_url TEXT, download_url TEXT, is_favorite INTEGER, is_downloaded INTEGER)""";

//Iniciar banco de dados
initDatabase() async {
  database = openDatabase(join(await getDatabasesPath(), "books.db"),
      onCreate: (db, version) {
    return db.execute(tableCreation);
  }, version: 1);
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

/*
* //TODO USE THIS
Future addBook(Book book) async {
  final db = await database;

  await db.insert(
    "books",
    book.mapBook(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}*/
