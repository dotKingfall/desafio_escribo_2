import 'package:flutter/material.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';
import 'package:path_provider/path_provider.dart';

class Reader extends StatefulWidget {
  const Reader({super.key, required this.id, required this.bookPath});

  final int id;
  final String bookPath;

  @override
  State<Reader> createState() => _ReaderState();
}

class _ReaderState extends State<Reader> {
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(),
      body: Container(),
    );
  }
}
