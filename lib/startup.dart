import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/bookshelf_model.dart';
import 'model/navigator_model.dart';

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
    await Provider.of<BookshelfModel>(context, listen: false).init();
    Provider.of<NavigatorModel>(context, listen: false).isLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
