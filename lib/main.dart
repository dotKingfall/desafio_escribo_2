import 'package:desafio_tecnico_2/tabs/favoritos.dart';
import 'package:desafio_tecnico_2/tabs/livros.dart';
import 'package:desafio_tecnico_2/tabs/offline.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'storage_helper.dart';

final dio = Dio(
  BaseOptions(
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
  ),
);
List<Book> bookList = [];
List<Book> databaseList = [];

Color beautifulGreen = const Color(0XFF768a76);
Color darkerBeautiful = const Color(0XFF465246);
Color pleasantWhite = const Color(0XFFF9F6EE);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDatabase();

  runApp(
    MaterialApp(
      title: "Desafio escribo 2",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            dynamicSchemeVariant: DynamicSchemeVariant.fruitSalad),
        textTheme: GoogleFonts.merriweatherTextTheme(),
      ),
      home: const BookLibrary(),
    ),
  );
}

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
    tabController = TabController(
      length: 3,
      vsync: this,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "E-BOOK READER",
          style: barsStyle,
        ),
        centerTitle: true,
        backgroundColor: beautifulGreen,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 45.0, left: 10.0, right: 10.0),
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: tabController,
              children: [
                showBooks(),
                showFav(),
                showOffline(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Row(
              children: [
                pageNavigator("Livros", 0),
                pageNavigator("Favoritos", 1),
                pageNavigator("Offline", 2)
              ],
            ),
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
            ? darkerBeautiful
            : beautifulGreen,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: darkerBeautiful, width: 2.5),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            tabController.animateTo(innerIndex);
          });
        },
        child: Text(
          text,
          style: barsStyle,
        ),
      ),
    );
  }
}

TextStyle barsStyle = GoogleFonts.ubuntu(
  color: pleasantWhite,
  fontWeight: FontWeight.w600,
);
