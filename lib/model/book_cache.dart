import 'package:flutter/material.dart';

import 'package:googleapis/books/v1.dart' as google_books;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'book_service.dart';

/// A 'shopping cart' of books.
class BookStore extends ChangeNotifier {
  SharedPreferences prefs;

  final Map<String, google_books.VolumeVolumeInfo> _books = {};
  final BookService bookService = BookService();

  List<String> get bookISBNs => _books.keys.toList();

  void add(String isbn) async {
    _books[isbn] = await bookService.getBookDetails(isbn);
    notifyListeners();
  }

  void addAll(List<String> isbnList) async {
    final httpClient = http.Client();

    try {
      for (final isbn in isbnList) {
        _books[isbn] =
            await bookService.getBookDetails(isbn, httpClient: httpClient);
        print('added book $isbn. _books.length is ${_books.length}.');
      }
      notifyListeners();
    } finally {
      httpClient.close();
    }
  }

  google_books.VolumeVolumeInfo get first => _books.entries.first.value;

  google_books.VolumeVolumeInfo operator [](int index) =>
      _books.entries.toList()[index].value;

  int length() {
    return _books.keys.length;
  }

  void removeBook(google_books.VolumeVolumeInfo bookToRemove) {
    assert(_books.containsValue(bookToRemove));
    _books.removeWhere((_, book) => book == bookToRemove);
    prefs.setStringList('bookshelf', bookISBNs);

    notifyListeners();
  }

  void removeAll() {
    _books.clear();
    notifyListeners();
  }

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('bookshelf')) {
      print('No preferences found.');
      await addAll([
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
      ]);
      await prefs.setStringList('bookshelf', bookISBNs);
    } else {
      print('Preferences found.');
      final shelf = prefs.getStringList('bookshelf');
      await addAll(shelf);
    }
  }
}
