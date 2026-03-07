import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});
  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {"role": "bot", "content": "¡Hola, Oscar! Soy tu asistente Localia. ¿Buscas algo específico en Guanajuato hoy?"}
  ];

  void _send() {
    if (_controller.text.isEmpty) return;
    setState(() {
      _messages.add({"role": "user", "content": _controller.text});
      _controller.clear();
    });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add({"role": "bot", "content": "Cerca del Estadio León encontré 'Tacos El Mundial'. Tienen 4.9 estrellas y aceptan Coppel Pay. ¿Te guío?"});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // Gris Apple
      appBar: AppBar(
        title: const Text("AI Concierge", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0.8),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (c, i) => _ChatBubble(m: _messages[i]),
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5EA),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(hintText: "Pregunta a Localia...", border: InputBorder.none),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: LocaliaTheme.coppelGreen,
            child: IconButton(icon: const Icon(Icons.arrow_upward, color: Colors.white), onPressed: _send),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final Map<String, String> m;
  const _ChatBubble({required this.m});

  @override
  Widget build(BuildContext context) {
    bool isBot = m["role"] == "bot";
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isBot ? Colors.white : LocaliaTheme.coppelGreen,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(25),
            topRight: const Radius.circular(25),
            bottomLeft: Radius.circular(isBot ? 5 : 25),
            bottomRight: Radius.circular(isBot ? 25 : 5),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
        ),
        child: Text(
          m["content"]!,
          style: TextStyle(color: isBot ? Colors.black87 : Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}