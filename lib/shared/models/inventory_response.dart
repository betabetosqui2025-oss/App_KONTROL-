import 'product_model.dart';

class InventoryProductResponse {
  final Producto producto;
  final int stock;
  final String estado;

  InventoryProductResponse({
    required this.producto,
    required this.stock,
    required this.estado,
  });

  factory InventoryProductResponse.fromJson(Map<String, dynamic> json) {
    return InventoryProductResponse(
      producto: Producto.fromJson(json['producto']),
      stock: json['stock'] ?? 0,
      estado: json['estado'] ?? 'DESCONOCIDO',
    );
  }

  // Método útil para obtener color según estado de stock
  String get estadoTexto {
    switch (estado) {
      case 'AGOTADO':
        return 'Agotado';
      case 'STOCK_BAJO':
        return 'Stock Bajo';
      case 'STOCK_MEDIO':
        return 'Stock Medio';
      case 'STOCK_NORMAL':
        return 'Stock Normal';
      default:
        return 'Desconocido';
    }
  }

  // Método útil para obtener color según estado
  int get nivelUrgencia {
    switch (estado) {
      case 'AGOTADO':
        return 3; // Máxima urgencia - rojo
      case 'STOCK_BAJO':
        return 2; // Urgencia media - naranja
      case 'STOCK_MEDIO':
        return 1; // Baja urgencia - amarillo
      case 'STOCK_NORMAL':
        return 0; // Sin urgencia - verde
      default:
        return -1; // Desconocido
    }
  }
}

class LowStockProduct {
  final Producto producto;
  final int stock;
  final String estado;

  LowStockProduct({
    required this.producto,
    required this.stock,
    required this.estado,
  });

  factory LowStockProduct.fromJson(Map<String, dynamic> json) {
    return LowStockProduct(
      producto: Producto.fromJson(json['producto']),
      stock: json['stock'] ?? 0,
      estado: json['estado'] ?? 'DESCONOCIDO',
    );
  }

  // Método útil para la interfaz
  String get alertaTexto {
    if (stock == 0) return '¡AGOTADO!';
    if (stock < 5) return 'Stock Muy Bajo';
    return 'Stock Bajo';
  }
}