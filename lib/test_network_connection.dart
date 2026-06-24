import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NetworkTestScreen extends StatefulWidget {
  const NetworkTestScreen({super.key});

  @override
  State<NetworkTestScreen> createState() => _NetworkTestScreenState();
}

class _NetworkTestScreenState extends State<NetworkTestScreen> {
  String _testResult = '';
  bool _isLoading = false;

  Future<void> _testNetworkConnection() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Testing network connection...';
    });

    try {
      // Test 1: Basic health check
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/health'),
      ).timeout(const Duration(seconds: 10));

      setState(() {
        _testResult = '''
✅ Network Test Results:

Test 1 - Health Check:
Status Code: ${response.statusCode}
Response: ${response.body}

✅ Basic network connection is working!
''';
      });

      // Test 2: Patient registration
      try {
        final registerResponse = await http.post(
          Uri.parse('http://127.0.0.1:8000/api/auth/patient/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': 'Network Test User',
            'email': 'test@network.com',
            'password': 'password123',
            'phone': '9876543210',
            'age': '30',
          }),
        ).timeout(const Duration(seconds: 10));

        setState(() {
          _testResult += '''
          
Test 2 - Patient Registration:
Status Code: ${registerResponse.statusCode}
Response: ${registerResponse.body}

✅ Patient registration endpoint is working!
''';
        });
      } catch (e) {
        setState(() {
          _testResult += '''
          
Test 2 - Patient Registration:
❌ Error: $e

❌ Patient registration failed!
''';
        });
      }

    } catch (e) {
      setState(() {
        _testResult = '''
❌ Network Test Failed:
Error: $e

❌ Cannot connect to backend server!
''';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testNetworkConnection,
              child: _isLoading 
                ? const CircularProgressIndicator()
                : const Text('Test Network Connection'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _testResult.isEmpty ? 'Press the button to test network connection' : _testResult,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
