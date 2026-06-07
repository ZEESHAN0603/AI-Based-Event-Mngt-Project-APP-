import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/chat_service.dart';
import '../../widgets/synora_header.dart';

// ---------------------------------------------------------------------------
// Data Model
// ---------------------------------------------------------------------------

class _ChatMessage {
  final String role; // "user" | "assistant"
  final String text;
  final DateTime timestamp;
  final bool isError;

  _ChatMessage({
    required this.role,
    required this.text,
    required this.timestamp,
    this.isError = false,
  });
}

// ---------------------------------------------------------------------------
// Suggestion chips shown above the input bar
// ---------------------------------------------------------------------------

const _kSuggestions = [
  '🎂 Birthday vendors in Chennai',
  '💍 Wedding budget 5 lakhs',
  '💼 Corporate event plan',
  '📸 Best photographers near me',
  '🍽️ Compare catering vendors',
  '🎨 Decoration ideas under ₹50,000',
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class AIChatbotScreen extends StatefulWidget {
  const AIChatbotScreen({super.key});

  @override
  State<AIChatbotScreen> createState() => _AIChatbotScreenState();
}

class _AIChatbotScreenState extends State<AIChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Welcome message
    _messages.add(_ChatMessage(
      role: 'assistant',
      text:
          'Vanakkam! 👋 I am **Event Nanban**, your intelligent event planning assistant.\n\n'
          'I can help you:\n'
          '• 🏪 Find and compare approved vendors\n'
          '• 💰 Allocate budgets for your events\n'
          '• 📅 Plan complete event schedules\n'
          '• 🎉 Suggest vendor combinations\n\n'
          'What are you planning today?',
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  List<ChatHistoryItem> _buildHistory() {
    // Send all non-error turns as history (exclude current in-progress message)
    return _messages
        .where((m) => !m.isError)
        .map((m) => ChatHistoryItem(
              role: m.role == 'user' ? 'user' : 'assistant',
              content: m.text,
            ))
        .toList();
  }

  Future<void> _sendMessage([String? overrideText]) async {
    final text = (overrideText ?? _controller.text).trim();
    if (text.isEmpty || _isTyping) return;

    _controller.clear();

    final userMsg = _ChatMessage(
      role: 'user',
      text: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isTyping = true;
    });
    _scrollToBottom();

    // Build history BEFORE adding the current user message (it's already in _messages)
    final history = _buildHistory();
    // Remove the last item (the userMsg we just added) from history
    // since the backend treats "message" as the current turn
    if (history.isNotEmpty && history.last.role == 'user') {
      history.removeLast();
    }

    try {
      final reply = await ChatService.sendMessage(text, history: history);
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            role: 'assistant',
            text: reply,
            timestamp: DateTime.now(),
          ));
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            role: 'assistant',
            text:
                '⚠️ ${e.toString().replaceFirst('Exception: ', '')}\n\nPlease ensure the backend is running and try again.',
            timestamp: DateTime.now(),
            isError: true,
          ));
          _isTyping = false;
        });
        _scrollToBottom();
      }
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const SynoraHeader(
              title: 'Event Nanban AI',
              subtitle: 'Your intelligent event planning assistant',
            ),

            // Chat list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    return _buildTypingIndicator(theme);
                  }
                  return _buildMessageBubble(_messages[index], theme, isDark);
                },
              ),
            ),

            // Suggestion chips (only when not typing and few messages)
            if (!_isTyping && _messages.length <= 3)
              _buildSuggestionChips(theme),

            const Divider(height: 1),

            // Input bar
            _buildInputBar(theme, isDark),
          ],
        ),
      ),
    );
  }

  // ── Message Bubble ──────────────────────────────────────────────────────

  Widget _buildMessageBubble(
      _ChatMessage msg, ThemeData theme, bool isDark) {
    final isUser = msg.role == 'user';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            _buildAvatar(theme),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? theme.primaryColor
                        : (msg.isError
                            ? Colors.red.withOpacity(0.1)
                            : (isDark
                                ? Colors.grey[800]
                                : Colors.grey[100])),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft:
                          Radius.circular(isUser ? 18 : 4),
                      bottomRight:
                          Radius.circular(isUser ? 4 : 18),
                    ),
                    border: msg.isError
                        ? Border.all(
                            color: Colors.red.withOpacity(0.3))
                        : null,
                  ),
                  child: _buildMessageText(msg.text, isUser, theme),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('h:mm a').format(msg.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 14,
              backgroundColor: theme.primaryColor.withOpacity(0.2),
              child: Icon(Icons.person,
                  size: 16, color: theme.primaryColor),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageText(String text, bool isUser, ThemeData theme) {
    // Render **bold** markdown and newlines
    final spans = <InlineSpan>[];
    final baseStyle = TextStyle(
      fontSize: 14,
      height: 1.5,
      color: isUser ? Colors.white : null,
    );
    final boldStyle = baseStyle.copyWith(fontWeight: FontWeight.bold);

    final parts = text.split('**');
    for (var i = 0; i < parts.length; i++) {
      spans.add(TextSpan(
        text: parts[i],
        style: i.isOdd ? boldStyle : baseStyle,
      ));
    }

    return RichText(
      text: TextSpan(children: spans, style: baseStyle),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: theme.primaryColor.withOpacity(0.15),
      child: Text(
        '🤖',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  // ── Typing Indicator ────────────────────────────────────────────────────

  Widget _buildTypingIndicator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _buildAvatar(theme),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (i) => _AnimatedDot(delay: Duration(milliseconds: i * 200)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Suggestion Chips ────────────────────────────────────────────────────

  Widget _buildSuggestionChips(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: _kSuggestions.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            return ActionChip(
              label: Text(
                _kSuggestions[index],
                style: const TextStyle(fontSize: 12),
              ),
              onPressed: () => _sendMessage(_kSuggestions[index]),
              backgroundColor: theme.primaryColor.withOpacity(0.08),
              side: BorderSide(
                  color: theme.primaryColor.withOpacity(0.3)),
              labelPadding:
                  const EdgeInsets.symmetric(horizontal: 4),
            );
          },
        ),
      ),
    );
  }

  // ── Input Bar ───────────────────────────────────────────────────────────

  Widget _buildInputBar(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      color: isDark ? Colors.grey[900] : Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Ask about vendors, budgets, event ideas...',
                hintStyle:
                    TextStyle(color: Colors.grey[400], fontSize: 14),
                filled: true,
                fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide(
                      color: Colors.grey.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide:
                      BorderSide(color: theme.primaryColor, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: _isTyping
                  ? Colors.grey
                  : theme.primaryColor,
              child: IconButton(
                icon: _isTyping
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
                onPressed: _isTyping ? null : () => _sendMessage(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Animated typing dot
// ---------------------------------------------------------------------------

class _AnimatedDot extends StatefulWidget {
  final Duration delay;
  const _AnimatedDot({required this.delay});

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _anim.value),
        child: Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: Colors.grey[500],
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
