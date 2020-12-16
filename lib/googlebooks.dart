import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/books/v1.dart';

const bookshelf = <String>[
  '9780525536291',
  '9781524763169',
  '9781250209764',
  '9780593230251',
  '9780593229354',
  '9780385543767',
  '9780735216723',
  '9780385348713',
  '9780385545969',
  '9780062868930',
];

class GoogleBook {
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

  BookTile(this.book);

  @override
  Widget build(BuildContext context) {
    final bookThumbnail = book.imageLinks?.smallThumbnail;

    return ListTile(
      leading: bookThumbnail != null
          ? Image.network(bookThumbnail)
          : const Icon(Icons.book),
      title: Text(book.title),
      subtitle: Text(book.authors.first),
    );
  }
}

class BooksPage extends StatefulWidget {
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
      body: FutureBuilder(
        future: GoogleBook().getBook(isbn: bookshelf[0]),
        builder: (context, AsyncSnapshot<VolumeVolumeInfo> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return BookTile(snapshot.data);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
