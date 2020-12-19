import 'package:barcoder/bookdetails.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/books/v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'barcoder.dart';
import 'books.dart';
import 'bookdetails.dart';

void main() {
  runApp(BarcoderApp());
}

class Bookshelf extends InheritedWidget {
  final Set<String> bookshelf;

  const Bookshelf({this.bookshelf, @required Widget child})
      : super(child: child);

  static Bookshelf of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Bookshelf>();
  }

  @override
  bool updateShouldNotify(Bookshelf oldBookshelf) =>
      oldBookshelf.bookshelf != bookshelf;
}

class BarcoderApp extends StatefulWidget {
  @override
  BarcoderAppState createState() => BarcoderAppState();
}

class BarcoderAppState extends State<BarcoderApp> {
  Set<String> bookshelf;
  SharedPreferences prefs;

  VolumeVolumeInfo _selectedBook;
  bool isScanning = false;

  void _handleBookTapped(VolumeVolumeInfo book) {
    setState(() {
      _selectedBook = book;
    });
  }

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) => {
          setState(() {
            if (!prefs.containsKey('bookshelf')) {
              print('No preferences found.');
              bookshelf = {
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
              bookshelf = prefs.getStringList('bookshelf').toSet();
              print('Preferences loaded.');
            }
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barcoder',
      home: Bookshelf(
        bookshelf: bookshelf ?? {},
        child: Builder(
          builder: (BuildContext innerContext) => Navigator(
            pages: [
              MaterialPage(
                key: ValueKey('BooksPage'),
                child: BooksPage(
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
                  child: BarcoderPage(
                    onBarcodeScanned: (barcode) {
                      setState(() async {
                        Bookshelf.of(innerContext).bookshelf.add(barcode);
                        await prefs.setStringList('bookshelf',
                            Bookshelf.of(innerContext).bookshelf.toList());
                      });
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
                if (_selectedBook != null) {
                  _selectedBook = null;
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
