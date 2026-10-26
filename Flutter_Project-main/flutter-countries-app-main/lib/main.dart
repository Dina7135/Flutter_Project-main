import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const CountriesApp());
}

class CountriesApp extends StatelessWidget {
  const CountriesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Countries App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // משתנה שישמור את מה שהמשתמש מקליד בתיבת החיפוש
  final TextEditingController _countryController = TextEditingController();

  Map<String, dynamic>? _countryData; // משתנה שישמור את נתוני המדינה שנמצאה
  bool _isLoading = false; // משתנה שיסמן האם אנחנו ממתינים לתשובה מהרשת

  // פונקציה שמקבלת שם מדינה ומביאה עליה מידע מהאינטרנט
  Future<void> fetchCountryData(String countryName) async {
    // 1. מעבירים את האפליקציה למצב טעינה ומנקים מידע קודם
    setState(() {
      _isLoading = true;
      _countryData = null;
    });

    final String url = 'https://restcountries.com/v3.1/name/$countryName';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // 2. שומרים את הנתונים ומכבים את מצב הטעינה
        setState(() {
          _countryData = data[0];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print('המדינה לא נמצאה');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print('שגיאה בתקשורת: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('חיפוש מידע על מדינות'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // תיבת הטקסט להקלדת שם המדינה
            TextField(
              controller: _countryController,
              decoration: const InputDecoration(
                labelText: 'הקלידי שם מדינה באנגלית (למשל: Canada)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),

            // כפתור החיפוש
            ElevatedButton(
              onPressed: () {
                if (_countryController.text.isNotEmpty) {
                  fetchCountryData(_countryController.text);
                  _countryController.clear(); // ניקוי התיבה
                }
              },
              child: const Text('חפשי מדינה'),
            ),
            const SizedBox(height: 24),

            // הצגת התוצאות
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_countryData != null)
              // שדרוג: עטיפת הכרטיס ב-Directionality כדי לאלץ כיוון מימין לשמאל (RTL)
              Directionality(
                textDirection: TextDirection.rtl,
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // שורת שם מדינה ודגל
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'שם המדינה:',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            // שדרוג: עטיפת הטקסט באנגלית ב-Directionality משלו כדי שלא יתהפך פנימית
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                '${_countryData!['name']['common']} ${_countryData!['flag'] ?? ""}',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const Divider(),

                        // שורת עיר בירה
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('עיר בירה:',
                                style: TextStyle(fontSize: 16)),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                '${_countryData!['capital'] != null ? _countryData!['capital'][0] : 'אין'}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // שורת יבשת
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('יבשת:', style: TextStyle(fontSize: 16)),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                '${_countryData!['region']}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // שורת אוכלוסייה
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('אוכלוסייה:',
                                style: TextStyle(fontSize: 16)),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                '${_countryData!['population']}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              const Text(
                'הקלידי שם מדינה באנגלית ולחצי על חפשי',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
