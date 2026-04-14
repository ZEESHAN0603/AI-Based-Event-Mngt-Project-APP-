import 'package:flutter/material.dart';

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
      'text': 'Hello! I am Nanban, your AI Assistant. How can I help you with your event planning today? You can ask about budget advice or vendor suggestions.',
    },
  ];

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;

    final userMessage = _messageController.text;
    setState(() {
      _messages.add({'role': 'user', 'text': userMessage});
      _messageController.clear();
    });

    _generateResponse(userMessage);
  }

  void _generateResponse(String userMessage) {
    String response = '';
    final lowerMsg = userMessage.toLowerCase();

    if (lowerMsg.contains('budget') || lowerMsg.contains('advice')) {
      response = 'For an event with your scale, I recommend allocating 40% to Venue, 30% to Catering, 15% to Decor, and 15% for miscellaneous. Check your Budget Overview for the current utilization!';
    } else if (lowerMsg.contains('vendor') || lowerMsg.contains('suggestion')) {
      response = 'Based on our top-rated partners, I suggest looking into "Royal Plaza Venue" for your location. They have great reviews for your event type.';
    } else if (lowerMsg.contains('hello') || lowerMsg.contains('hi')) {
      response = 'Hi there! Ready to make your event spectacular? Ask me anything about your budget or vendors.';
    } else {
      response = "That's interesting! Tell me more, or ask for \"budget advice\" or \"vendor suggestions\".";
    }

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _messages.add({'role': 'bot', 'text': response});
        });
      }
    });
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
                      color: isBot ? Colors.white.withValues(alpha: 0.12) : Theme.of(context).primaryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: Radius.circular(isBot ? 0 : 12),
                        bottomRight: Radius.circular(isBot ? 12 : 0),
                      ),
                      border: isBot ? Border.all(color: Colors.white.withValues(alpha: 0.1)) : null,
                    ),
                    child: Text(
                      message['text'],
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
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
        color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.8),
        border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: IconButton(
              icon: const Icon(Icons.send, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
