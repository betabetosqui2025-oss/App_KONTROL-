import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_de_ventas/core/services/auth_service.dart';
import 'package:sistema_de_ventas/core/services/api_service.dart';
import 'package:sistema_de_ventas/app/routes.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int totalProductos = 0;
  int totalClientes = 0;
  int stockBajo = 0;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _cargarDatosReales();
  }

  Future<void> _cargarDatosReales() async {
    try {
      print('🔄 Cargando datos del dashboard...');
      
      // ✅ CARGAR DATOS REALES + STOCK BAJO
      final productos = await ApiService.obtenerProductosTemp();
      final clientes = await ApiService.obtenerClientesTemp();
      final stockBajoCount = await ApiService.contarStockBajo();

      print('✅ Productos cargados: ${productos.length}');
      print('✅ Clientes cargados: ${clientes.length}');
      print('✅ Stock bajo: $stockBajoCount productos');

      setState(() {
        totalProductos = productos.length;
        totalClientes = clientes.length;
        stockBajo = stockBajoCount;
        isLoading = false;
        errorMessage = '';
      });
    } catch (e) {
      print('❌ Error en dashboard: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $e';
      });
    }
  }

  // WIDGET DE LOADING
  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Conectando con el servidor...'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard KONTROL+'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDatosReales,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authService.logout();
            },
          ),
        ],
      ),
      body: isLoading
          ? _buildLoadingIndicator()
          : errorMessage.isNotEmpty
              ? _buildErrorWidget()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bienvenida
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blue.shade100,
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '¡Bienvenido/a!',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Sistema de Ventas Móvil',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Métricas con datos REALES
                      const Text(
                        'Resumen en Tiempo Real',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Grid de métricas con datos REALES
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          _buildMetricCard('Productos', totalProductos.toString(), Icons.inventory_2, Colors.blue),
                          _buildMetricCard('Clientes', totalClientes.toString(), Icons.people, Colors.green),
                          _buildMetricCard('Ventas Hoy', '0', Icons.shopping_cart, Colors.orange),
                          _buildMetricCard('Stock Bajo', stockBajo.toString(), Icons.warning, Colors.red),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Acciones rápidas
                      const Text(
                        'Acciones Rápidas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          ActionChip(
                            avatar: const Icon(Icons.inventory_2, color: Colors.white, size: 16),
                            label: const Text('Ver Productos'),
                            backgroundColor: Colors.blue,
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.products);
                            },
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.people, color: Colors.white, size: 16),
                            label: const Text('Ver Clientes'),
                            backgroundColor: Colors.green,
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.clients);
                            },
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.warehouse, color: Colors.white, size: 16),
                            label: const Text('Inventario'),
                            backgroundColor: Colors.orange,
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.inventory);
                            },
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 16),
                            label: const Text('Nueva Venta'),
                            backgroundColor: Colors.purple,
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.pos);
                            },
                          ),
                        ],
                      ),

                      // ✅ BOTÓN DESTACADO PARA INVENTARIO INTELIGENTE
                      const SizedBox(height: 24),
                      Card(
                        color: Colors.blue.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.auto_awesome, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text(
                                    'Nueva Funcionalidad',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Inventario Inteligente con alertas de stock bajo',
                                style: TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, AppRoutes.inventory);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.qr_code_scanner),
                                    SizedBox(width: 8),
                                    Text('Probar Inventario Inteligente'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, color: Colors.orange, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Problema de conexión',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _cargarDatosReales,
                  child: const Text('Reintentar'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _probarConexion,
                  child: const Text('Probar Conexión'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _probarConexion() async {
    try {
      final health = await ApiService.healthCheck();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Conexión OK: ${health['message']}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}