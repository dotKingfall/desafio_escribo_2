import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

late Future<Database> database;
String tableCreation =
    """CREATE TABLE IF NOT EXISTS books(id INTEGER PRIMARY KEY, title TEXT, author TEXT, cover_url TEXT, download_url TEXT, is_favorite INTEGER, is_downloaded INTEGER)""";

initDatabase() async {
  database = openDatabase(join(await getDatabasesPath(), "books.db"),
      onCreate: (db, version) {
    return db.execute(tableCreation);
  }, version: 1);
}

Future addBook(Book book) async {
  final db = await database;

  await db.insert(
    "books",
    book.mapBook(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

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

  Map<String, dynamic> mapBook() {
    return {
      "id": id,
      "title": title,
      "author": author,
      "cover_url": coverUrl,
      "download_url": downloadUrl,
      "is_favorite": isFavorite,
      "is_downloaded": isDownloaded,
    };
  }
}
