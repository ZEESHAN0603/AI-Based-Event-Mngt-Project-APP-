import 'dart:convert';
import 'api_client.dart';

/// Represents a single turn in the conversation history sent to the backend.
class ChatHistoryItem {
  final String role; // "user" or "assistant"
  final String content;

  const ChatHistoryItem({required this.role, required this.content});

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

class ChatService {
  /// Send [message] to the Gemma AI backend and get a reply.
  /// [history] is the list of previous turns (oldest first) for multi-turn context.
  static Future<String> sendMessage(
    String message, {
    List<ChatHistoryItem> history = const [],
  }) async {
    final body = {
      'message': message,
      'history': history.map((h) => h.toJson()).toList(),
    };

    final response = await ApiClient.post('/ai/chat', body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['reply'] as String? ?? '';
    }

    // Surface a human-readable error
    try {
      final err = jsonDecode(response.body);
      throw Exception(err['detail'] ?? 'AI service error');
    } catch (_) {
      throw Exception('AI service unavailable (${response.statusCode})');
    }
  }
}
