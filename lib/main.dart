import 'package:barcoder/bookdetails.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/books/v1.dart' as google_books;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_isbn.dart';
import 'barcoder.dart';
import 'books.dart';
import 'bookdetails.dart';
import 'startup.dart';

import 'model/book_cache.dart';

void main() {
  runApp(BarcoderApp());
}

class BarcoderApp extends StatefulWidget {
  @override
  BarcoderAppState createState() => BarcoderAppState();
}

class BarcoderAppState extends State<BarcoderApp> {
  google_books.VolumeVolumeInfo selectedBook;
  bool isLoaded = false;
  bool isScanning = false;
  bool isAddingBarcode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barcoder',
      home: ChangeNotifierProvider(
        create: (context) => BookStore()

        // ..addListener(updateSettings)
        ,
        child: Builder(
          builder: (BuildContext innerContext) => Navigator(
            pages: [
              if (isLoaded == false)
                MaterialPage(
                  key: ValueKey('StartupPage'),
                  child: StartupPage(),
                )
              else
                MaterialPage(
                  key: ValueKey('BooksPage'),
                  child: BooksPage(),
                ),
              if (selectedBook != null)
                MaterialPage(
                  key: ValueKey(selectedBook),
                  child: BookDetailsPage(book: selectedBook),
                ),
              if (isScanning != false)
                MaterialPage(
                  key: ValueKey('ScanningPage'),
                  child: BarcoderPage(
                    onBarcodeScanned: (barcode) {
                      Provider.of<BookStore>(innerContext, listen: false)
                          .add(barcode);
                    },
                  ),
                ),
              if (isAddingBarcode != false)
                MaterialPage(
                  key: ValueKey('AddingBarcodePage'),
                  child: AddISBNPage(
                    onBarcodeScanned: (barcode) {
                      Provider.of<BookStore>(innerContext, listen: false)
                          .add(barcode);
                    },
                  ),
                )
            ],
            onPopPage: (route, result) {
              if (!route.didPop(result)) {
                return false;
              }

              setState(() {
                if (isScanning == true) {
                  isScanning = false;
                }
                if (isAddingBarcode == true) {
                  isAddingBarcode = false;
                }
                if (selectedBook != null) {
                  selectedBook = null;
                }
              });
              return true;
            },
          ),
        ),
      ),
    );
  }
}
