import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent_ui;
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:window_manager/window_manager.dart';

bool get isDesktop {
  if (kIsWeb) return false;
  return [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (isDesktop) {
    await flutter_acrylic.Window.initialize();
    await WindowManager.instance.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setTitleBarStyle(TitleBarStyle.normal,
          windowButtonVisibility: false);
      await windowManager.setSize(const Size(755, 545));
      await windowManager.setMinimumSize(const Size(755, 545));
      await windowManager.center();
      await windowManager.show();
      await windowManager.setPreventClose(false);
      await windowManager.setSkipTaskbar(false);
    });
  }
  runApp(MyApp());
}

// void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  int _index = 0;
  var _questionIndex = 0;

  void _answerQuestion() {
    setState(() {
      _questionIndex = _questionIndex + 1;
    });
    print(_questionIndex);
  }

  @override
  Widget build(BuildContext context) {
    var questions = [
      'Cual es tu color favorito?',
      'Cual es tu animal favorito?',
    ];

    return Platform.isWindows
        ? fluent_ui.FluentApp(
            title: 'Flutter App',
            home: fluent_ui.NavigationView(
              appBar: const fluent_ui.NavigationAppBar(
                title: Text('Flutter App'),
              ),
              content: fluent_ui.NavigationBody(
                index: _index,
                children: [
                  Column(
                    children: [
                      Text(questions[_questionIndex]),
                      ElevatedButton(
                        child: const Text('Respuesta 1'),
                        onPressed: _answerQuestion,
                      ),
                      ElevatedButton(
                        child: const Text('Respuesta 2'),
                        onPressed: _answerQuestion,
                      ),
                      ElevatedButton(
                        child: const Text('Respuesta 3'),
                        onPressed: _answerQuestion,
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        : MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: const Text('Flutter App')),
              body: Column(
                children: [
                  const Text('La pregunta'),
                  ElevatedButton(
                    child: const Text('Respuesta 1'),
                    onPressed: _answerQuestion,
                  ),
                  ElevatedButton(
                    child: const Text('Respuesta 2'),
                    onPressed: _answerQuestion,
                  ),
                  ElevatedButton(
                    child: const Text('Respuesta 3'),
                    onPressed: _answerQuestion,
                  ),
                ],
              ),
            ),
          );
  }
}
