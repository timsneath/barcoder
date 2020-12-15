import 'package:flutter/material.dart';
import 'scanner.dart';

void main() {
  runApp(BarcoderApp());
}

class BarcoderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barcoder',
      home: BarcoderPage(),
    );
  }
}

class BarcoderPage extends StatefulWidget {
  @override
  _BarcoderPageState createState() => _BarcoderPageState();
}

class _BarcoderPageState extends State<BarcoderPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialBarcodeScanner();
  }
}
