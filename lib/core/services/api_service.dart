import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sistema_de_ventas/shared/models/product_model.dart';
import 'package:sistema_de_ventas/shared/models/inventory_response.dart';

class ApiService {
  // ✅ URL CONFIGURABLE PARA DIFERENTES ENTORNOS
  static String get baseUrl {
    // PARA EMULADOR (Android):
    // return 'http://10.0.2.2:8080';
    
    // PARA DISPOSITIVO FÍSICO (con ngrok):

    // return 'https://rectally-nonaffiliated-tiffani.ngrok-free.dev';
    
    // PARA WEB:
    return 'http://localhost:8080';
  }

  static String? _token;

  // Inicializar servicio
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  // Guardar token
  static Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Eliminar token
  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Headers con autenticación
  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return headers;
  }

  // ✅ POST REQUEST - AGREGADO
  static Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    try {
      print('🔗 Haciendo POST a: $baseUrl$endpoint');
      print('📤 Datos: $data');
      
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: json.encode(data),
      );
      
      print('📥 Respuesta POST: ${response.statusCode}');
      print('📦 Body: ${response.body}');
      
      return response;
    } catch (e) {
      print('❌ Error en POST: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // GET request con mejor manejo de errores
  static Future<http.Response> get(String endpoint) async {
    try {
      print('🔗 Haciendo GET a: $baseUrl$endpoint');
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );
      
      print('📥 Respuesta: ${response.statusCode}');
      print('📦 Body: ${response.body}');
      
      return response;
    } catch (e) {
      print('❌ Error de conexión: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Verificar si está logueado
  static bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  // ==================== ✅ MÉTODOS TEMPORALES MEJORADOS ====================

  // HEALTH CHECK
  static Future<Map<String, dynamic>> healthCheck() async {
    final response = await get('/api/mobile/health');
    
    if (response.statusCode == 200) {
      try {
        return json.decode(response.body);
      } catch (e) {
        throw Exception('Error decodificando JSON: $e');
      }
    } else {
      throw Exception('Error en health check: ${response.statusCode}');
    }
  }

  // PRODUCTOS TEMPORAL
  static Future<List<dynamic>> obtenerProductosTemp() async {
    final response = await get('/api/mobile/products');
    
    if (response.statusCode == 200) {
      try {
        final decoded = json.decode(response.body);
        if (decoded is List) {
          return decoded;
        } else {
          throw Exception('La respuesta no es una lista: $decoded');
        }
      } catch (e) {
        print('❌ Error decodificando productos: $e');
        print('📦 Body recibido: ${response.body}');
        throw Exception('Error decodificando productos: $e');
      }
    } else {
      throw Exception('Error al cargar productos: ${response.statusCode}');
    }
  }

  // CLIENTES TEMPORAL
  static Future<List<dynamic>> obtenerClientesTemp() async {
    final response = await get('/api/mobile/clients');
    
    if (response.statusCode == 200) {
      try {
        final decoded = json.decode(response.body);
        if (decoded is List) {
          return decoded;
        } else {
          throw Exception('La respuesta no es una lista: $decoded');
        }
      } catch (e) {
        print('❌ Error decodificando clientes: $e');
        print('📦 Body recibido: ${response.body}');
        throw Exception('Error decodificando clientes: $e');
      }
    } else {
      throw Exception('Error al cargar clientes: ${response.statusCode}');
    }
  }

  // ==================== 📱 INVENTARIO INTELIGENTE - KONTROL+ ====================

  /// 🔍 Buscar producto por código de barras
  /// Retorna el producto si existe, null si no se encuentra
  static Future<Producto?> buscarPorCodigoBarras(String codigoBarras) async {
    try {
      print('🔍 Buscando producto con código: $codigoBarras');
      final response = await get('/api/mobile/inventory/barcode/$codigoBarras');
      
      if (response.statusCode == 200) {
        print('✅ Producto encontrado');
        return Producto.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        print('❌ Producto no encontrado');
        return null;
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en buscarPorCodigoBarras: $e');
      rethrow;
    }
  }

  /// 📊 Obtener información completa de stock de un producto
  static Future<InventoryProductResponse> obtenerStockProducto(String productoId) async {
    try {
      print('📊 Obteniendo stock para producto: $productoId');
      final response = await get('/api/mobile/inventory/stock/$productoId');
      
      if (response.statusCode == 200) {
        print('✅ Stock obtenido correctamente');
        return InventoryProductResponse.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Producto no encontrado');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en obtenerStockProducto: $e');
      rethrow;
    }
  }

  /// 📈 Obtener lista de productos con stock bajo
  /// Útil para alertas y reabastecimiento
  static Future<List<LowStockProduct>> obtenerStockBajo() async {
    try {
      print('📈 Obteniendo productos con stock bajo');
      final response = await get('/api/mobile/inventory/low-stock');
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final productos = jsonList.map((json) => LowStockProduct.fromJson(json)).toList();
        print('✅ ${productos.length} productos con stock bajo encontrados');
        return productos;
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en obtenerStockBajo: $e');
      rethrow;
    }
  }

  /// 🔄 Búsqueda flexible por nombre o código de barras
  /// Ideal para búsqueda rápida en la app
  static Future<List<Producto>> buscarProductosFlexible(String termino) async {
    try {
      print('🔄 Búsqueda flexible: $termino');
      final response = await get('/api/mobile/inventory/search/$termino');
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final productos = jsonList.map((json) => Producto.fromJson(json)).toList();
        print('✅ ${productos.length} productos encontrados');
        return productos;
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en buscarProductosFlexible: $e');
      rethrow;
    }
  }

  /// 📋 Contar productos con stock bajo
  /// Para mostrar badge en el dashboard
  static Future<int> contarStockBajo() async {
    try {
      final productos = await obtenerStockBajo();
      return productos.length;
    } catch (e) {
      print('❌ Error contando stock bajo: $e');
      return 0;
    }
  }
}