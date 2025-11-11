import 'package:flutter/material.dart';
import 'package:sistema_de_ventas/core/services/api_service.dart';
import 'package:sistema_de_ventas/shared/models/product_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Producto> _productos = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    try {
      print('🔄 Cargando productos...');
      final response = await ApiService.obtenerProductosTemp();
      
      List<Producto> productos = (response).map((item) {
        return Producto.fromJson(item);
      }).toList();
      
      setState(() {
        _productos = productos;
        _isLoading = false;
      });
      
      print('✅ Productos cargados: ${productos.length}');
    } catch (e) {
      print('❌ Error cargando productos: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  // ✅ NUEVO MÉTODO: EXPORTAR PRODUCTOS A TXT CON PERMISOS
  Future<void> _exportarProductos() async {
    try {
      // 1. Pedir permiso de almacenamiento ESPECIAL para Android 11+
      PermissionStatus status;
      
      if (await Permission.manageExternalStorage.isGranted) {
        status = PermissionStatus.granted;
      } else {
        status = await Permission.manageExternalStorage.request();
      }
      
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Permiso de almacenamiento denegado. Toque para abrir configuración.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        
        // Abrir configuración después de un delay
        Future.delayed(const Duration(seconds: 2), () {
          openAppSettings();
        });
        
        return;
      }

      // 2. Mostrar loading
      setState(() {
        _isLoading = true;
      });

      // 3. Crear contenido del archivo
      final contenido = _generarContenidoExportacion();
      
      // 4. Obtener directorio de descargas (CORREGIDO)
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('No se pudo acceder al almacenamiento');
      }
      
      // Crear subcarpeta para la app
      final appDir = Directory('${directory.path}/SistemaVentas');
      if (!await appDir.exists()) {
        await appDir.create(recursive: true);
      }
      
      final filePath = '${appDir.path}/productos_${DateTime.now().millisecondsSinceEpoch}.txt';
      
      // 5. Guardar archivo
      final file = File(filePath);
      await file.writeAsString(contenido);
      
      // 6. Mostrar éxito
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('✅ Productos exportados exitosamente'),
              Text('Archivo: ${file.path.split('/').last}', style: const TextStyle(fontSize: 12)),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'ABRIR',
            onPressed: () {
              // Intentar abrir el archivo
              print('📂 Ruta completa: ${file.path}');
            },
          ),
        ),
      );
      
      print('📁 Archivo guardado en: ${file.path}');
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error exportando: $e'),
          backgroundColor: Colors.red,
        ),
      );
      
      print('❌ Error en exportación: $e');
    }
  }

  // ✅ NUEVO MÉTODO: GENERAR CONTENIDO DEL ARCHIVO
  String _generarContenidoExportacion() {
    final buffer = StringBuffer();
    
    buffer.writeln('=== SISTEMA DE VENTAS - EXPORTACIÓN DE PRODUCTOS ===');
    buffer.writeln('Fecha: ${DateTime.now()}');
    buffer.writeln('Total productos: ${_productos.length}');
    buffer.writeln('=' * 50);
    buffer.writeln();
    
    for (var i = 0; i < _productos.length; i++) {
      final producto = _productos[i];
      buffer.writeln('PRODUCTO ${i + 1}:');
      buffer.writeln('Nombre: ${producto.nombre ?? "Sin nombre"}');
      buffer.writeln('Precio: ${producto.precioFormateado}');
      buffer.writeln('Categoría: ${producto.categoria ?? "General"}');
      buffer.writeln('Código: ${producto.codigoBarras ?? "Sin código"}');
      buffer.writeln('Activo: ${producto.activo == true ? "SÍ" : "NO"}');
      
      if (producto.descripcion?.isNotEmpty == true) {
        buffer.writeln('Descripción: ${producto.descripcion}');
      }
      
      buffer.writeln('-' * 30);
    }
    
    return buffer.toString();
  }

  List<Producto> get _filteredProducts {
    if (_searchQuery.isEmpty) return _productos;
    return _productos.where((producto) =>
      producto.nombre?.toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
      producto.codigoBarras?.toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
      producto.categoria?.toLowerCase().contains(_searchQuery.toLowerCase()) == true
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          // ✅ NUEVO BOTÓN DE EXPORTACIÓN
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportarProductos,
            tooltip: 'Exportar productos a TXT (Pide permisos)',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarProductos,
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingIndicator()
          : _errorMessage.isNotEmpty
              ? _buildErrorWidget()
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar productos...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: _filteredProducts.isEmpty
                          ? _buildEmptyState()
                          : _buildProductList(),
                    ),
                  ],
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
          Text('Cargando productos...'),
        ],
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
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar productos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _cargarProductos,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'No hay productos' : 'No se encontraron productos',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          if (_searchQuery.isNotEmpty)
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                });
              },
              child: const Text('Limpiar búsqueda'),
            )
          else
            ElevatedButton(
              onPressed: _cargarProductos,
              child: const Text('Recargar'),
            ),
        ],
      ),
    );
  }

  Widget _buildProductImage(Producto producto) {
    if (producto.imagenUrl != null && producto.imagenUrl!.isNotEmpty) {
      String imageUrl = producto.imagenUrl!;
      
      if (!imageUrl.startsWith('http')) {
        imageUrl = 'http://127.0.0.1:8080$imageUrl';
      }
      
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('❌ Error cargando imagen: $error');
            return _buildPlaceholderIcon(producto);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
        ),
      );
    }
    
    return _buildPlaceholderIcon(producto);
  }

  Widget _buildPlaceholderIcon(Producto producto) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: producto.activo == false ? Colors.grey.shade300 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.inventory_2,
        color: producto.activo == false ? Colors.grey : Colors.blue,
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final producto = _filteredProducts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          elevation: 2,
          child: ListTile(
            leading: _buildProductImage(producto),
            title: Text(
              producto.nombre ?? 'Sin nombre',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: producto.activo == false ? Colors.grey : Colors.black,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                if (producto.codigoBarras?.isNotEmpty == true)
                  Text(
                    'Código: ${producto.codigoBarras}',
                    style: TextStyle(
                      color: producto.activo == false ? Colors.grey : null,
                    ),
                  ),
                Text(
                  'Precio: ${producto.precioFormateado}',
                  style: TextStyle(
                    color: producto.activo == false ? Colors.grey : null,
                  ),
                ),
                Text(
                  'Categoría: ${producto.categoria ?? "General"}',
                  style: TextStyle(
                    color: producto.activo == false ? Colors.grey : null,
                  ),
                ),
                if (producto.activo == false)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'INACTIVO',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            trailing: Icon(
              producto.activo == true ? Icons.check_circle : Icons.cancel,
              color: producto.activo == true ? Colors.green : Colors.red,
            ),
          ),
        );
      },
    );
  }
}