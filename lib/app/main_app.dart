import 'package:flutter/material.dart';

import '../features/memos/presentation/pages/memo_home_page.dart';

class WorklifeMemoApp extends StatelessWidget {
  const WorklifeMemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Worklife Memo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const MemoHomePage(),
    );
  }
}
