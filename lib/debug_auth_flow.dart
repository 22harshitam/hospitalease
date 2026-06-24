import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api/api_config.dart';

class DebugAuthFlowScreen extends StatefulWidget {
  const DebugAuthFlowScreen({super.key});

  @override
  State<DebugAuthFlowScreen> createState() => _DebugAuthFlowScreenState();
}

class _DebugAuthFlowScreenState extends State<DebugAuthFlowScreen> {
  String _debugLog = '';
  bool _isLoading = false;

  void _addLog(String message) {
    setState(() {
      _debugLog += '${DateTime.now().toString().substring(11, 19)}: $message\n';
    });
  }

  Future<void> _testDirectHttpCall() async {
    setState(() {
      _isLoading = true;
      _debugLog = '';
    });

    _addLog('Starting direct HTTP test...');
    
    try {
      _addLog('Testing health endpoint...');
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/health'),
      ).timeout(const Duration(seconds: 10));
      
      _addLog('Health check - Status: ${response.statusCode}');
      _addLog('Health check - Response: ${response.body}');
      
      if (response.statusCode == 200) {
        _addLog('✅ Basic HTTP connection working!');
        
        // Test patient registration
        _addLog('Testing patient registration...');
        
        final registerResponse = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/api/auth/patient/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': 'Debug User',
            'email': 'debug@test.com',
            'password': 'password123',
            'phone': '9876543210',
            'age': '30',
          }),
        ).timeout(const Duration(seconds: 10));
        
        _addLog('Registration - Status: ${registerResponse.statusCode}');
        _addLog('Registration - Response: ${registerResponse.body}');
        
        if (registerResponse.statusCode == 201) {
          _addLog('✅ Patient registration working!');
        } else {
          _addLog('❌ Patient registration failed');
        }
      } else {
        _addLog('❌ Basic HTTP connection failed');
      }
      
    } catch (e) {
      _addLog('❌ Error: $e');
      _addLog('Error type: ${e.runtimeType}');
      
      if (e.toString().contains('Connection refused')) {
        _addLog('💡 Hint: Backend server might not be running');
      } else if (e.toString().contains('timeout')) {
        _addLog('💡 Hint: Network timeout - check firewall/antivirus');
      } else if (e.toString().contains('Host')) {
        _addLog('💡 Hint: DNS/host resolution issue');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testApiService() async {
    setState(() {
      _isLoading = true;
      _debugLog = '';
    });

    _addLog('Testing API Service integration...');
    
    try {
      // Import and test the actual API service
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/patient/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': 'API Test User',
          'email': 'apitest@test.com',
          'password': 'password123',
          'phone': '9876543211',
          'age': '25',
        }),
      ).timeout(const Duration(seconds: 10));
      
      _addLog('API Service - Status: ${response.statusCode}');
      _addLog('API Service - Response: ${response.body}');
      
      if (response.statusCode == 201) {
        _addLog('✅ API Service integration working!');
      } else {
        _addLog('❌ API Service integration failed');
      }
      
    } catch (e) {
      _addLog('❌ API Service Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearLog() {
    setState(() {
      _debugLog = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Auth Flow'),
        actions: [
          IconButton(
            onPressed: _clearLog,
            icon: const Icon(Icons.clear),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testDirectHttpCall,
                    child: _isLoading 
                      ? const CircularProgressIndicator()
                      : const Text('Test Direct HTTP'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testApiService,
                    child: _isLoading 
                      ? const CircularProgressIndicator()
                      : const Text('Test API Service'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black87,
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _debugLog.isEmpty ? 'Press a button to start debugging...' : _debugLog,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.green,
                      fontSize: 12,
                    ),
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
