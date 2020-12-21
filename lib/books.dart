import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/books/v1.dart' as booksapi;

import 'main.dart';

// TODO: Make this part of the app state
class GoogleBooks {
  Future<booksapi.VolumeVolumeInfo> getBook({String isbn}) async {
    var client = http.Client();
    try {
      final api = booksapi.BooksApi(client);
      final volumes = await api.volumes.list(q: 'isbn:$isbn');

      return volumes.items.first.volumeInfo;
    } finally {
      client.close();
    }
  }
}

class BookTile extends StatelessWidget {
  final booksapi.VolumeVolumeInfo book;
  final ValueChanged<booksapi.VolumeVolumeInfo> onTapped;
  final ValueChanged<booksapi.VolumeVolumeInfo> onSwipeLeft;

  BookTile(
      {@required this.book,
      @required this.onTapped,
      @required this.onSwipeLeft});

  Widget bookThumbnail() {
    var url = book.imageLinks.thumbnail;
    if (url != null) {
      if (url.startsWith('http://')) {
        url = url.replaceFirst('http://', 'https://');
      }
      return Image.network(url);
    } else {
      return const Icon(Icons.book);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (book == null) {
      // TODO: What should happen if the API returns null?
      return ListTile();
    } else {
      return Dismissible(
        background: Container(color: Colors.red),
        key: Key(book.hashCode.toString()),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) => onSwipeLeft(book),
        child: Card(
          child: InkWell(
            splashColor: Colors.blue.withAlpha(30),
            onTap: () => onTapped(book),
            child: ListTile(
              leading: bookThumbnail(),
              title: book.title != null ? Text(book.title) : '[Unknown]',
              subtitle: Text(book.authors.join(', ')),
            ),
          ),
        ),
      );
    }
  }
}

class BooksPage extends StatefulWidget {
  BooksPage();

  @override
  _BooksPageState createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  void _handleBookTapped(booksapi.VolumeVolumeInfo book) {
    final parentState = context.findAncestorStateOfType<BarcoderAppState>();

    parentState.setState(
      () {
        parentState.selectedBook = book;
      },
    );
  }

  void _handleBookDeleted(booksapi.VolumeVolumeInfo book) {
    final isbn = book.industryIdentifiers
        .where((id) => id.type == 'ISBN_13')
        .first
        .identifier;
    setState(() {
      Bookshelf.of(context).bookshelf.remove(isbn);
    });

    // TODO: Add undo action

    // This only works on the latest bits (e.g. `beta` channel). If you're using
    // Flutter 1.22 or lower (e.g. `stable` channel), you'll need to replace
    // `ScaffoldMessenger` with `Scaffold` below for this code to successfully
    // compile.
    //
    // For more information on this breaking change, see:
    // https://flutter.dev/docs/release/breaking-changes/scaffold-messenger
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${book.title} deleted.')));

    final parentState = context.findAncestorStateOfType<BarcoderAppState>();
    parentState.updateSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Books'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Manually add a book ISBN',
            onPressed: () {
              final parentState =
                  context.findAncestorStateOfType<BarcoderAppState>();

              parentState.setState(
                () {
                  parentState.isAddingBarcode = true;
                },
              );
            },
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: Bookshelf.of(context).bookshelf.length,
        itemBuilder: (BuildContext context, int index) {
          return FutureBuilder(
            future: GoogleBooks().getBook(
                isbn: Bookshelf.of(context).bookshelf.elementAt(index)),
            builder:
                (context, AsyncSnapshot<booksapi.VolumeVolumeInfo> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return BookTile(
                  book: snapshot.data,
                  onTapped: _handleBookTapped,
                  onSwipeLeft: _handleBookDeleted,
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.qr_code_scanner),
        onPressed: (() {
          final parentState =
              context.findAncestorStateOfType<BarcoderAppState>();

          parentState.setState(
            () {
              parentState.isScanning = true;
            },
          );
        }),
      ),
    );
  }
}
