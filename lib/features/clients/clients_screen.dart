import 'package:flutter/material.dart';
import 'package:sistema_de_ventas/core/services/api_service.dart';
import 'package:sistema_de_ventas/shared/models/cliente_model.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  List<Cliente> _clientes = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  Future<void> _cargarClientes() async {
    try {
      print('🔄 Cargando clientes...');
      final response = await ApiService.obtenerClientesTemp();
      
      // ✅ CASTING A List<Cliente> - IGUAL QUE EN PRODUCTOS
      List<Cliente> clientes = (response).map((item) {
        return Cliente.fromJson(item);
      }).toList();
      
      setState(() {
        _clientes = clientes;
        _isLoading = false;
      });
      
      print('✅ Clientes cargados: ${clientes.length}');
    } catch (e) {
      print('❌ Error cargando clientes: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  List<Cliente> get _filteredClients {
    if (_searchQuery.isEmpty) return _clientes;
    return _clientes.where((cliente) =>
      cliente.nombreCompleto.toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
      cliente.email?.toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
      cliente.telefono?.contains(_searchQuery) == true ||
      cliente.numeroDocumento?.contains(_searchQuery) == true
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarClientes,
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingIndicator()
          : _errorMessage.isNotEmpty
              ? _buildErrorWidget()
              : Column(
                  children: [
                    // Buscador
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar clientes...',
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
                      child: _filteredClients.isEmpty
                          ? _buildEmptyState()
                          : _buildClientList(),
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
          Text('Cargando clientes...'),
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
              'Error al cargar clientes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _cargarClientes,
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
          const Icon(Icons.people_outline, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'No hay clientes' : 'No se encontraron clientes',
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
              onPressed: _cargarClientes,
              child: const Text('Recargar'),
            ),
        ],
      ),
    );
  }

  Widget _buildClientList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _filteredClients.length,
      itemBuilder: (context, index) {
        final cliente = _filteredClients[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          elevation: 2,
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(Icons.person, color: Colors.green),
            ),
            title: Text(
              cliente.nombreCompleto,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                if (cliente.infoContacto.isNotEmpty) Text(cliente.infoContacto),
                if (cliente.direccion?.isNotEmpty == true) Text('Dir: ${cliente.direccion}'),
                if (cliente.numeroDocumento?.isNotEmpty == true) 
                  Text('Doc: ${cliente.tipoDocumento} ${cliente.numeroDocumento}'),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        );
      },
    );
  }
}