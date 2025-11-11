import 'package:flutter/material.dart';
import 'package:sistema_de_ventas/features/auth/login_screen.dart';
import 'package:sistema_de_ventas/features/dashboard/dashboard_screen.dart';
import 'package:sistema_de_ventas/features/inventory/inventory_screen.dart';
import 'package:sistema_de_ventas/features/products/products_screen.dart';
import 'package:sistema_de_ventas/features/clients/clients_screen.dart';
import 'package:sistema_de_ventas/features/sales/pos_screen.dart';

class AppRoutes {
  static const String login = '/';
  static const String dashboard = '/dashboard';
  static const String inventory = '/inventory';
  static const String products = '/products';
  static const String clients = '/clients';
  static const String pos = '/pos';

  // ✅ MANTENER PARA FUTURA MIGRACIÓN A RUTAS NOMBRADAS
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case inventory:
        return MaterialPageRoute(builder: (_) => const InventoryScreen());
      case products:
        return MaterialPageRoute(builder: (_) => const ProductsScreen());
      case clients:
        return MaterialPageRoute(builder: (_) => const ClientsScreen());
      case pos:
        return MaterialPageRoute(builder: (_) => const PosScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}