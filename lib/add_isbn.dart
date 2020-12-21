import 'package:flutter/material.dart';

import 'main.dart';

class AddISBNPage extends StatefulWidget {
  final ValueChanged<String> onBarcodeScanned;

  AddISBNPage({@required this.onBarcodeScanned});

  @override
  _AddISBNPageState createState() => _AddISBNPageState();
}

class _AddISBNPageState extends State<AddISBNPage> {
  final textController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void closeDialog() {
    final parentState = context.findAncestorStateOfType<BarcoderAppState>();
    parentState.setState(
      () {
        parentState.isAddingBarcode = false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manually add barcode'),
      ),
      body: Column(children: [
        Text('Enter the barcode to add:'),
        TextField(
          controller: textController,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RaisedButton(
              onPressed: (() {
                widget.onBarcodeScanned(textController.text);
                closeDialog();
              }),
              child: Text('Add'),
            ),
            RaisedButton(
              onPressed: (() {
                closeDialog();
              }),
              child: Text('Cancel'),
            ),
          ],
        )
      ]),
    );
  }
}
