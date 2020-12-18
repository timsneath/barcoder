import 'package:flutter/material.dart';
import 'package:googleapis/books/v1.dart';

class BookDetailsPage extends StatelessWidget {
  final VolumeVolumeInfo book;

  BookDetailsPage({@required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
      ),
      body: Center(
        child: Text(book.title),
      ),
    );
  }
}
