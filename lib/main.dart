import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const PasswordCheckerApp());
}

class PasswordCheckerApp extends StatelessWidget {
  const PasswordCheckerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Risk Checker',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const PasswordCheckerPage(),
    );
  }
}

class PasswordCheckerPage extends StatefulWidget {
  const PasswordCheckerPage({super.key});

  @override
  State<PasswordCheckerPage> createState() => _PasswordCheckerPageState();
}

class _PasswordCheckerPageState extends State<PasswordCheckerPage> {
  final TextEditingController _passwordController = TextEditingController();
  String _riskLevel = '';
  bool _loading = false;

  Future<void> _checkPassword() async {
    final password = _passwordController.text.trim();
    if (password.isEmpty) return;

    // ⛔️ НЕБЕЗОПАСНО: Сохраняем пароль
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("password", password); // <--- добавлено

    setState(() {
      _loading = true;
      _riskLevel = '';
    });

    try {
      final url = Uri.parse('http://127.0.0.1:5000/analyze');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'password': password}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        setState(() {
          _riskLevel = json['risk_level'];
        });
      } else {
        setState(() {
          _riskLevel = 'Ошибка: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _riskLevel = 'Ошибка подключения: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Проверка пароля')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Введите пароль',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _checkPassword,
              child:
                  _loading
                      ? const CircularProgressIndicator()
                      : const Text('Проверить'),
            ),
            const SizedBox(height: 24),
            Text(
              _riskLevel.isNotEmpty ? 'Уровень риска: $_riskLevel' : '',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color:
                    _riskLevel == 'HIGH'
                        ? Colors.red
                        : _riskLevel == 'MEDIUM'
                        ? Colors.orange
                        : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
