import 'package:flutter/material.dart';

class BookDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Details'),
      ),
      body: Center(
        child: FlatButton(
          child: Text('Pop!'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
