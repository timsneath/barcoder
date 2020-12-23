import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:googleapis/books/v1.dart' as google_books;
import 'package:http/http.dart' as http;

import 'book_service.dart';

/// A 'shopping cart' of books.
class BookStore extends ChangeNotifier {
  final Map<String, google_books.VolumeVolumeInfo> _books = {};
  final BookService bookService = BookService();

  UnmodifiableListView<String> get bookISBNs => _books.keys;

  void add(String isbn) async {
    _books[isbn] = await bookService.getBookDetails(isbn);
    notifyListeners();
  }

  void addAll(List<String> isbnList) {
    final httpClient = http.Client();

    try {
      isbnList.forEach((isbn) async {
        _books[isbn] =
            await bookService.getBookDetails(isbn, httpClient: httpClient);
      });
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
