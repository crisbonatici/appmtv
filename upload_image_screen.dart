import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadImageScreen extends StatefulWidget {
  @override
  _UploadImageScreenState createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  File? image;
  final tituloController = TextEditingController();
  final precioController = TextEditingController();

  Future pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => image = File(picked.path));
  }

  Future uploadImage() async {
    if (image == null) return;

    final ref = FirebaseStorage.instance.ref().child('paquetes/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(image!);
    final imageUrl = await ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('paquetes').add({
      'titulo': tituloController.text.trim(),
      'precio': precioController.text.trim(),
      'imagen': imageUrl,
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Paquete subido")));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Subir nuevo paquete")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: tituloController, decoration: InputDecoration(labelText: "Título")),
            TextField(controller: precioController, decoration: InputDecoration(labelText: "Precio")),
            SizedBox(height: 10),
            ElevatedButton(onPressed: pickImage, child: Text("Seleccionar imagen")),
            if (image != null) Image.file(image!, height: 200),
            SizedBox(height: 20),
            ElevatedButton(onPressed: uploadImage, child: Text("Subir paquete")),
          ],
        ),
      ),
    );
  }
}