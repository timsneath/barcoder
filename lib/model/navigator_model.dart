import 'package:flutter/foundation.dart';

import 'package:googleapis/books/v1.dart' as google_books;

class NavigatorModel extends ChangeNotifier {
  google_books.VolumeVolumeInfo _selectedBook;
  bool _isLoaded = false;
  bool _isScanning = false;
  bool _isAddingISBN = false;

  google_books.VolumeVolumeInfo get selectedBook => _selectedBook;
  set selectedBook(google_books.VolumeVolumeInfo value) {
    _selectedBook = value;
    notifyListeners();
  }

  bool get isLoaded => _isLoaded;
  set isLoaded(bool value) {
    _isLoaded = value;
    notifyListeners();
  }

  bool get isScanning => _isScanning;
  set isScanning(bool value) {
    _isScanning = value;
    notifyListeners();
  }

  bool get isAddingISBN => _isAddingISBN;
  set isAddingISBN(bool value) {
    _isAddingISBN = value;
    notifyListeners();
  }
}
