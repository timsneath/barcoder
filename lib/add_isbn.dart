import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/navigator_model.dart';

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
    Provider.of<NavigatorModel>(context, listen: false).isAddingISBN = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manually add ISBN'),
      ),
      body: Column(children: [
        Text('Enter the ISBN to add:'),
        TextField(
          controller: textController,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RaisedButton(
              onPressed: (() {
                print('ISBN: ${textController.text}');
                widget.onBarcodeScanned(textController.text);
                closeDialog();
              }),
              child: Text('Add'),
            ),
            RaisedButton(
              onPressed: (() => closeDialog()),
              child: Text('Cancel'),
            ),
          ],
        )
      ]),
    );
  }
}
