import 'package:flutter/material.dart';
import 'package:googleapis/books/v1.dart' as google_books;
import 'package:provider/provider.dart';

import 'model/book_cache.dart';
import 'main.dart';

class BookTile extends StatelessWidget {
  final google_books.VolumeVolumeInfo book;
  final ValueChanged<google_books.VolumeVolumeInfo> onTapped;
  final ValueChanged<google_books.VolumeVolumeInfo> onSwipeLeft;

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
      // TODO: Use slidable package when refactoring is complete.
      //   https://github.com/letsar/flutter_slidable/issues/186
      return Dismissible(
        background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.all(16),
            child: const Icon(Icons.delete, color: Colors.white)),
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
      body: BooksList(),
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

class BooksList extends StatelessWidget {
  void _handleBookTapped(
      BuildContext context, google_books.VolumeVolumeInfo book) {
    final parentState = context.findAncestorStateOfType<BarcoderAppState>();

    parentState.selectedBook = book;
  }

  void _handleBookDeleted(
      BuildContext context, google_books.VolumeVolumeInfo book) {
    final isbn = book.industryIdentifiers
        .where((id) => id.type == 'ISBN_13')
        .first
        .identifier;
    Provider.of<BookStore>(context).removeBook(isbn);

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
    print('bookslist.build()');
    return Consumer<BookStore>(
      builder: (context, store, child) {
        print('store.length is ${store.length()}');
        // return Text(store.first.title);
        return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: store.length(),
            itemBuilder: (BuildContext context, int index) {
              return BookTile(
                book: store[index],
                onTapped: (book) => _handleBookTapped(context, book),
                onSwipeLeft: (book) => _handleBookDeleted(context, book),
              );
            });
      },
    );
  }
}
