import 'dart:async';
import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';
import 'package:image_picker/image_picker.dart';

class ChatView extends StatefulWidget {
  final VoidCallback? onBack;

  const ChatView({super.key, this.onBack});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  bool isAiOn = true;
  final TextEditingController controller = TextEditingController();

  String? _selectedImagePath;

  List<Map<String, dynamic>> messages = [
    {
      "text": "Hi, I'd like to know more about your products..",
      "time": "10:30 AM",
      "isMe": false
    },
  ];

  //  Dynamic reply function
  String getAutoReply(String message) {
    message = message.toLowerCase();

    if (message.contains("price")) {
      return "Our prices vary depending on the product 😊";
    } else if (message.contains("hello") || message.contains("hi")) {
      return "Hello! How can I help you today?";
    } else if (message.contains("product")) {
      return "We have a wide range of products available.";
    } else if (message.contains("order")) {
      return "You can place an order directly from our app.";
    } else if (message.contains("thanks")) {
      return "You're welcome 🙌";
    } else {
      return "Got it 👍 Let me check that for you.";
    }
  }

  //  Send message
  void sendMessage() {
    if (controller.text.trim().isEmpty) return;

    final userText = controller.text;

    setState(() {
      messages.add({
        "text": userText,
        "time": "Now",
        "isMe": true,
      });
    });

    controller.clear();

    //  Auto reply
    if (isAiOn) {
      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() {
          messages.add({
            "text": getAutoReply(userText),
            "time": "Now",
            "isMe": false,
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          //  Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Theme.of(context).dividerTheme.color ?? const Color(0xffEEEEEE))),
            ),
            child: Row(
              children: [
                if (widget.onBack != null)
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: widget.onBack,
                  ),

                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: AppColor.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text("R",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Robarto",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "Active now",
                        style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 6),

                Transform.scale(
                  scale: 0.75,
                  child: Switch(
                    value: isAiOn,
                    onChanged: (val) {
                      setState(() {
                        isAiOn = val;
                      });
                    },
                    activeColor: AppColor.mini,
                  ),
                ),
              ],
            ),
          ),

          //  Messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildMessageBubble(
                    text: msg["text"],
                    time: msg["time"],
                    isMe: msg["isMe"],
                  ),
                );
              },
            ),
          ),

          // ✅ Input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light ? const Color(0xffF3F4F6) : Theme.of(context).colorScheme.surface,
              border: Border(top: BorderSide(color: Theme.of(context).dividerTheme.color ?? const Color(0xffEEEEEE))),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.photo_library),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();

                    final XFile? image =
                    await picker.pickImage(source: ImageSource.gallery);

                    if (image != null) {
                      setState(() {
                        _selectedImagePath = image.path;
                      });
                    }
                  },
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: "Type a message",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String text,
    required String time,
    required bool isMe,
  }) {
    return Align(
      alignment:
      isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMe
                  ? AppColor.primary
                  : (Theme.of(context).brightness == Brightness.light ? const Color(0xffF3F4F6) : Theme.of(context).colorScheme.surface),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: isMe ? Colors.white : (Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            time,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}