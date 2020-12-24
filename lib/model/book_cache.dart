import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:googleapis/books/v1.dart' as google_books;
import 'package:http/http.dart' as http;

import 'book_service.dart';

/// A 'shopping cart' of books.
class BookStore extends ChangeNotifier {
  final Map<String, google_books.VolumeVolumeInfo> _books = {};
  final BookService bookService = BookService();

  // SharedPreferences.getInstance().then((instance) {
  //   prefs = instance;
  //   setState(() {
  //     if (!prefs.containsKey('bookshelf')) {
  //       print('No preferences found.');
  //       final bookshelf = {
  //         '9780525536291',
  //         '9781524763169',
  //         '9781250209764',
  //         '9780593230251',
  //         '9781984801258',
  //         '9780385543767',
  //         '9780735216723',
  //         '9780385348713',
  //         '9780385545969',
  //         '9780062868930',
  //       };
  //       prefs.setStringList('bookshelf', bookshelf.toList());
  //     } else {
  //       print('Preferences loaded.');
  //       final shelf = prefs.getStringList('bookshelf');
  //       Provider.of<BookStore>(context).addAll(shelf);
  //     }
  //   });
  // });

  // TODO: Init from preferences
  BookStore() {
    addAll([
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
  }

  UnmodifiableListView<String> get bookISBNs => _books.keys;

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
      }
      notifyListeners();
    } finally {
      httpClient.close();
    }
  }

  google_books.VolumeVolumeInfo operator [](isbn) => _books[isbn];

  int length() {
    return _books.keys.length;
  }

  void removeBook(String isbn) {
    _books.remove(isbn);
    notifyListeners();
  }

  void removeAll() {
    _books.clear();
    notifyListeners();
  }
}
