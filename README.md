// pubspec.yaml
name: paquetes_turisticos_app
description: Aplicación para vender paquetes turísticos
publish_to: 'none'
version: 1.0.0+1
environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.0
  firebase_auth: ^4.12.0
  cloud_firestore: ^4.9.0
  firebase_storage: ^11.5.0
  image_picker: ^1.1.0
  provider: ^6.1.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true

// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(PaquetesApp());
}

class PaquetesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paquetes Turísticos',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: LoginScreen(),
    );
  }
}

// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passController = TextEditingController();

  void login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text.trim(),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al iniciar sesión')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Iniciar Sesión")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Correo")),
            TextField(controller: passController, decoration: InputDecoration(labelText: "Contraseña"), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: Text("Ingresar")),
            TextButton(onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen()));
            }, child: Text("¿No tienes cuenta? Regístrate"))
          ],
        ),
      ),
    );
  }
}

// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passController = TextEditingController();

  void register() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text.trim(),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al registrar usuario')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registrarse")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Correo")),
            TextField(controller: passController, decoration: InputDecoration(labelText: "Contraseña"), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: register, child: Text("Crear cuenta")),
          ],
        ),
      ),
    );
  }
}

// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_screen.dart';
import 'upload_image_screen.dart';
import 'admin_reservas_screen.dart';

class HomeScreen extends StatelessWidget {
  final paquetesRef = FirebaseFirestore.instance.collection('paquetes');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Paquetes Turísticos"),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AdminReservasScreen()));
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.upload),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => UploadImageScreen()));
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: paquetesRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final paquete = docs[index];
              return ListTile(
                title: Text(paquete['titulo']),
                subtitle: Text("\$${paquete['precio']}"),
                leading: Image.network(paquete['imagen'], width: 60, fit: BoxFit.cover),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailScreen(paquete: paquete),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// lib/screens/detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailScreen extends StatelessWidget {
  final QueryDocumentSnapshot paquete;

  DetailScreen({required this.paquete});

  final nombreController = TextEditingController();
  final fechaController = TextEditingController();
  final personasController = TextEditingController();

  void reservar(BuildContext context) async {
    await FirebaseFirestore.instance.collection('reservas').add({
      'paqueteId': paquete.id,
      'nombre': nombreController.text.trim(),
      'fecha': fechaController.text.trim(),
      'personas': personasController.text.trim(),
      'fechaReserva': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Reserva realizada exitosamente")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(paquete['titulo'])),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(paquete['imagen'], height: 200, fit: BoxFit.cover),
            SizedBox(height: 10),
            Text(paquete['titulo'], style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text("\$${paquete['precio']}", style: TextStyle(fontSize: 18)),
            Divider(height: 30),
            Text("Reserva este paquete", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(controller: nombreController, decoration: InputDecoration(labelText: "Tu nombre")),
            TextField(controller: fechaController, decoration: InputDecoration(labelText: "Fecha deseada")),
            TextField(controller: personasController, decoration: InputDecoration(labelText: "Número de personas")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () => reservar(context), child: Text("Reservar ahora")),
          ],
        ),
      ),
    );
  }
}

// lib/screens/upload_image_screen.dart
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

    final ref = FirebaseStorage.instance.ref().child('paquetes/\${DateTime.now().millisecondsSinceEpoch}.jpg');
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

// lib/screens/admin_reservas_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminReservasScreen extends StatelessWidget {
  final reservasRef = FirebaseFirestore.instance.collection('reservas');
  final paquetesRef = FirebaseFirestore.instance.collection('paquetes');

  Future<String> obtenerTituloPaquete(String paqueteId) async {
    final doc = await paquetesRef.doc(paqueteId).get();
    return doc.exists ? doc['titulo'] : 'Desconocido';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reservas Realizadas")),
      body: StreamBuilder<QuerySnapshot>(
        stream: reservasRef.orderBy('fechaReserva', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final reserva = docs[index];
              return FutureBuilder<String>(
                future: obtenerTituloPaquete(reserva['paqueteId']),
                builder: (context, paqueteSnapshot) {
                  final titulo = paqueteSnapshot.data ?? "Cargando...";
                  return ListTile(
                    title: Text("Reserva de \${reserva['nombre']}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Paquete: \$titulo"),
                        Text("Fecha: \${reserva['fecha']}"),
                        Text("Personas: \${reserva['personas']}"),
                      ],
                    ),
                    trailing: Icon(Icons.check_circle_outline),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

