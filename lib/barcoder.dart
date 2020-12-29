import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class BarcoderPage extends StatefulWidget {
  final ValueChanged<String> onBarcodeScanned;

  BarcoderPage({@required this.onBarcodeScanned});

  @override
  _BarcoderPageState createState() => _BarcoderPageState();
}

class _BarcoderPageState extends State<BarcoderPage> {
  String _scanBarcode = 'Unknown';

  Future<void> startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
            '#ff6666', 'Cancel', true, ScanMode.BARCODE)
        .listen((barcode) => widget.onBarcodeScanned(barcode));
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });

    widget.onBarcodeScanned(barcodeScanRes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barcode scan')),
      body: Builder(
        builder: (BuildContext context) {
          return Container(
            alignment: Alignment.center,
            child: Flex(
              direction: Axis.vertical,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton(
                    onPressed: () => scanBarcodeNormal(),
                    child: Text('Start barcode scan')),
                RaisedButton(
                    onPressed: () => startBarcodeScanStream(),
                    child: Text('Start barcode scan stream')),
                Text('Scan result : $_scanBarcode\n',
                    style: TextStyle(fontSize: 20))
              ],
            ),
          );
        },
      ),
    );
  }
}
