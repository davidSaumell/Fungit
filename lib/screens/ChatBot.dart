import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../ThemeProvider.dart';
import 'package:provider/provider.dart';


class ChatBotScreen extends StatefulWidget {
  final String? initialMessage;

  const ChatBotScreen({super.key, this.initialMessage});
  
  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final List<Map<String, String>> _messages = [];
  final _ctrl = TextEditingController();
  bool _sending = false;
  String apiBase = 'http://192.168.0.159:5000/';

  @override
  void initState() {
    super.initState();
    if (widget.initialMessage != null) {
      _messages.add({'role': 'bot', 'text': widget.initialMessage!});
    }
  }

  @override
  void didUpdateWidget(covariant ChatBotScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialMessage != null &&
        widget.initialMessage != oldWidget.initialMessage) {
      setState(() {
        _messages.add({'role': 'bot', 'text': widget.initialMessage!});
      });
    }
  }

  String _buildPromptWithContext(String userInput) {
    final buffer = StringBuffer();

    buffer.writeln(
      "Eres Mushie, un asistente experto en micología. "
      "Responde de forma clara, concisa y basada en hechos científicos.\n"
    );

    if (_messages.isNotEmpty) {
      buffer.writeln("Este es el contexto de la conversación hasta ahora:\n");

      for (final msg in _messages) {
        final role = msg['role'] == 'user' ? 'Usuario' : 'Asistente';
        final text = msg['text'] ?? '';
        buffer.writeln("$role: $text\n");
      }
    }

    buffer.writeln("Pregunta actual del usuario:");
    buffer.writeln(userInput);

    return buffer.toString();
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _sending = true;
      _messages.add({'role': 'user', 'text': text});
    });
    _ctrl.clear();

    final prompt = _buildPromptWithContext(text);

    try {
      final res = await http.post(
        Uri.parse('${apiBase}ask-chatbot/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': prompt}),
      );
      final body = json.decode(res.body);
      final reply = body['response'] ?? 'Sin respuesta';
      if (mounted) {
        setState(() {
          _messages.add({'role': 'bot', 'text': reply});
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'bot',
            'text': '❌ Error de conexión con la API'
          });
        });
      }
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PreferredSize(
          preferredSize: const Size.fromHeight(170),
          child: Stack(
            children: [
              CustomPaint(
                size: const Size(double.infinity, 170),
                painter: CurvedShadowPainter(),
              ),

              ClipPath(
                clipper: CurvedHeaderClipper(),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  color: const Color(0xFFD91515),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "MUSHIE",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Asistente boletaire",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _messages.length,
            itemBuilder: (_, i) {
              final msg = _messages[i];
              final isUser = msg['role'] == 'user';
              return Align(
                alignment: isUser!
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(12),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.grey[300] : Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: MarkdownBody(
                    data: msg['text'] ?? '',
                    styleSheet: MarkdownStyleSheet(
                      h2: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      p: const TextStyle(fontSize: 16),
                      em: const TextStyle(fontStyle: FontStyle.italic),
                      strong: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: InputDecoration(
                      hintText: 'Pregúntale a Mushie...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  )
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sending ? null : () => _send(_ctrl.text),
                  child: _sending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color:  Color(0xFFF2EDE4)
                          ),
                        )
                      : const SizedBox(
                          width: 16,
                          height: 16,
                          child: const Icon(Icons.send_rounded),
                        )
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CurvedShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final shadowPath = Path();

    shadowPath.lineTo(0, size.height - 40);

    shadowPath.quadraticBezierTo(
      size.width * 0.5,
      size.height,
      size.width,
      size.height - 40,
    );

    shadowPath.lineTo(size.width, 0);
    shadowPath.close();

    canvas.drawShadow(
      shadowPath,
      Colors.black.withOpacity(0.4),
      12.0,
      true,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CurvedHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, size.height - 40);

    path.quadraticBezierTo(
      size.width * 0.5,
      size.height,
      size.width,
      size.height - 40,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
