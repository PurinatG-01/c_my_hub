import 'package:flutter/material.dart';

import 'service/health_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  HealthService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final healthService = HealthService();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: FutureBuilder<int>(
              future: healthService.getSteps(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return ErrorWidget(snapshot.error ?? "Error occured");
                }
                if (snapshot.hasData) {
                  final steps = snapshot.data ?? [];
                  debugPrint("Steps: $steps");
                  return SingleChildScrollView(
                      child: Column(
                    children: List.filled(
                        30,
                        DataCard(
                            icon: Icons.nordic_walking_rounded,
                            label: 'Steps',
                            value: steps.toString())),
                  ));
                }
                return const CircularProgressIndicator();
              })), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class DataCard extends StatelessWidget {
  const DataCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      color: Colors.white,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(
            "$label : $value",
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ]),
      ),
    );
  }
}
