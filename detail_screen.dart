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