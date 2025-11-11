class Cliente {
  final String? id;
  final String? nombre;
  final String? apellido;
  final String? numeroDocumento;
  final String? tipoDocumento;
  final String? email;
  final String? telefono;
  final String? direccion;
  final String? ciudad;
  final String? pais;
  final String? notas;
  // ELIMINADO: activo, fechaCreacion

  Cliente({
    this.id,
    this.nombre,
    this.apellido,
    this.numeroDocumento,
    this.tipoDocumento,
    this.email,
    this.telefono,
    this.direccion,
    this.ciudad,
    this.pais,
    this.notas,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id']?.toString(),
      nombre: json['nombre'] ?? 'Sin nombre',
      apellido: json['apellido'] ?? '',
      tipoDocumento: json['tipoDocumento'] ?? 'DNI',
      numeroDocumento: json['numeroDocumento'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? '',
      direccion: json['direccion'] ?? '',
      ciudad: json['ciudad'] ?? '',
      pais: json['pais'] ?? '',
      notas: json['notas'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'tipoDocumento': tipoDocumento,
      'numeroDocumento': numeroDocumento,
      'email': email,
      'telefono': telefono,
      'direccion': direccion,
      'ciudad': ciudad,
      'pais': pais,
      'notas': notas,
    };
  }

  String get nombreCompleto {
    if (nombre != null && apellido != null) {
      return '$nombre $apellido'.trim();
    }
    return nombre ?? apellido ?? 'Cliente';
  }

  String get infoContacto {
    final contactos = [];
    if (telefono?.isNotEmpty == true) contactos.add(telefono);
    if (email?.isNotEmpty == true) contactos.add(email);
    return contactos.join(' • ');
  }
}