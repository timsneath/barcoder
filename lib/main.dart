import 'package:barcoder/bookdetails.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/books/v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_isbn.dart';
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

// TODO: Cache the retrieved information from the Google Books API
class BarcoderAppState extends State<BarcoderApp> {
  Set<String> bookshelf;
  SharedPreferences prefs;

  VolumeVolumeInfo _selectedBook;
  bool isScanning = false;
  bool isAddingBarcode = false;

  // TODO: Should this be part of the Books page?
  void _handleBookTapped(VolumeVolumeInfo book) {
    setState(() {
      _selectedBook = book;
    });
  }

  void _handleBookDeleted(VolumeVolumeInfo book) {
    final isbn = book.industryIdentifiers
        .where((id) => id.type == 'ISBN_13')
        .first
        .identifier;
    setState(() {
      bookshelf.remove(isbn);
    });
    updateSettings();
  }

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((instance) {
      prefs = instance;
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
      });
    });
  }

  void updateSettings() {
    prefs.setStringList('bookshelf', bookshelf.toList());
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
                  onSwipeLeft: _handleBookDeleted,
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
                      setState(() {
                        Bookshelf.of(innerContext).bookshelf.add(barcode);
                      });
                      updateSettings();
                    },
                  ),
                ),
              if (isAddingBarcode != false)
                MaterialPage(
                  key: ValueKey('AddingBarcodePage'),
                  child: AddISBNPage(
                    onBarcodeScanned: (barcode) {
                      setState(() {
                        Bookshelf.of(innerContext).bookshelf.add(barcode);
                      });
                      updateSettings();
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
