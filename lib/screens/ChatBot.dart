import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final List<Map<String, String>> _messages = [];
  final _ctrl = TextEditingController();
  bool _sending = false;
  String apiBase = ''; // TODO Add the apiBase url

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    setState(() => _sending = true);
    _messages.add({'role': 'user', 'text': text});
    _ctrl.clear();
    try {
      final res = await http.post(
        Uri.parse('\$apiBase/chat'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': text}),
      );
      final body = json.decode(res.body);
      final reply = body['reply'] ?? 'Sin respuesta';
      _messages.add({'role': 'bot', 'text': reply});
    } catch (e) {
      _messages.add({'role': 'bot', 'text': 'Error de conexión con la API'});
    } finally {
      if (mounted) setState(() => _sending = false);
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
                  child: Text(msg['text'] ?? ''),
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
