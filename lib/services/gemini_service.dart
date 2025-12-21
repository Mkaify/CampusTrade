import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import this

class GeminiService {
  // ⚠️ TRIPLE CHECK THIS KEY.
  // It should start with "AIza..."
  // Read the key safely
  // If the key is missing, this throws a helpful error instead of crashing silently
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";

  Future<String> generateDescription(String title, String price) async {
    if (_apiKey.isEmpty) {
      throw "API Key not found in .env file";
    }
    try {
      // 1. Use the Flash model (Faster & more reliable for free tier)
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
      );

      final prompt = 'Write a short, persuasive 2-sentence sales description for a student selling a "$title" for $price. Tone: casual peer-to-peer.';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      return response.text ?? "AI generated no text.";

    } catch (e) {
      // 2. Return the REAL error so we can see it on the phone screen
      throw "Error: $e";
    }
  }

  // New function for the Chat Screen
  Stream<String> chatWithGemini(List<Content> history, String message) async* {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
      );

      final chat = model.startChat(history: history);
      final content = Content.text(message);

      final response = await chat.sendMessage(content);
      yield response.text ?? "No response.";

    } catch (e) {
      throw "Chat Error: $e";
    }
  }
}