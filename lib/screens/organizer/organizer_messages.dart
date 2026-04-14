import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/design_system.dart';
import '../../widgets/synora_header.dart';

class OrganizerMessagesScreen extends StatelessWidget {
  const OrganizerMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> vendors = [
      {'name': 'Elite Catering', 'lastMessage': 'The menu is finalized.', 'time': '10:30 AM', 'phone': '+91 98765 43210'},
      {'name': 'Royal Venue', 'lastMessage': 'Is the guest list ready?', 'time': '09:15 AM', 'phone': '+91 87654 32109'},
      {'name': 'Sparkle Decor', 'lastMessage': 'Theme selection is pending.', 'time': 'Yesterday', 'phone': '+91 76543 21098'},
      {'name': 'Click Photography', 'lastMessage': 'Sent the sample álbum.', 'time': '2 days ago', 'phone': '+91 65432 10987'},
      {'name': 'Music Masters DJ', 'lastMessage': 'Song list received, thanks!', 'time': '3 days ago', 'phone': '+91 54321 09876'},
    ];

    return Scaffold(
      body: Column(
        children: [
          const SynoraHeader(
            title: 'Messages',
            subtitle: 'Chat with your event vendors',
          ),
          Expanded(
            child: AnimationLimiter(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                itemCount: vendors.length,
                itemBuilder: (context, index) {
                  final vendor = vendors[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: FadeInAnimation(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: AnimatedPressable(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => OrganizerChatScreen(name: vendor['name']!, phone: vendor['phone']!)));
                          },
                          child: GlassCard(
                            padding: const EdgeInsets.all(12),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: SynoraAvatar(name: vendor['name']),
                              title: Text(vendor['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              subtitle: Text(
                                vendor['lastMessage']!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 13),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(vendor['time']!, style: const TextStyle(fontSize: 10)),
                                  const SizedBox(height: 4),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrganizerChatScreen extends StatefulWidget {
  final String name;
  final String phone;
  const OrganizerChatScreen({super.key, required this.name, required this.phone});

  @override
  State<OrganizerChatScreen> createState() => _OrganizerChatScreenState();
}

class _OrganizerChatScreenState extends State<OrganizerChatScreen> {
  final TextEditingController _controller = TextEditingController();
  late List<Map<String, dynamic>> _messages;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messages = _getMessagesForVendor(widget.name);
  }

  List<Map<String, dynamic>> _getMessagesForVendor(String name) {
    switch (name) {
      case 'Elite Catering':
        return [
          {'text': 'Hi, I saw your wedding package.', 'isMe': true, 'time': '10:00 AM'},
          {'text': 'Hello! Yes, would you like to customize the menu?', 'isMe': false, 'time': '10:01 AM'},
          {'text': 'Yes, we need more vegetarian options.', 'isMe': true, 'time': '10:02 AM'},
          {'text': 'Noted. We can add a specialized North Indian counter.', 'isMe': false, 'time': '10:05 AM'},
          {'text': 'That sounds great. What is the additional cost?', 'isMe': true, 'time': '10:06 AM'},
          {'text': 'It will be ₹200 extra per plate.', 'isMe': false, 'time': '10:10 AM'},
          {'text': 'Okay, I will discuss this with my family.', 'isMe': true, 'time': '10:11 AM'},
          {'text': 'Sure, take your time. We are here to help.', 'isMe': false, 'time': '10:15 AM'},
          {'text': 'Also, do you provide breakfast service?', 'isMe': true, 'time': '10:16 AM'},
          {'text': 'Yes, we have a complete 3-meal wedding package.', 'isMe': false, 'time': '10:20 AM'},
        ];
      case 'Royal Venue':
        return [
          {'text': 'Is the grand hall available for Jan 15th?', 'isMe': true, 'time': 'Yesterday'},
          {'text': 'Let me check... Yes, it is free!', 'isMe': false, 'time': 'Yesterday'},
          {'text': 'What is the capacity for a round-table setup?', 'isMe': true, 'time': 'Yesterday'},
          {'text': 'We can comfortably seat 400 guests.', 'isMe': false, 'time': 'Yesterday'},
          {'text': 'Does it include the valet parking?', 'isMe': true, 'time': 'Yesterday'},
          {'text': 'Yes, we have space for 100 cars with valet.', 'isMe': false, 'time': 'Yesterday'},
          {'text': 'Perfect. Can we visit today for a walkthrough?', 'isMe': true, 'time': 'Yesterday'},
          {'text': 'Sure, I am available until 6 PM.', 'isMe': false, 'time': 'Yesterday'},
          {'text': 'Great, see you then.', 'isMe': true, 'time': 'Yesterday'},
          {'text': 'Is the guest list ready?', 'isMe': false, 'time': '09:15 AM'},
        ];
      default:
        return List.generate(10, (index) => {
          'text': index % 2 == 0 ? 'Organizer message help $index' : 'Vendor response info $index',
          'isMe': index % 2 == 0,
          'time': '11:${index.toString().padLeft(2, "0")} AM'
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
      _isTyping = true;
    });
    
    // Mock response after typing
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add({
            'text': 'Thank you for the update! We are working on it.',
            'isMe': false,
            'time': '${now.hour}:${(now.minute + 2).toString().padLeft(2, "0")}'
          });
        });
      }
    });
  }

  Future<void> _handleCall() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Vendor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vendor: ${widget.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Phone: ${widget.phone}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.phone));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone number copied to clipboard')));
            },
            child: const Text('Copy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final Uri launchUri = Uri(scheme: 'tel', path: widget.phone);
              if (await canLaunchUrl(launchUri)) {
                await launchUrl(launchUri);
              }
              Navigator.pop(context);
            },
            child: const Text('Call Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
          IconButton(icon: const Icon(Icons.call_outlined), onPressed: _handleCall),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _buildTypingIndicator();
                }
                final msg = _messages[index];
                return _buildChatBubble(msg);
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          SynoraAvatar(name: widget.name, size: 24),
          const SizedBox(width: 8),
          const GlassCard(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TypingIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> msg) {
    final bool isMe = msg['isMe'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[
                SynoraAvatar(name: widget.name, size: 28),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: GlassCard(
                  blur: isMe ? 0 : 10,
                  opacity: isMe ? 1.0 : 0.1,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isMe ? 20 : 0),
                    bottomRight: Radius.circular(isMe ? 0 : 20),
                  ),
                  child: Text(
                    msg['text'],
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              if (isMe) const SizedBox(width: 28), // Space for alignment 
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 4, left: isMe ? 0 : 36, right: isMe ? 0 : 0),
            child: Text(
              msg['time'],
              style: TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GlassCard(
          padding: const EdgeInsets.fromLTRB(20, 4, 8, 4),
          borderRadius: BorderRadius.circular(32),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Type message...',
                    border: InputBorder.none,
                    hintStyle: const TextStyle(),
                  ),
                ),
              ),
              AnimatedPressable(
                onTap: _handleSend,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_rounded, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
