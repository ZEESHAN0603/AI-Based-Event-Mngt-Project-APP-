import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/synora_header.dart';

class VendorMessagesScreen extends StatelessWidget {
  const VendorMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> chats = [
      {'name': 'Rahul Sharma', 'lastMessage': 'Is Dec 22nd available?', 'time': '10:30 AM', 'phone': '+91 98765 43210'},
      {'name': 'Priya Singh', 'lastMessage': 'Thanks for the quote!', 'time': '09:15 AM', 'phone': '+91 87654 32109'},
      {'name': 'Amit Patel', 'lastMessage': 'Can we confirm the booking?', 'time': 'Yesterday', 'phone': '+91 76543 21098'},
      {'name': 'Sangeeta Roy', 'lastMessage': 'I loved the portfolio work!', 'time': '2 days ago', 'phone': '+91 65432 10987'},
    ];

    return Scaffold(
      body: Column(
        children: [
          const SynoraHeader(
            title: 'Messages',
            subtitle: 'Chat with your clients',
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: chats.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final chat = chats[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(chat['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(chat['lastMessage']!, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Text(chat['time']!, style: const TextStyle(fontSize: 12)),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(name: chat['name']!, phone: chat['phone']!)));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String name;
  final String phone;
  final bool isNew; // Logic for "If new customer from booking -> create new chat"
  
  const ChatScreen({super.key, required this.name, required this.phone, this.isNew = false});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  late List<Map<String, dynamic>> _messages;

  @override
  void initState() {
    super.initState();
    _messages = _getMessagesForUser(widget.name, widget.isNew);
  }

  List<Map<String, dynamic>> _getMessagesForUser(String name, bool isNew) {
    if (isNew) {
      return [
        {'text': 'Hi! I saw your profile on Synora and want to book you for my event.', 'isMe': false, 'time': 'Just now'},
        {'text': 'Hello! Thanks for reaching out. Which event are you planning?', 'isMe': true, 'time': 'Just now'},
      ];
    }

    // Unique conversations for existing users
    switch (name) {
      case 'Rahul Sharma':
        return [
          {'text': 'Hello! Is Dec 22nd available for a wedding?', 'isMe': false, 'time': '10:00 AM'},
          {'text': 'Hi Rahul! Let me check the calendar.', 'isMe': true, 'time': '10:01 AM'},
          {'text': 'Yes, we are currently free on that date.', 'isMe': true, 'time': '10:02 AM'},
          {'text': 'Great! What is your pricing for 500 guests?', 'isMe': false, 'time': '10:05 AM'},
          {'text': 'Our wedding package starts from ₹1,50,000.', 'isMe': true, 'time': '10:06 AM'},
          {'text': 'Does that include decoration?', 'isMe': false, 'time': '10:10 AM'},
          {'text': 'Yes, basic theme decoration is included.', 'isMe': true, 'time': '10:11 AM'},
          {'text': 'Can we schedule a call to discuss further?', 'isMe': false, 'time': '10:15 AM'},
          {'text': 'Sure, I am available now or after 4 PM.', 'isMe': true, 'time': '10:16 AM'},
          {'text': 'I will call you in 5 minutes.', 'isMe': false, 'time': '10:20 AM'},
        ];
      case 'Priya Singh':
        return [
          {'text': 'Hi, I received the estimate for the birthday party.', 'isMe': false, 'time': 'Yesterday'},
          {'text': 'Hi Priya! Does everything look okay?', 'isMe': true, 'time': 'Yesterday'},
          {'text': 'Yes, but can we add more Jain options?', 'isMe': false, 'time': 'Yesterday'},
          {'text': 'Absolutely, we have a specialized Jain menu.', 'isMe': true, 'time': 'Yesterday'},
          {'text': 'Great. What about the seating arrangement?', 'isMe': false, 'time': 'Yesterday'},
          {'text': 'We can provide round tables with satin covers.', 'isMe': true, 'time': '10:11 AM'},
          {'text': 'Can you send some photos of past birthday events?', 'isMe': false, 'time': '10:15 AM'},
          {'text': 'Sent! Check your email.', 'isMe': true, 'time': '10:16 AM'},
          {'text': 'Wow, they look amazing!', 'isMe': false, 'time': '10:20 AM'},
          {'text': 'Thanks for the quote!', 'isMe': false, 'time': '09:15 AM'},
        ];
      case 'Amit Patel':
        return [
          {'text': 'Hey, regarding the corporate event on 28th...', 'isMe': false, 'time': 'Monday'},
          {'text': 'Yes Amit, I have blocked the dates.', 'isMe': true, 'time': 'Monday'},
          {'text': 'Need the invoice for advance payment.', 'isMe': false, 'time': 'Tuesday'},
          {'text': 'Generating it now. Will send by evening.', 'isMe': true, 'time': 'Tuesday'},
          {'text': 'Perfect. Is VAT included?', 'isMe': false, 'time': 'Wednesday'},
          {'text': 'Yes, 5% VAT is included in the base price.', 'isMe': true, 'time': 'Wednesday'},
          {'text': 'Also, we need a separate counter for coffee.', 'isMe': false, 'time': 'Thursday'},
          {'text': 'Noted. Added to the service list.', 'isMe': true, 'time': 'Thursday'},
          {'text': 'Thanks for the quick response.', 'isMe': false, 'time': 'Friday'},
          {'text': 'Can we confirm the booking?', 'isMe': false, 'time': 'Yesterday'},
        ];
      default:
        return List.generate(10, (index) => {
          'text': index % 2 == 0 ? 'Customer message $index' : 'Vendor reply $index',
          'isMe': index % 2 != 0,
          'time': '12:${index.toString().padLeft(2, "0")} PM'
        });
    }
  }

  void _handleSend() {
    if (_controller.text.isEmpty) return;
    
    final text = _controller.text;
    final now = DateTime.now();
    final timeStr = '${now.hour}:${now.minute.toString().padLeft(2, "0")}';

    setState(() {
      _messages.add({'text': text, 'isMe': true, 'time': timeStr});
      _controller.clear();
    });

    if (text.toLowerCase().contains('dec 22nd') || text.toLowerCase().contains('22nd')) {
      _showAISuggestion("Date detected: Dec 22nd. Available! Update calendar?");
    } else if (text.toLowerCase().contains('confirm') || text.toLowerCase().contains('book')) {
      _showAISuggestion("Booking intent detected. Update calendar to 'Booked'?");
    }
  }

  void _showAISuggestion(String suggestion) {
    Future.delayed(const Duration(milliseconds: 500), () {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(suggestion),
          action: SnackBarAction(label: 'Update', onPressed: () {}),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
    });
  }

  Future<void> _handleCall() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Customer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Connecting to ${widget.name} at ${widget.phone}...'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.phone));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone number copied to clipboard')));
            },
            child: const Text('Copy Number'),
          ),
          ElevatedButton(
            onPressed: () async {
              final Uri launchUri = Uri(scheme: 'tel', path: widget.phone);
              if (await canLaunchUrl(launchUri)) {
                await launchUrl(launchUri);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white),
            child: const Text('Open Dialer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.name, style: const TextStyle(fontSize: 16)),
            Text(widget.phone, style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.call), onPressed: _handleCall),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final bool isMe = msg['isMe'];
                return Row(
                  mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    if (!isMe) const CircleAvatar(radius: 12, child: Icon(Icons.person, size: 12)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? Theme.of(context).primaryColor.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isMe ? 16 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg['text'],
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              msg['time'],
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: 'Type a message...', border: InputBorder.none),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          IconButton(icon: const Icon(Icons.send), onPressed: _handleSend),
        ],
      ),
    );
  }
}
