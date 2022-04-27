import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent_ui;
import 'package:flutter/foundation.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';
import 'package:url_launcher/link.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:window_manager/window_manager.dart';

import './theme.dart';

const String appTitle = 'Flutter Demo';

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

  if (kIsWeb ||
      [TargetPlatform.windows, TargetPlatform.android]
          .contains(defaultTargetPlatform)) {
    SystemTheme.accentColor;
  }

  setPathUrlStrategy();

  if (isDesktop) {
    await flutter_acrylic.Window.initialize();
    await WindowManager.instance.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setTitleBarStyle(TitleBarStyle.hidden,
          windowButtonVisibility: false);
      await windowManager.setSize(const Size(755, 545));
      await windowManager.setMinimumSize(const Size(755, 545));
      await windowManager.center();
      await windowManager.show();
      await windowManager.setPreventClose(true);
      await windowManager.setSkipTaskbar(false);
    });
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppTheme(),
      builder: (context, _) {
        final appTheme = context.watch<AppTheme>();
        return Platform.isWindows
            ? fluent_ui.FluentApp(
                title: appTitle,
                themeMode: appTheme.mode,
                debugShowCheckedModeBanner: false,
                home: const MyHomePage(title: appTitle),
                color: appTheme.color,
                darkTheme: fluent_ui.ThemeData(
                  brightness: Brightness.dark,
                  accentColor: appTheme.color,
                  visualDensity: VisualDensity.standard,
                  focusTheme: fluent_ui.FocusThemeData(
                    glowFactor: fluent_ui.is10footScreen() ? 2.0 : 0.0,
                  ),
                ),
                theme: fluent_ui.ThemeData(
                  accentColor: appTheme.color,
                  visualDensity: VisualDensity.standard,
                  focusTheme: fluent_ui.FocusThemeData(
                    glowFactor: fluent_ui.is10footScreen() ? 2.0 : 0.0,
                  ),
                ),
                builder: (context, child) {
                  return Directionality(
                    textDirection: appTheme.textDirection,
                    child: fluent_ui.NavigationPaneTheme(
                      data: fluent_ui.NavigationPaneThemeData(
                        backgroundColor: appTheme.windowEffect !=
                                flutter_acrylic.WindowEffect.disabled
                            ? Colors.transparent
                            : null,
                      ),
                      child: child!,
                    ),
                  );
                },
              )
            : MaterialApp(
                title: 'Flutter Demo',
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                ),
                home: const MyHomePage(title: 'Flutter Demo Home Page'),
              );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WindowListener {
  int _counter = 0;
  bool value = false;
  int index = 0;
  final settingsController = ScrollController();
  final viewKey = GlobalKey();
  final searchTextController = TextEditingController();

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    settingsController.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    return isDesktop
        ? fluent_ui.NavigationView(
            key: viewKey,
            appBar: fluent_ui.NavigationAppBar(
              title: () {
                if (kIsWeb) return const Text(appTitle);
                return const DragToMoveArea(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(appTitle),
                  ),
                );
              }(),
              actions: kIsWeb
                  ? null
                  : DragToMoveArea(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [Spacer(), WindowButtons()],
                      ),
                    ),
            ),
            pane: fluent_ui.NavigationPane(
              selected: index,
              onChanged: (i) => setState(() => index = i),
              size: const fluent_ui.NavigationPaneSize(
                openMinWidth: 250,
                openMaxWidth: 320,
              ),
              header: Container(
                height: fluent_ui.kOneLineTileHeight,
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: const FlutterLogo(
                  style: FlutterLogoStyle.horizontal,
                  size: 100,
                ),
              ),
              displayMode: appTheme.displayMode,
              indicator: () {
                switch (appTheme.indicator) {
                  case NavigationIndicators.end:
                    return const fluent_ui.EndNavigationIndicator();
                  case NavigationIndicators.sticky:
                  default:
                    return const fluent_ui.StickyNavigationIndicator();
                }
              }(),
              autoSuggestBox: fluent_ui.AutoSuggestBox(
                controller: searchTextController,
                items: const ['Item 1', 'Item 2', 'Item 3', 'Item 4'],
                leadingIcon: Container(
                  child: const fluent_ui.Icon(fluent_ui.FluentIcons.search),
                  margin: const EdgeInsets.only(left: 8),
                ),
              ),
              autoSuggestBoxReplacement:
                  const Icon(fluent_ui.FluentIcons.search),
              footerItems: [
                fluent_ui.PaneItemSeparator(),
                fluent_ui.PaneItem(
                  icon: const Icon(fluent_ui.FluentIcons.settings),
                  title: const Text('Ajustes'),
                ),
                _LinkPaneItemAction(
                  icon: const Icon(fluent_ui.FluentIcons.open_source),
                  title: const Text('Source code'),
                  link:
                      'https://github.com/ginsenghung/flutter_apps_maximilian',
                ),
              ],
            ),
            content: fluent_ui.NavigationBody(
              index: index,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Tocaste el botón: ',
                    ),
                    Text(
                      '$_counter',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    fluent_ui.FilledButton(
                      child: const Icon(fluent_ui.FluentIcons.add),
                      onPressed: _incrementCounter,
                    ),
                  ],
                ),
              ],
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'You have pushed the button this many times:',
                  ),
                  Text(
                    '$_counter',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: _incrementCounter,
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            ), // This trailing comma makes auto-formatting nicer for build methods.
          );
  }

  @override
  void onWindowClose() async {
    bool _isPreventClose = await windowManager.isPreventClose();
    if (_isPreventClose) {
      showDialog(
        context: context,
        builder: (_) {
          return fluent_ui.ContentDialog(
            title: const Text('¿Desea cerrar?'),
            content: const Text('¿Está seguro que desea cerrar esta ventana?'),
            actions: [
              fluent_ui.FilledButton(
                child: const Text('Sí'),
                onPressed: () {
                  Navigator.pop(context);
                  windowManager.destroy();
                },
              ),
              fluent_ui.Button(
                child: const Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fluent_ui.ThemeData theme = fluent_ui.FluentTheme.of(context);

    return SizedBox(
      width: 138,
      height: 50,
      child: WindowCaption(
        brightness: theme.brightness,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}

class _LinkPaneItemAction extends fluent_ui.PaneItem {
  _LinkPaneItemAction({
    required Widget icon,
    required this.link,
    title,
    infoBadge,
    focusNode,
    autofocus = false,
  }) : super(
          icon: icon,
          title: title,
          infoBadge: infoBadge,
          focusNode: focusNode,
          autofocus: autofocus,
        );

  final String link;

  @override
  Widget build(
    BuildContext context,
    bool selected,
    VoidCallback? onPressed, {
    fluent_ui.PaneDisplayMode? displayMode,
    bool showTextOnTop = true,
    bool? autofocus,
  }) {
    return Link(
      uri: Uri.parse(link),
      builder: (context, followLink) => super.build(
        context,
        selected,
        followLink,
        displayMode: displayMode,
        showTextOnTop: showTextOnTop,
        autofocus: autofocus,
      ),
    );
  }
}
