import 'package:barcoder/bookdetails.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/books/v1.dart';
// import 'barcode_page.dart';
import 'books.dart';

void main() {
  runApp(BarcoderApp());
}

class BarcoderApp extends StatefulWidget {
  @override
  _BarcoderAppState createState() => _BarcoderAppState();
}

class _BarcoderAppState extends State<BarcoderApp> {
  VolumeVolumeInfo _selectedBook;

  void _handleBookTapped(VolumeVolumeInfo book) {
    setState(() {
      _selectedBook = book;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barcoder',
      home: Navigator(
        pages: [
          MaterialPage(
            key: ValueKey('BooksPage'),
            child: BooksPage(
              books: bookshelf,
              onTapped: _handleBookTapped,
            ),
          ),
          if (_selectedBook != null)
            MaterialPage(
              key: ValueKey(_selectedBook),
              child: BookDetailsPage(book: _selectedBook),
            ),
        ],
        onPopPage: (route, result) {
          if (!route.didPop(result)) {
            return false;
          }

          setState(() {
            _selectedBook = null;
          });
          return true;
        },
      ),
    );
  }
}
