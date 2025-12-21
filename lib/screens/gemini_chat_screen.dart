import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import this

class GeminiChatScreen extends StatefulWidget {
  const GeminiChatScreen({super.key});

  @override
  State<GeminiChatScreen> createState() => _GeminiChatScreenState();
}

class _GeminiChatScreenState extends State<GeminiChatScreen> {
  // ⚠️ REPLACE WITH YOUR API KEY
  // Load the Environment variables
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? ""; // Secure key


  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = []; // Stores chat history
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    final text = _controller.text;
    if (text.isEmpty) return;

    // 1. Add User Message to UI
    setState(() {
      _messages.add({"role": "user", "text": text});
      _isLoading = true;
    });
    _controller.clear();

    try {
      // 2. Call Gemini
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
      final prompt = [Content.text(text)];
      final response = await model.generateContent(prompt);

      // 3. Add AI Response to UI
      setState(() {
        _messages.add({"role": "ai", "text": response.text ?? "I didn't understand that."});
      });
    } catch (e) {
      setState(() {
        _messages.add({"role": "ai", "text": "Error: Check your internet or API Key."});
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Assistant 🤖")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == "user";

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(color: isUser ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Ask Gemini something...",
                        border: OutlineInputBorder(),
                      ),
                    )),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}