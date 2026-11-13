import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class AppColors{
  static const Color colorPrimary = Color(0xFF6200EE);
  static const Color colorOnPrimary = Color(0xFF03DAC6);
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab5',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.colorPrimary,
        ).copyWith(
          primary: AppColors.colorPrimary,
          onPrimary: AppColors.colorOnPrimary,
        ),
      ),
      home: const MyHomePage(
        title: 'Adding 2 Numbers',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController num1Controller =
      TextEditingController();

  final TextEditingController num2Controller =
      TextEditingController();

  String result = '';

  @override
  void dispose() {
    num1Controller.dispose();
    num2Controller.dispose();
    super.dispose();
  }

  void addNumbers() {
    // tryParse() returns null instead of throwing (see Lab 4)

    final int? a =
        int.tryParse(num1Controller.text.trim());

    final int? b =
        int.tryParse(num2Controller.text.trim());

    if (a == null || b == null) {
      setState(
        () => result =
            'Please enter two whole numbers.',
      );
      return;
    }

    setState(
      () => result = 'Result: ${a + b}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 60,
          ),
          child: Column(
            mainAxisAlignment: .center,
            children: [
              TextField(
                controller: num1Controller,
                keyboardType:
                    TextInputType.number,
              ),

              const SizedBox(
                height: 24,
              ),

              TextField(
                controller: num2Controller,
                keyboardType:
                    TextInputType.number,
              ),

              const SizedBox(
                height: 32,
              ),

              FilledButton(
                onPressed: addNumbers,
                child: const Text('ADD'),
              ),

              const SizedBox(
                height: 32,
              ),

              Text(result),
            ],
          ),
        ),
      ),
    );
  }
}