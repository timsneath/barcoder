import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';
import 'model/book_cache.dart';

class StartupPage extends StatefulWidget {
  StartupPage();

  @override
  _StartupPageState createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  @override
  void initState() {
    super.initState();
    onStart();
  }

  Future<void> onStart() async {
    await Provider.of<BookStore>(context, listen: false).init();
    final parentState = context.findAncestorStateOfType<BarcoderAppState>();
    parentState.setState(
      () {
        parentState.isLoaded = true;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
