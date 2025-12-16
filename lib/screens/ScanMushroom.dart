import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ChatBot.dart';

class ScanMushroomScreen extends StatefulWidget {
  final void Function(int, {String? initialMessage})? onNavigate;
  const ScanMushroomScreen({super.key, this.onNavigate});

  @override
  State<ScanMushroomScreen> createState() => _ScanMushroomScreenState();
}

class _ScanMushroomScreenState extends State<ScanMushroomScreen> {
  File? _image;
  bool _uploading = false;
  List<Map<String, dynamic>> _results = [];
  final ImagePicker _picker = ImagePicker();
  String apiBase = 'http://192.168.0.159:5000/';

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1200,
    );
    if (photo == null) return;
    setState(() => _image = File(photo.path));
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Usar esta imagen?'),
        content: Image.file(File(photo.path), width: 250),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tomar otra'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Usar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _uploadImage(File(photo.path));
    } else {
      setState(() => _image = null);
    }
  }

  Future<void> _uploadImage(File image) async {
    setState(() {
      _uploading = true;
      _results = [];
    });
    try {
      final uri = Uri.parse('${apiBase}identify-mushroom/');
      final req = http.MultipartRequest('POST', uri);
      req.files.add(await http.MultipartFile.fromPath('file', image.path));
      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        final list = (body['results'] as List)
            .map((e) => {'name': e['name'], 'score': e['score']})
            .toList();
        setState(() => _results = List<Map<String, dynamic>>.from(list));
      } else {
        _showError('Error en la API');
      }
    } catch (e) {
      _showError('Error de conexión');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _showError(String msg) => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Error'),
      content: Text(msg),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => _image = File(image.path));
    await _uploadImage(File(image.path));
  }

  Map<String, dynamic> _parseJsonFromResponse(String raw) {
    final cleaned = raw
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    return json.decode(cleaned) as Map<String, dynamic>;
  }

  String _formatMushroomInfo(Map<String, dynamic> json) {
    final buffer = StringBuffer();

    buffer.writeln("## 🍄 ${json['nombre_comun'] ?? 'Desconocido'}");
    buffer.writeln("_${json['nombre_cientifico'] ?? ''}_\n");

    buffer.writeln(
      "🥗 **Comestible:** ${json['es_comestible'] == 'sí' ? '✅ Sí' : '⚠️ No'}  ",
    );
    // buffer.writeln(
    //   "☠️ **Venenoso:** ${json['venenoso'] == 'sí' ? '⚠️ Sí' : '✅ No'}\n",
    // );

    if (json['donde_crecen'] != null) {
      buffer.writeln("### 🌲 Dónde crece");
      buffer.writeln("${json['donde_crecen']}\n");
    }

    if (json['como_cocinar'] != null) {
      buffer.writeln("### 🍳 Cómo cocinar");
      buffer.writeln("${json['como_cocinar']}\n");
    }

    if (json['advertencias'] != null) {
      buffer.writeln("### ⚠️ Advertencias");
      buffer.writeln("${json['advertencias']}");
    }

    return buffer.toString();
  }

  Future<void> _openMushroomInfo(String name) async {
    try {
      final res = await http.post(
        Uri.parse('${apiBase}get-mushroom-info/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'mushroom_name': name}),
      );

      final body = json.decode(res.body);

      if (res.statusCode == 200) {
        if (!mounted) return;

        final rawResponse = body["response"] as String;
        final mushroomJson = _parseJsonFromResponse(rawResponse);
        final formattedText = _formatMushroomInfo(mushroomJson);

        widget.onNavigate?.call(
          0,
          initialMessage: formattedText,
        );
      } else {
        _showError(body["error"] ?? "Error en la API");
      }
    } catch (e) {
      _showError("Error de conexión");
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
                              "ESCANEAR SETA",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.5,
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
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 260,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7EE),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: _image == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 180,
                                child: ElevatedButton(
                                  onPressed: _pickFromGallery,
                                  child: const Text("Subir archivo"),
                                ),
                              ),

                              const SizedBox(height: 8),
                              const Text("o"),
                              const SizedBox(height: 8),

                              SizedBox(
                                width: 180,
                                child: ElevatedButton(
                                  onPressed: _takePhoto,
                                  child: const Text("Tomar foto"),
                                ),
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _image!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                  ),

                  if (_image != null)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: GestureDetector(
                        onTap: () => setState(() => _image = null),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black54,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    )
                ],
              ),

              const SizedBox(height: 20),

              if (_image == null)
                Text(
                  "¡Haz una foto o súbela de tu galería para poder analizarla y obtener una predicción de qué especie de seta se trata!\n\n"
                  "Para obtener mejores resultados, asegúrate de que la foto muestre claramente la copa y el tallo de la seta, "
                  "sin que esté cubierta por musgo, hojas o hierbas. Evita sombras fuertes y trata de que toda la seta esté enfocada.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 20),

              if (_uploading) const CircularProgressIndicator(),

              const SizedBox(height: 20),

              if (_results.isNotEmpty && _image != null)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _results.length,
                  itemBuilder: (_, i) {
                    final r = _results[i];  
                    final percent = ((r['score'] as num) * 100).toStringAsFixed(1);
                    return ListTile(
                      title: Text(r['name']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("$percent%"),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.info_outline, color: Color(0xFF2E5E3A)),
                            onPressed: () => _openMushroomInfo(r['name']),
                          )
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ]
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