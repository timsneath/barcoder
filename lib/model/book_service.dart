import 'package:googleapis/books/v1.dart' as google_books;
import 'package:http/http.dart' as http;

class BookService {
  final Map<String, google_books.VolumeVolumeInfo> _cachedBooks = {};

  /// Returns the cached book details if they exist. Alternatively, call the
  /// Google books API to add them to the cache and return the results.
  ///
  /// If an existing HTTP connection is provided, that will be used. If not,
  /// this function creates a short-lived HTTP connection that is closed at the
  /// end of the call.
  Future<google_books.VolumeVolumeInfo> getBookDetails(String isbn,
      {http.Client httpClient}) async {
    final client = httpClient ?? http.Client();

    try {
      if (!_cachedBooks.containsKey(isbn) || _cachedBooks[isbn] == null) {
        final api = google_books.BooksApi(client);
        final volumes = await api.volumes.list(q: 'isbn:$isbn');
        _cachedBooks[isbn] = volumes.items.first.volumeInfo;
      }
      return _cachedBooks[isbn];
    } finally {
      if (httpClient == null) {
        client.close();
      }
    }
  }
}
