import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

//theme colour app
class AppColors {
  //so that takya retype colour code berulang kali
  static const Color colorPrimary = Color(0xFFF59E0B); // Warm Amber Yellow
  static const Color colorOnPrimary = Color(0xFF1F2937); // Dark Charcoal Text
  static const Color colorSecondary = Color(0xFFD97706); // Deep Gold Accent
  static const Color colorBackground = Color(0xFFFFFBEB); // Soft Cream Yellow
}

class MyApp extends StatelessWidget {
  //stateless widget sebab theme settings do not change masa user interact with the app
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //sorok debug ribbon
      title: 'AeroFee Baggage Estimator',
      theme: ThemeData(
        primaryColor: AppColors.colorPrimary,
        scaffoldBackgroundColor: AppColors.colorBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.colorPrimary,
          primary: AppColors.colorPrimary,
          onPrimary: AppColors.colorOnPrimary,
          secondary: AppColors.colorSecondary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.colorPrimary,
          foregroundColor: AppColors.colorOnPrimary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.colorPrimary,
            foregroundColor: AppColors.colorOnPrimary,
          ),
        ),
      ),
      home: const MainScreen(title: 'AeroFee Baggage Estimator'),
    );
  }
}

//navigation bar (home & about page)
class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.title});
  final String title;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; //tracks active tab (0 = home, 1 = about). function letak _ sebab nak buat dia private to this file

  final List<Widget> _screens = const [
    //list of screens for navigation bar
    HomePage(),
    AboutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //provied basic structure app
      appBar: AppBar(
        //untuk icon luggage and title
        leading: const Icon(Icons.luggage),
        title: Text(widget.title),
      ),
      body: _screens[_currentIndex], //display screen sekarang based on current index
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.colorSecondary,
        onTap: (int index) {
          //bila user tap on bottom navigation bar, update current index and rebuild UI
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
        ],
      ),
    );
  }
}

// 3. HOME PAGE
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController weightController = TextEditingController();
  //connects dengan TextField so code can read apa user type

  String selectedClass = 'Economy';
  String errorMessage = '';

  double excessWeight = 0.0;
  double ratePerKg = 15.0;
  double excessCharge = 0.0;
  double totalPayable = 0.0;
  bool isCalculated = false;

  @override
  void dispose() {
    //untuk prevent memory leaks, dispose controller bila widget ni takde lagi
    weightController.dispose();
    super.dispose();
  }

  void calculateBaggageFee() {
    final double? weight = double.tryParse(weightController.text.trim());
    //convert user text into decimal number, kalau tak boleh convert, return null

    // TRIGGER 1: Empty box or letters (like "abc")
    if (weight == null) {
      setState(() {
        errorMessage = 'Please enter a valid baggage weight.';
        isCalculated = false;
      });
      return;
    }

    // TRIGGER 2: Negative numbers (like "-5")
    if (weight < 0) {
      setState(() {
        errorMessage = 'Baggage weight cannot be negative.';
        isCalculated = false;
      });
      return;
    }

    // Automatic allowance and rate based on Ticket Class
    double allowance;
    double autoRate;

    if (selectedClass == 'Economy') {
      allowance = 20.0;
      autoRate = 15.0;
    } else {
      allowance = 40.0;
      autoRate = 12.0;
    }

    //calculate excess weight and charges
    double calcExcess = weight - allowance;
    if (calcExcess < 0) {
      calcExcess = 0.0;
    }

    //tambah service tax 8% to total payable
    final double calcCharge = calcExcess * autoRate;
    final double calcTotal = calcCharge + (0.08 * calcCharge); // + 8% tax

    setState(() {
      //update variables pastu rebuild UI
      errorMessage = '';
      ratePerKg = autoRate;
      excessWeight = calcExcess;
      excessCharge = calcCharge;
      totalPayable = calcTotal;
      isCalculated = true;
    });
  }

  void resetForm() {
    //reset semua variables to default values
    weightController.clear();
    setState(() {
      selectedClass = 'Economy';
      errorMessage = '';
      excessWeight = 0.0;
      ratePerKg = 15.0;
      excessCharge = 0.0;
      totalPayable = 0.0;
      isCalculated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      //makes the page controllable when keyboard appears, so user can scroll to see all content
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, //makes the children widgets stretch to fill the width of the column
        children: [
          const Text(
            'Enter your checked baggage weight and select your ticket class to calculate excess baggage fees.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),

          // Input 1: Baggage Weight
          TextField(
            controller: weightController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ), //mobile number keyboard with decimal point
            decoration: const InputDecoration(
              labelText: 'Checked Baggage Weight (kg)',
              hintText: 'e.g. 25',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // Input 2: Ticket Class
          const Text(
            'Select Ticket Class:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            //display option economy ngan business class option
            initialValue: selectedClass,
            isExpanded: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            items: const [
              DropdownMenuItem(
                value: 'Economy',
                child: Text('Economy (Free: 20 kg | Rate: RM 15/kg)'),
              ),
              DropdownMenuItem(
                value: 'Business',
                child: Text('Business (Free: 40 kg | Rate: RM 12/kg)'),
              ),
            ],
            onChanged: (String? newValue) {
              //update selectedClass bila user pilih option baru
              if (newValue != null) {
                setState(() {
                  selectedClass = newValue;
                });
              }
            },
          ),
          const SizedBox(height: 10),

          const Text(
            '* Total payable includes 8% service tax.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 16),

          // Error Message when user input invalid baggage weight (abc, negative number, etc))
          if (errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                errorMessage,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          // Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: calculateBaggageFee,
                  child: const Text('Calculate'),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(onPressed: resetForm, child: const Text('Reset')),
            ],
          ),
          const SizedBox(height: 24),

          // Results Section
          if (isCalculated) ...[
            const Divider(thickness: 1.5),
            const SizedBox(height: 8),
            const Text(
              'Calculation Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Applied Rate: RM ${ratePerKg.toStringAsFixed(2)} / kg'),
            const SizedBox(height: 6),
            Text('Excess Weight: ${excessWeight.toStringAsFixed(2)} kg'),
            const SizedBox(height: 6),
            Text('Excess Charge: RM ${excessCharge.toStringAsFixed(2)}'),
            const SizedBox(height: 10),
            Text(
              'Total Payable (incl. 8% tax): RM ${totalPayable.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.colorSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// 4. ABOUT PAGE
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static final Uri githubUri = Uri.parse(
    //convert string to Uri object, so can use launchUrl function
    'https://github.com/ecachuu/ITT550_IndividualAssignment_flutter',
  );

  Future<void> _openGitHub() async {
    await launchUrl(githubUri, mode: LaunchMode.externalApplication); // tells os to open the link in external browser instead of in-app webview
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'asset/icon/icon.png', //untuk app icon
              width: 90,
              height: 90,
            ),
            const SizedBox(height: 16),
            const Text(
              'AeroFee Baggage Estimator',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),
            const Text('Name: NUR AISYAH BINTI SUHAIMI'),
            const SizedBox(height: 4),
            const Text('Matric No: 2024211216'),
            const SizedBox(height: 4),
            const Text('Course: ICT602'),
            const SizedBox(height: 20),

            ElevatedButton(
              // button to open GitHub repo
              onPressed: _openGitHub,
              child: const Text('Open GitHub Repository'),
            ),
            const SizedBox(height: 8),

            InkWell(
              //makes the text clickable, so user can tap on the link to open GitHub repo
              onTap: _openGitHub,
              child: Text(
                githubUri.toString(),
                style: const TextStyle(
                  color: AppColors.colorSecondary,
                  decoration: TextDecoration.underline,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '© 2026 AeroFee Baggage Estimator. All Rights Reserved.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
