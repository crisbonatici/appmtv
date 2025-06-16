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
                    title: Text("Reserva de ${reserva['nombre']}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Paquete: $titulo"),
                        Text("Fecha: ${reserva['fecha']}"),
                        Text("Personas: ${reserva['personas']}"),
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