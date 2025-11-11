import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_de_ventas/app/app.dart'; // Ahora importa MyApp
import 'package:sistema_de_ventas/core/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar servicios antes de iniciar la app
  final authService = AuthService();
  await authService.initialize();
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => authService,
      child: const MyApp(), // ✅ Cambiado a MyApp
    ),
  );
}