import 'package:barcoder/barcoder.dart';
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
  BarcoderAppState createState() => BarcoderAppState();
}

class BarcoderAppState extends State<BarcoderApp> {
  VolumeVolumeInfo _selectedBook;
  bool isScanning = false;

  void _handleBookTapped(VolumeVolumeInfo book) {
    setState(() {
      _selectedBook = book;
    });
  }

  void _handleBarcodeScanned(String barcode) {
    // add to bookshelf
    print(barcode);
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
          if (isScanning != false)
            MaterialPage(
                key: ValueKey('ScanningPage'),
                child: BarcoderPage(onBarcodeScanned: _handleBarcodeScanned))
        ],
        onPopPage: (route, result) {
          if (!route.didPop(result)) {
            return false;
          }

          setState(() {
            if (isScanning == true) {
              isScanning = false;
            }
            if (_selectedBook != null) {
              _selectedBook = null;
            }
          });
          return true;
        },
      ),
    );
  }
}
