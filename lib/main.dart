import 'package:barcoder/bookdetails.dart';
import 'package:barcoder/model/navigator_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'add_isbn.dart';
import 'barcoder.dart';
import 'books.dart';
import 'bookdetails.dart';
import 'startup.dart';

import 'model/bookshelf_model.dart';

void main() {
  runApp(BarcoderApp());
}

class BarcoderApp extends StatefulWidget {
  @override
  BarcoderAppState createState() => BarcoderAppState();
}

class BarcoderAppState extends State<BarcoderApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barcoder',
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => NavigatorModel()),
          ChangeNotifierProvider(
            create: (_) => BookshelfModel(),
          ),
        ],
        child: BarcoderNavigator(),
      ),
    );
  }
}

class BarcoderNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<NavigatorModel>(
      builder: (_, pageModel, __) => Navigator(
        pages: [
          if (pageModel.isLoaded == false)
            MaterialPage(
              key: ValueKey('StartupPage'),
              child: StartupPage(),
            )
          else
            MaterialPage(
              key: ValueKey('BooksPage'),
              child: BooksPage(),
            ),
          if (pageModel.selectedBook != null)
            MaterialPage(
              key: ValueKey(pageModel.selectedBook),
              child: BookDetailsPage(book: pageModel.selectedBook),
            ),
          if (pageModel.isScanning != false)
            MaterialPage(
              key: ValueKey('ScanningPage'),
              child: BarcoderPage(
                onBarcodeScanned: (barcode) {
                  Provider.of<BookshelfModel>(context, listen: false)
                      .add(barcode);
                },
              ),
            ),
          if (pageModel.isAddingISBN != false)
            MaterialPage(
              key: ValueKey('AddingBarcodePage'),
              child: AddISBNPage(
                onBarcodeScanned: (barcode) {
                  Provider.of<BookshelfModel>(context, listen: false)
                      .add(barcode);
                },
              ),
            )
        ],
        onPopPage: (route, result) {
          if (!route.didPop(result)) {
            return false;
          }

          if (pageModel.isScanning) {
            pageModel.isScanning = false;
          }

          if (pageModel.isAddingISBN) {
            pageModel.isAddingISBN = false;
          }
          if (pageModel.selectedBook != null) {
            pageModel.selectedBook = null;
          }

          return true;
        },
      ),
    );
  }
}
