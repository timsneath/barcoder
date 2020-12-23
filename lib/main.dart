import 'package:barcoder/bookdetails.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/books/v1.dart' as google_books;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_isbn.dart';
import 'barcoder.dart';
import 'books.dart';
import 'bookdetails.dart';

import 'model/book_cache.dart';

void main() {
  runApp(BarcoderApp());
}

class BarcoderApp extends StatefulWidget {
  @override
  BarcoderAppState createState() => BarcoderAppState();
}

class BarcoderAppState extends State<BarcoderApp> {
  SharedPreferences prefs;

  google_books.VolumeVolumeInfo selectedBook;
  bool isScanning = false;
  bool isAddingBarcode = false;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((instance) {
      prefs = instance;
      setState(() {
        if (!prefs.containsKey('bookshelf')) {
          print('No preferences found.');
          final bookshelf = {
            '9780525536291',
            '9781524763169',
            '9781250209764',
            '9780593230251',
            '9781984801258',
            '9780385543767',
            '9780735216723',
            '9780385348713',
            '9780385545969',
            '9780062868930',
          };
          prefs.setStringList('bookshelf', bookshelf.toList());
        } else {
          print('Preferences loaded.');
          final shelf = prefs.getStringList('bookshelf');
          Provider.of<BookStore>(context).addAll(shelf);
        }
      });
    });
  }

  void updateSettings() => prefs.setStringList(
      'bookshelf', Provider.of<BookStore>(context, listen: false).bookISBNs);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barcoder',
      home: ChangeNotifierProvider(
        create: (context) => BookStore()..addListener(updateSettings),
        child: Builder(
          builder: (BuildContext innerContext) => Navigator(
            pages: [
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
                      Provider.of<BookStore>(context, listen: false)
                          .add(barcode);
                    },
                  ),
                ),
              if (isAddingBarcode != false)
                MaterialPage(
                  key: ValueKey('AddingBarcodePage'),
                  child: AddISBNPage(
                    onBarcodeScanned: (barcode) {
                      Provider.of<BookStore>(context, listen: false)
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
