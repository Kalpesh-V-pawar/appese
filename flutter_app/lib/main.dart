import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter MongoDB Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter MongoDB Integration'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textController = TextEditingController();
  List<dynamic> _entries = [];
  bool _isLoading = false;

  // Replace with your actual Vercel deployment URL
  final String baseUrl = 'https://appese-37xyi7ijd-kalpesh-vinod-pawars-projects.vercel.app';

  @override
  void initState() {
    super.initState();
    _fetchEntries();
  }

  Future<void> _fetchEntries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('$baseUrl/api/entries'));
      
      if (response.statusCode == 200) {
        setState(() {
          _entries = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        _showErrorSnackBar('Failed to fetch entries');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    }
  }

  Future<void> sendDataToMongoDB() async {
    if (_textController.text.isEmpty) {
      _showErrorSnackBar('Please enter some text');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/add-entry'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'text': _textController.text,
        }),
      );

      if (response.statusCode == 200) {
        // Clear text field
        _textController.clear();
        
        // Refresh entries
        await _fetchEntries();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Entry saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showErrorSnackBar('Failed to save entry');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchEntries,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter text',
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: sendDataToMongoDB,
                ),
              ),
              onSubmitted: (_) => sendDataToMongoDB(),
            ),
          ),
          _isLoading
              ? CircularProgressIndicator()
              : Expanded(
                  child: ListView.builder(
                    itemCount: _entries.length,
                    itemBuilder: (context, index) {
                      final entry = _entries[index];
                      return ListTile(
                        title: Text(entry['text'] ?? ''),
                        subtitle: Text(
                          DateTime.parse(entry['createdAt']).toLocal().toString(),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
