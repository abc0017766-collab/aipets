cd C:/app/flutter_application_1
git add [flutter-ci.yml](http://_vscodecontentref_/1)
git commit -m "Add Flutter CI workflow"
git pushimport 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/home_root_screen.dart';

class DogCareApp extends StatelessWidget {
  const DogCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Dog Care',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2C7A7B)),
        useMaterial3: true,
      ),
      home: const HomeRootScreen(),
    );
  }
}
