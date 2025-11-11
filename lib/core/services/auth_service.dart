import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService with ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  Map<String, dynamic>? _currentUser;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get currentUser => _currentUser;

  // Inicializar servicio
  Future<void> initialize() async {
    await ApiService.initialize();
    
    // Verificar si hay token guardado
    if (ApiService.isLoggedIn) {
      try {
        // ✅ RUTA CORREGIDA
        final response = await ApiService.get('/api/mobile/verify-token');
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success'] == true) {
            _isAuthenticated = true;
            _currentUser = data['data'];
            notifyListeners();
          }
        }
      } catch (e) {
        print('❌ Error verificando token: $e');
        await _clearAuthData();
      }
    }
  }

  // Login real con tu API Spring Boot
  Future<Map<String, dynamic>> login(String username, String password) async {
    _setLoading(true);
    
    try {
      // ✅ RUTA CORREGIDA
      final response = await ApiService.post('/api/mobile/login', {
        'username': username,
        'password': password,
      });

      _setLoading(false);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          // Login exitoso
          final token = data['data']['token'];
          await ApiService.setToken(token);
          
          // Guardar datos de usuario
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_data', json.encode(data['data']));
          
          // Actualizar estado
          _isAuthenticated = true;
          _currentUser = data['data'];
          notifyListeners();
          
          return {
            'success': true,
            'message': data['data']['message'] ?? 'Login exitoso',
            'user': data['data'],
          };
        } else {
          // Login fallido
          return {
            'success': false,
            'message': data['message'] ?? 'Credenciales incorrectas',
          };
        }
      } else {
        // Error HTTP
        return {
          'success': false,
          'message': 'Error del servidor: ${response.statusCode}',
        };
      }
    } catch (e) {
      _setLoading(false);
      print('❌ Error en login: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  // Logout
  Future<void> logout() async {
    await _clearAuthData();
    notifyListeners();
  }

  // Limpiar datos de autenticación
  Future<void> _clearAuthData() async {
    _isAuthenticated = false;
    _isLoading = false;
    _currentUser = null;
    await ApiService.clearToken();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    
    print('✅ Sesión cerrada correctamente');
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}