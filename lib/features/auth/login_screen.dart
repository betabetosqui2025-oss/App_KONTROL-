import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_de_ventas/core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = 'admin';
    _passwordController.text = '123456';
  }

  Future<void> _login() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    final result = await authService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 400;

    if (authService.isLoading) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Fondo decorativo (manteniendo tu código original)
          Positioned(
            top: -size.height * 0.15,
            right: -size.width * 0.1,
            child: Container(
              width: size.width * 0.6,
              height: size.width * 0.6,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          Positioned(
            bottom: -size.height * 0.2,
            left: -size.width * 0.1,
            child: Container(
              width: size.width * 0.5,
              height: size.width * 0.5,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              // SOLO CAMBIÉ ESTO: padding adaptativo para móviles
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 24,
              ),
              child: SizedBox(
                height: size.height,
                child: Column(
                  children: [
                    // Espacio superior reducido en móviles
                    SizedBox(height: isSmallScreen ? 20 : 40),

                    // Logo y título
                    _buildHeader(isSmallScreen),

                    const Spacer(),

                    // Formulario con márgenes adaptativos
                    _buildLoginForm(isSmallScreen),

                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Column(
      children: [
        // Logo container con efecto neumórfico
        Container(
          width: isSmallScreen ? 80 : 100,
          height: isSmallScreen ? 80 : 100,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(5, 5),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.9),
                blurRadius: 20,
                offset: const Offset(-5, -5),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logos/app_logo.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.point_of_sale,
                    size: isSmallScreen ? 32 : 40,
                    color: Colors.blue,
                  ),
                );
              },
            ),
          ),
        ),
        
        SizedBox(height: isSmallScreen ? 16 : 24),
        
        // Título principal con tamaño responsive
        Text(
          'Sistema de Ventas',
          style: TextStyle(
            fontSize: isSmallScreen ? 24 : 28,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
            letterSpacing: -0.5,
          ),
        ),
        
        SizedBox(height: isSmallScreen ? 4 : 8),
        
        // Subtítulo con tamaño responsive
        Text(
          'Gestión Profesional de Inventario',
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 0 : 24),
      padding: EdgeInsets.all(isSmallScreen ? 20 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade100,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del formulario con tamaño responsive
          Text(
            'Iniciar Sesión',
            style: TextStyle(
              fontSize: isSmallScreen ? 20 : 22,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 4 : 8),
          
          Text(
            'Ingresa a tu cuenta para continuar',
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 14,
              color: const Color(0xFF64748B),
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 24 : 32),

          // Campo Email
          _buildEmailField(isSmallScreen),

          SizedBox(height: isSmallScreen ? 16 : 20),

          // Campo Contraseña
          _buildPasswordField(isSmallScreen),

          SizedBox(height: isSmallScreen ? 20 : 24),

          // Botón Login
          _buildLoginButton(isSmallScreen),

          SizedBox(height: isSmallScreen ? 20 : 24),

          // Información de demo
          _buildDemoCard(isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildEmailField(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Usuario',
          style: TextStyle(
            fontSize: isSmallScreen ? 13 : 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: _emailController,
            style: TextStyle(
              fontSize: isSmallScreen ? 15 : 16,
              color: const Color(0xFF1F2937),
            ),
            decoration: InputDecoration(
              hintText: 'Ingresa tu usuario',
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                child: Icon(
                  Icons.person_outline,
                  color: const Color(0xFF6B7280),
                  size: isSmallScreen ? 18 : 20,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                borderSide: const BorderSide(
                  color: Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                borderSide: const BorderSide(
                  color: Color(0xFF3B82F6),
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contraseña',
          style: TextStyle(
            fontSize: isSmallScreen ? 13 : 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: TextStyle(
              fontSize: isSmallScreen ? 15 : 16,
              color: const Color(0xFF1F2937),
            ),
            decoration: InputDecoration(
              hintText: 'Ingresa tu contraseña',
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                child: Icon(
                  Icons.lock_outlined,
                  color: const Color(0xFF6B7280),
                  size: isSmallScreen ? 18 : 20,
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword 
                      ? Icons.visibility_outlined 
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFF6B7280),
                  size: isSmallScreen ? 18 : 20,
                ),
                onPressed: _togglePasswordVisibility,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                borderSide: const BorderSide(
                  color: Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                borderSide: const BorderSide(
                  color: Color(0xFF3B82F6),
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(bool isSmallScreen) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: isSmallScreen ? 50 : 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isHovering
                ? [const Color(0xFF2563EB), const Color(0xFF1D4ED8)]
                : [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
          ),
          borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
          boxShadow: _isHovering
              ? [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _login,
            borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Acceder al Sistema',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 15 : 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: _isHovering ? 0.5 : 0.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform: Matrix4.translationValues(
                      _isHovering ? 4 : 0,
                      0,
                      0,
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: isSmallScreen ? 16 : 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoCard(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
        border: Border.all(
          color: const Color(0xFFBAE6FD),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white,
                  size: isSmallScreen ? 14 : 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Credenciales de Prueba',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0369A1),
                  fontSize: isSmallScreen ? 13 : 14,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 13,
                color: const Color(0xFF0C4A6E),
                height: 1.5,
              ),
              children: const [
                TextSpan(
                  text: 'Para acceder al sistema demo usa:\n\n',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                TextSpan(text: '👤 '),
                TextSpan(
                  text: 'Usuario: ',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                TextSpan(text: 'admin\n'),
                TextSpan(text: '🔐 '),
                TextSpan(
                  text: 'Contraseña: ',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                TextSpan(text: '123456'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 1000),
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logos/app_logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F9FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.point_of_sale,
                        size: 32,
                        color: Color(0xFF0EA5E9),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0EA5E9)),
              strokeWidth: 2,
            ),
            const SizedBox(height: 20),
            const Text(
              'Iniciando sesión...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bienvenido al Sistema de Ventas',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}