import 'package:flutter/material.dart';
// import 'barcode_page.dart';
import 'books.dart';

void main() {
  runApp(BarcoderApp());
}

class BarcoderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barcoder',
      home: BooksPage(),
    );
  }
}
