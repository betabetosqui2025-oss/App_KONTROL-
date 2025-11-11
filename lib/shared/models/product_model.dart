class Producto {
  final String? id;
  final String? nombre;
  final String? descripcion;
  final double? precio;          // ← CAMBIADO: de "precioVenta" a "precio"
  final String? categoria;
  final String? codigoBarras;
  final String? imagenUrl;
  final bool? activo;            // ← NUEVO CAMPO
  // ELIMINADO: stockActual, stockMinimo, precioCompra

  Producto({
    this.id,
    this.nombre,
    this.descripcion,
    this.precio,                 // ← CAMBIADO
    this.categoria,
    this.codigoBarras,
    this.imagenUrl,
    this.activo,                 // ← NUEVO
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id']?.toString(),
      nombre: json['nombre'] ?? 'Sin nombre',
      descripcion: json['descripcion'] ?? '',
      precio: (json['precio'] is double) 
          ? json['precio'] 
          : double.tryParse(json['precio']?.toString() ?? '0') ?? 0.0,
      categoria: json['categoria'] ?? 'General',
      codigoBarras: json['codigoBarras'] ?? '',
      imagenUrl: json['imagenUrl'],
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'categoria': categoria,
      'codigoBarras': codigoBarras,
      'imagenUrl': imagenUrl,
      'activo': activo,
    };
  }

  String get precioFormateado => '\$${precio?.toStringAsFixed(2) ?? '0.00'}';
  
  // NOTA: No hay stockActual en el modelo Spring Boot
  // El stock viene del Inventario (tabla separada)
}