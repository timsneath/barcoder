import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/books/v1.dart';

import 'main.dart';

const bookshelf = <String>[
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
];

class GoogleBooks {
  Future<VolumeVolumeInfo> getBook({String isbn}) async {
    var client = http.Client();
    try {
      var api = BooksApi(client);
      final volumes = await api.volumes.list(q: 'isbn:$isbn');
      return volumes.items.first.volumeInfo;
    } finally {
      client.close();
    }
  }
}

class BookTile extends StatelessWidget {
  final VolumeVolumeInfo book;
  final ValueChanged<VolumeVolumeInfo> onTapped;

  BookTile({@required this.book, @required this.onTapped});

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
      return ListTile();
    } else {
      return Card(
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () => onTapped(book),
          child: ListTile(
            leading: bookThumbnail(),
            title: book.title != null ? Text(book.title) : '[Unknown]',
            subtitle: Text(book.authors.join(', ')),
          ),
        ),
      );
    }
  }
}

class BooksPage extends StatefulWidget {
  final List<String> books;
  final ValueChanged<VolumeVolumeInfo> onTapped;

  BooksPage({@required this.books, @required this.onTapped});

  @override
  _BooksPageState createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Books'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: bookshelf.length,
        itemBuilder: (BuildContext context, int index) {
          return FutureBuilder(
            future: GoogleBooks().getBook(isbn: bookshelf[index]),
            builder: (context, AsyncSnapshot<VolumeVolumeInfo> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return BookTile(
                  book: snapshot.data,
                  onTapped: widget.onTapped,
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
          child: Icon(Icons.scanner),
          onPressed: (() {
            var parentState =
                context.findAncestorStateOfType<BarcoderAppState>();

            parentState.setState(() {
              parentState.isScanning = true;
            });
          })),
    );
  }
}
