import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/event_provider.dart';
import '../../services/recommendation_service.dart';
import '../../models/recommendation.dart';

class AIChatbotScreen extends StatefulWidget {
  const AIChatbotScreen({super.key});

  @override
  State<AIChatbotScreen> createState() => _AIChatbotScreenState();
}

class _AIChatbotScreenState extends State<AIChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'role': 'bot',
      'text': 'Hello! I am Nanban, your AI Assistant. I can help you with your event planning. If you have an event selected, I can recommend the best vendors for you!',
    },
  ];
  bool _isRecommending = false;

  Future<void> _getAiRecommendations() async {
    final eventId = context.read<EventProvider>().selectedEventId;
    if (eventId == null) {
      _addBotMessage("Please select an event from your dashboard first so I can provide relevant recommendations.");
      return;
    }

    setState(() => _isRecommending = true);
    _addBotMessage("Analyzing vendors based on your event's budget, location, and date...");

    try {
      final result = await RecommendationService.getRecommendations(eventId);
      if (result['statusCode'] == 200) {
        final List<dynamic> recs = result['recommendations'];
        if (recs.isEmpty) {
          _addBotMessage("I couldn't find any approved vendors that match your event's criteria at the moment.");
        } else {
          final items = recs.map((j) => RecommendationItem.fromJson(j)).toList();
          String response = "Based on my analysis, here are the top matches for you:\n\n";
          for (var i = 0; i < items.take(3).length; i++) {
            final item = items[i];
            response += "${i + 1}. ${item.businessName} (Score: ${item.score})\n   Reason: ${item.reason}\n\n";
          }
          _addBotMessage(response);
        }
      } else {
        _addBotMessage("I encountered an error while fetching recommendations. Please try again later.");
      }
    } catch (e) {
      _addBotMessage("I'm having trouble connecting to my knowledge base. Check your connection!");
    } finally {
      if (mounted) setState(() => _isRecommending = false);
    }
  }

  void _addBotMessage(String text) {
    if (mounted) {
      setState(() {
        _messages.add({'role': 'bot', 'text': text});
      });
    }
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;

    final userMessage = _messageController.text;
    setState(() {
      _messages.add({'role': 'user', 'text': userMessage});
      _messageController.clear();
    });

    // Simple response logic
    if (userMessage.toLowerCase().contains('recommend') || userMessage.toLowerCase().contains('vendor')) {
      _getAiRecommendations();
    } else {
      _addBotMessage("That's interesting! I'm still learning how to chat, but I can certainly help with 'vendor recommendations' if you ask!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Nanban (AI)'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isBot = message['role'] == 'bot';
                return Align(
                  alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isBot ? Colors.grey.withOpacity(0.1) : Theme.of(context).primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message['text'],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isRecommending)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
          _buildInputArea(context),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type "recommend vendors"...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _isRecommending ? null : _getAiRecommendations,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Get AI Recommendations'),
          ),
        ],
      ),
    );
  }
}
