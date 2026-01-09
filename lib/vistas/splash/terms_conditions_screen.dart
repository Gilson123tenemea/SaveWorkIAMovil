import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TermsConditionsScreen extends StatefulWidget {
  const TermsConditionsScreen({Key? key}) : super(key: key);

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen>
    with SingleTickerProviderStateMixin {
  bool _isChecked = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToBottom = false;

  final Color primaryBlue = const Color(0xFF1976D2);
  final Color accentBlue = const Color(0xFF2196F3);
  final Color darkBlue = const Color(0xFF0D47A1);

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _setupScrollListener();
  }

  void _setupAnimation() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _slideController.forward();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50) {
        if (!_hasScrolledToBottom) {
          setState(() {
            _hasScrolledToBottom = true;
          });
        }
      }
    });
  }

  Future<void> _acceptTerms() async {
    if (!_isChecked) {
      _showSnackBar(
        'Debes aceptar los términos y condiciones para continuar',
        Colors.orange,
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('terms_accepted', true);

    print('✅ Términos aceptados - Redirigiendo al login');

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/login');
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 🎯 Header
            _buildHeader(),

            Expanded(
              child: _buildContent(),
            ),

            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo pequeño
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryBlue, accentBlue],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Términos y Condiciones',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: darkBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Save Work IA - Seguridad Industrial',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    '1. Aceptación de los Términos',
                    'Al utilizar SafetyTrack, usted acepta cumplir con estos términos y condiciones. Si no está de acuerdo con alguna parte de estos términos, no debe usar esta aplicación.',
                  ),
                  _buildSection(
                    '2. Propósito de la Aplicación',
                    'SafetyTrack es una herramienta diseñada para la gestión y supervisión de equipos de protección personal (EPP) en entornos industriales. La aplicación permite registrar, monitorear y reportar el uso adecuado de equipos de seguridad.',
                  ),
                  _buildSection(
                    '3. Responsabilidades del Usuario',
                    'Los usuarios se comprometen a:\n\n'
                        '• Proporcionar información veraz y actualizada\n'
                        '• Usar la aplicación únicamente con fines laborales autorizados\n'
                        '• Reportar de manera honesta el estado y uso de equipos de seguridad\n'
                        '• Mantener la confidencialidad de sus credenciales de acceso\n'
                        '• No compartir su cuenta con terceros no autorizados',
                  ),
                  _buildSection(
                    '4. Privacidad y Protección de Datos',
                    'Save Work IA recopila y almacena información relacionada con:\n\n'
                        '• Datos de identificación de trabajadores\n'
                        '• Registros de uso de equipos de protección\n'
                        '• Reportes de incidentes de seguridad\n'
                        '• Fotografías y evidencias relacionadas con seguridad industrial\n\n'
                        'Toda la información recopilada se utiliza exclusivamente para fines de seguridad laboral y cumplimiento de normativas.',
                  ),
                  _buildSection(
                    '5. Seguridad de la Información',
                    'Implementamos medidas de seguridad para proteger sus datos, incluyendo:\n\n'
                        '• Cifrado de datos sensibles\n'
                        '• Autenticación segura de usuarios\n'
                        '• Almacenamiento en servidores protegidos\n'
                        '• Acceso restringido basado en roles',
                  ),
                  _buildSection(
                    '6. Notificaciones y Alertas',
                    'Al usar esta aplicación, usted acepta recibir notificaciones push relacionadas con:\n\n'
                        '• Alertas de seguridad\n'
                        '• Recordatorios de inspecciones\n'
                        '• Reportes de faltas de EPP\n'
                        '• Actualizaciones importantes del sistema',
                  ),
                  _buildSection(
                    '7. Limitación de Responsabilidad',
                    'Save Work IA es una herramienta de apoyo y no reemplaza las responsabilidades legales de la empresa ni del trabajador en materia de seguridad industrial. El uso de esta aplicación no exime del cumplimiento de normativas de seguridad vigentes.',
                  ),
                  _buildSection(
                    '8. Modificaciones a los Términos',
                    'Nos reservamos el derecho de modificar estos términos en cualquier momento. Los cambios serán notificados a través de la aplicación y entrarán en vigencia inmediatamente después de su publicación.',
                  ),
                  _buildSection(
                    '9. Terminación del Servicio',
                    'Nos reservamos el derecho de suspender o terminar el acceso a la aplicación en caso de:\n\n'
                        '• Uso indebido de la plataforma\n'
                        '• Violación de estos términos\n'
                        '• Actividades fraudulentas o ilegales\n'
                        '• Razones técnicas o de mantenimiento',
                  ),
                  _buildSection(
                    '10. Contacto y Soporte',
                    'Para consultas sobre estos términos o sobre el uso de la aplicación, puede contactar al administrador del sistema o al departamento de seguridad industrial de su organización.',
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: primaryBlue.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: primaryBlue, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Última actualización: Enero 2026',
                            style: TextStyle(
                              color: darkBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
            if (!_hasScrolledToBottom)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.grey[50]!.withOpacity(0),
                        Colors.grey[50]!,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: primaryBlue,
                          size: 30,
                        ),
                        Text(
                          'Desliza para leer más',
                          style: TextStyle(
                            color: primaryBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: darkBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Checkbox
          InkWell(
            onTap: () {
              setState(() {
                _isChecked = !_isChecked;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isChecked ? primaryBlue.withOpacity(0.1) : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _isChecked ? primaryBlue : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _isChecked ? primaryBlue : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _isChecked ? primaryBlue : Colors.grey[400]!,
                        width: 2,
                      ),
                    ),
                    child: _isChecked
                        ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'He leído y acepto los términos y condiciones',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _isChecked ? darkBlue : Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _acceptTerms,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isChecked ? primaryBlue : Colors.grey[300],
                foregroundColor: Colors.white,
                elevation: _isChecked ? 2 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Continuar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _isChecked ? Colors.white : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    color: _isChecked ? Colors.white : Colors.grey[500],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}