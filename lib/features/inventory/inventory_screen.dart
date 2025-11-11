import 'package:flutter/material.dart';
import 'package:sistema_de_ventas/core/services/api_service.dart';
import 'package:sistema_de_ventas/shared/models/inventory_response.dart';
// ← Asegurar import

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<LowStockProduct> _productosStockBajo = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _cargarStockBajo();
  }

  Future<void> _cargarStockBajo() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final productos = await ApiService.obtenerStockBajo();
      
      setState(() {
        _productosStockBajo = productos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error cargando inventario: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _buscarProductos(String termino) async {
    try {
      setState(() {
        _isLoading = true;
        _searchTerm = termino;
      });

      // Por ahora mostramos solo stock bajo, luego implementaremos búsqueda completa
      await _cargarStockBajo();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error en búsqueda: $e';
        _isLoading = false;
      });
    }
  }

  void _navegarAlScanner() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔍 Escáner de código de barras - Próximamente'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Color _getColorPorEstado(String estado) {
    switch (estado) {
      case 'AGOTADO':
        return Colors.red;
      case 'STOCK_BAJO':
        return Colors.orange;
      case 'STOCK_MEDIO':
        return Colors.yellow;
      case 'STOCK_NORMAL':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconPorEstado(String estado) {
    switch (estado) {
      case 'AGOTADO':
        return Icons.error_outline;
      case 'STOCK_BAJO':
        return Icons.warning;
      case 'STOCK_MEDIO':
        return Icons.info_outline;
      case 'STOCK_NORMAL':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  double _getProgresoStock(int stock) {
    if (stock == 0) return 0.1;
    if (stock < 5) return 0.3;
    if (stock < 10) return 0.6;
    if (stock < 20) return 0.8;
    return 1.0;
  }

  void _mostrarModalProducto(LowStockProduct producto) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withOpacity(0.2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getColorPorEstado(producto.estado).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getIconPorEstado(producto.estado),
                        color: _getColorPorEstado(producto.estado),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            producto.producto.nombre ?? 'Sin nombre', // ← CORREGIDO: agregar ??
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            producto.alertaTexto,
                            style: TextStyle(
                              color: _getColorPorEstado(producto.estado),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _buildInfoRow('📦 Stock actual', '${producto.stock} unidades'),
                _buildInfoRow('💰 Precio', producto.producto.precioFormateado), // ← CORREGIDO: usar getter
                _buildInfoRow('📁 Categoría', producto.producto.categoria ?? 'General'), // ← CORREGIDO: agregar ??
                _buildInfoRow(
                  '🔢 Código', 
                  (producto.producto.codigoBarras?.isNotEmpty == true) // ← CORREGIDO: agregar ??
                      ? producto.producto.codigoBarras! 
                      : 'Sin código de barras'
                ),

                if (producto.producto.descripcion?.isNotEmpty == true) // ← CORREGIDO: agregar ??
                  _buildInfoRow('📝 Descripción', producto.producto.descripcion!),

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nivel de stock:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _getProgresoStock(producto.stock),
                        backgroundColor: Colors.grey.shade300,
                        color: _getColorPorEstado(producto.estado),
                        minHeight: 6,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Crítico',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red.shade600,
                            ),
                          ),
                          Text(
                            'Óptimo',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _navegarAlScanner();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.qr_code_scanner, size: 18),
                            SizedBox(width: 8),
                            Text('Escanear'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('✏️ Editar stock de ${producto.producto.nombre ?? "producto"}'), // ← CORREGIDO
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getColorPorEstado(producto.estado),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Acción'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              titulo,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📦 Inventario Inteligente'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _navegarAlScanner,
            tooltip: 'Escanear código de barras',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarStockBajo,
            tooltip: 'Actualizar inventario',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: '🔍 Buscar producto por nombre o código...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (value) {
                if (value.length >= 2) {
                  _buscarProductos(value);
                } else if (value.isEmpty) {
                  _cargarStockBajo();
                }
              },
            ),
          ),

          if (_productosStockBajo.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_productosStockBajo.length} productos necesitan atención',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          Expanded(
            child: _isLoading
                ? _buildLoadingIndicator()
                : _errorMessage.isNotEmpty
                    ? _buildErrorWidget()
                    : _productosStockBajo.isEmpty
                        ? _buildEmptyState()
                        : _buildProductList(),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _navegarAlScanner,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Cargando inventario...'),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Error al cargar el inventario',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _cargarStockBajo,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2, size: 80, color: Colors.green.shade400),
          const SizedBox(height: 16),
          const Text(
            '¡Inventario en Orden!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'No hay productos con stock bajo',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            _searchTerm.isNotEmpty
                ? 'No se encontraron productos para "$_searchTerm"'
                : 'Todo está bajo control',
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      itemCount: _productosStockBajo.length,
      itemBuilder: (context, index) {
        final producto = _productosStockBajo[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getColorPorEstado(producto.estado).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getIconPorEstado(producto.estado),
                color: _getColorPorEstado(producto.estado),
              ),
            ),
            title: Text(
              producto.producto.nombre ?? 'Sin nombre', // ← CORREGIDO
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Código: ${(producto.producto.codigoBarras?.isNotEmpty == true) ? producto.producto.codigoBarras : 'Sin código'}', // ← CORREGIDO
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  'Categoría: ${producto.producto.categoria ?? "General"}', // ← CORREGIDO
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${producto.stock} uds',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getColorPorEstado(producto.estado),
                  ),
                ),
                Text(
                  producto.alertaTexto,
                  style: TextStyle(
                    fontSize: 10,
                    color: _getColorPorEstado(producto.estado),
                  ),
                ),
              ],
            ),
            onTap: () {
              _mostrarModalProducto(producto);
            },
          ),
        );
      },
    );
  }
}