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