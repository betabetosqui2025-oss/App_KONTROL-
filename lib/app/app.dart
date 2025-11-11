import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:sistema_de_ventas/core/services/auth_service.dart';
import 'package:sistema_de_ventas/features/auth/login_screen.dart';  
import 'package:sistema_de_ventas/features/dashboard/dashboard_screen.dart';
import 'package:sistema_de_ventas/features/inventory/inventory_screen.dart';
import 'package:sistema_de_ventas/features/products/products_screen.dart';
import 'package:sistema_de_ventas/features/clients/clients_screen.dart';
import 'package:sistema_de_ventas/features/sales/pos_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: MaterialApp(
        title: 'KONTROL+ - Sistema de Ventas',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const AppContent(),
        // ✅ RUTAS NOMBRADAS PARA NAVEGACIÓN
        routes: {
          '/dashboard': (context) => const DashboardScreen(),
          '/inventory': (context) => const InventoryScreen(),
          '/products': (context) => const ProductsScreen(),
          '/clients': (context) => const ClientsScreen(),
          '/pos': (context) => const PosScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AppContent extends StatelessWidget {
  const AppContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        print('🔄 AppContent reconstruido - Autenticado: ${authService.isAuthenticated}');
        
        if (authService.isAuthenticated) {
          print('✅ Redirigiendo al Dashboard...');
          return const DashboardScreen();
        } else {
          print('🔐 Mostrando Login...');
          return const LoginScreen();
        }
      },
    );
  }
}