import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

import '../../../sesion/user_session.dart';
import '../../../controlador/supervisor/perfil_supervisor_controller.dart';
import '../../../controlador/supervisor/cambio_contra_controller.dart';
import '../../../controlador/auth/foto_perfil_controller.dart';
import '../../../controlador/auth/login_controller.dart';

class PerfilSupervisorPage extends StatefulWidget {
  const PerfilSupervisorPage({super.key});

  @override
  State<PerfilSupervisorPage> createState() => _PerfilSupervisorPageState();
}

class _PerfilSupervisorPageState extends State<PerfilSupervisorPage> {
  final PerfilSupervisorController controller = PerfilSupervisorController();
  final CambioContraController cambioContraController = CambioContraController();
  final FotoPerfilController _fotoController = FotoPerfilController();
  final ImagePicker _imagePicker = ImagePicker();

  late Future<Map<String, dynamic>> futurePerfil;
  bool editMode = false;
  bool showPasswordModal = false;
  String passwordStep = "request";
  bool isLoadingToken = false;
  bool isChangingPassword = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;
  bool isUpdatingFoto = false;

  Map<String, dynamic>? perfilData;

  late TextEditingController nombreController;
  late TextEditingController apellidoController;
  late TextEditingController correoController;
  late TextEditingController telefonoController;

  late TextEditingController tokenController;
  late TextEditingController nuevaContraseaController;
  late TextEditingController confirmarContraseaController;

  String? tokenError;
  String? nuevaContraseaError;
  String? confirmarContraseaError;

  File? _imagenSeleccionada;
  String? _fotoBase64Preparada;

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController();
    apellidoController = TextEditingController();
    correoController = TextEditingController();
    telefonoController = TextEditingController();
    tokenController = TextEditingController();
    nuevaContraseaController = TextEditingController();
    confirmarContraseaController = TextEditingController();

    final idSupervisor = UserSession().idSupervisor!;
    futurePerfil = controller.obtenerPerfilSupervisor(idSupervisor);
  }

  @override
  void dispose() {
    nombreController.dispose();
    apellidoController.dispose();
    correoController.dispose();
    telefonoController.dispose();
    tokenController.dispose();
    nuevaContraseaController.dispose();
    confirmarContraseaController.dispose();
    super.dispose();
  }

  void _loadFormData(Map<String, dynamic> data) {
    nombreController.text = data['nombre'] ?? '';
    apellidoController.text = data['apellido'] ?? '';
    correoController.text = data['correo'] ?? '';
    telefonoController.text = data['telefono'] ?? '';
  }


  Future<void> _seleccionarImagenGaleria() async {
    try {
      final imagen = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (imagen != null) {
        setState(() {
          _imagenSeleccionada = File(imagen.path);
        });
        await _prepararFotoPerfil();
      }
    } catch (e) {
      _mostrarError('Error al seleccionar imagen: $e');
    }
  }

  Future<void> _seleccionarImagenCamara() async {
    try {
      final imagen = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (imagen != null) {
        setState(() {
          _imagenSeleccionada = File(imagen.path);
        });
        await _prepararFotoPerfil();
      }
    } catch (e) {
      _mostrarError('Error al tomar foto: $e');
    }
  }

  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.pop(context);
                  _seleccionarImagenCamara();
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Seleccionar de galería'),
                onTap: () {
                  Navigator.pop(context);
                  _seleccionarImagenGaleria();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _prepararFotoPerfil() async {
    if (_imagenSeleccionada == null) return;

    try {
      final bytes = await _imagenSeleccionada!.readAsBytes();
      _fotoBase64Preparada = base64Encode(bytes);
      print('📸 Foto preparada para guardar: ${_fotoBase64Preparada!.length} bytes');
    } catch (e) {
      _mostrarError("Error al preparar foto: $e");
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _mostrarExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }


  Map<String, bool> _getPasswordValidations() {
    final password = nuevaContraseaController.text;
    return {
      'minLength': password.length >= 8,
      'hasLowercase': password.contains(RegExp(r'[a-z]')),
      'hasUppercase': password.contains(RegExp(r'[A-Z]')),
      'hasNumber': password.contains(RegExp(r'\d')),
      'hasSpecial': password.contains(RegExp(r'[@$!%*#?&]')),
    };
  }

  bool _isPasswordValid() {
    final validations = _getPasswordValidations();
    return validations.values.every((v) => v);
  }


  Future<void> _handleSave() async {
    final nombre = nombreController.text.trim();
    final apellido = apellidoController.text.trim();
    final correo = correoController.text.trim();
    final telefono = telefonoController.text.trim();

    if (nombre.isEmpty || apellido.isEmpty || correo.isEmpty || telefono.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    final soloLetrasRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]{2,50}$');

    if (!soloLetrasRegex.hasMatch(nombre)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre solo debe contener letras (2–50 caracteres)'),
        ),
      );
      return;
    }

    if (!soloLetrasRegex.hasMatch(apellido)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El apellido solo debe contener letras (2–50 caracteres)'),
        ),
      );
      return;
    }

    if (!RegExp(r'^\d{10}$').hasMatch(telefono)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El teléfono debe tener exactamente 10 dígitos'),
        ),
      );
      return;
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(correo)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El correo electrónico no es válido')),
      );
      return;
    }

    final result = await controller.actualizar(
      UserSession().idSupervisor!,
      nombre,
      apellido,
      correo,
      telefono,
    );

    if (!mounted) return;

    if (!result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['mensaje'] ?? 'Error al guardar'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_fotoBase64Preparada != null) {
      final idPersona = UserSession().idPersona;
      if (idPersona != null) {
        print('📤 Subiendo foto para ID Persona: $idPersona');
        final resultado = await _fotoController.actualizarFotoPerfilActual(_fotoBase64Preparada!);

        if (!resultado['success']) {
          _mostrarError("Datos guardados pero hay error con foto: ${resultado['mensaje']}");
        } else {
          print('✅ Foto guardada correctamente');
          perfilData!['foto'] = _fotoBase64Preparada;
        }
      }
    }

    setState(() {
      perfilData!['nombre'] = nombre;
      perfilData!['apellido'] = apellido;
      perfilData!['correo'] = correo;
      perfilData!['telefono'] = telefono;

      if (_fotoBase64Preparada != null) {
        perfilData!['foto'] = _fotoBase64Preparada;
        print('✅ Foto actualizada en UI');
      }

      editMode = false;
      _imagenSeleccionada = null;
      _fotoBase64Preparada = null;
      isUpdatingFoto = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Perfil actualizado correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleCancel() {
    if (perfilData != null) {
      _loadFormData(perfilData!);
    }
    setState(() {
      editMode = false;
      _imagenSeleccionada = null;
      _fotoBase64Preparada = null;
    });
  }


  Future<void> _handleRequestToken() async {
    if (correoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El correo es requerido')),
      );
      return;
    }

    if (perfilData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo identificar el usuario')),
      );
      return;
    }

    setState(() => isLoadingToken = true);

    final result = await cambioContraController.solicitar(
      correoController.text,
      perfilData!['id_persona'],
    );

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token enviado a tu correo'),
          backgroundColor: Colors.green,
        ),
      );

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          isLoadingToken = false;
          passwordStep = "verify";
        });
      }
    } else {
      setState(() => isLoadingToken = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['mensaje'] ?? 'Error al enviar token'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleChangePassword() async {
    setState(() {
      tokenError = null;
      nuevaContraseaError = null;
      confirmarContraseaError = null;
    });

    if (tokenController.text.trim().isEmpty) {
      setState(() => tokenError = "El token es obligatorio");
      return;
    }

    if (nuevaContraseaController.text.trim().isEmpty) {
      setState(() => nuevaContraseaError = "La contraseña es obligatoria");
      return;
    }

    if (confirmarContraseaController.text.trim().isEmpty) {
      setState(() => confirmarContraseaError = "Debes confirmar la contraseña");
      return;
    }

    if (nuevaContraseaController.text.length < 8) {
      setState(() => nuevaContraseaError = "La contraseña debe tener mínimo 8 caracteres");
      return;
    }

    if (!_isPasswordValid()) {
      setState(() => nuevaContraseaError = "La contraseña debe tener mayúsculas, minúsculas, números y caracteres especiales (@\$!%*#?&)");
      return;
    }

    if (nuevaContraseaController.text != confirmarContraseaController.text) {
      setState(() => confirmarContraseaError = "Las contraseñas no coinciden");
      return;
    }

    if (perfilData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo identificar el usuario')),
      );
      return;
    }

    setState(() => isChangingPassword = true);

    try {
      await cambioContraController.confirmar(
        tokenController.text,
        nuevaContraseaController.text,
        perfilData!['id_persona'],
      );

      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contraseña actualizada correctamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      _closePasswordModal();
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '').toLowerCase();

      if (errorMessage.contains('token')) {
        setState(() {
          if (errorMessage.contains('expirado')) {
            tokenError = "El token ha expirado. Solicita uno nuevo";
          } else if (errorMessage.contains('utilizado')) {
            tokenError = "Este token ya fue utilizado";
          } else {
            tokenError = "Token incorrecto o inválido";
          }
        });
      } else if (errorMessage.contains('contraseña') ||
          errorMessage.contains('mayúscula') ||
          errorMessage.contains('minúscula') ||
          errorMessage.contains('número') ||
          errorMessage.contains('caracter')) {
        setState(() => nuevaContraseaError = errorMessage);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => isChangingPassword = false);
    }
  }

  void _closePasswordModal() {
    setState(() {
      showPasswordModal = false;
      passwordStep = "request";
      isLoadingToken = false;
      isChangingPassword = false;
      showNewPassword = false;
      showConfirmPassword = false;
      tokenController.clear();
      nuevaContraseaController.clear();
      confirmarContraseaController.clear();
      tokenError = null;
      nuevaContraseaError = null;
      confirmarContraseaError = null;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futurePerfil,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error al cargar perfil:\n${snapshot.error}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          }

          perfilData = snapshot.data;
          final empresa = perfilData!["empresa"];

          if (!editMode && nombreController.text.isEmpty) {
            _loadFormData(perfilData!);
          }

          return Column(
            children: [
              // HEADER
              Stack(
                children: [
                  Container(
                    height: 140,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xff073375), Color(0xff073375)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  const Positioned(
                    top: 70,
                    left: 0,
                    right: 0,
                    child: Text(
                      "Perfil del Supervisor",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 12,
                    child: IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white, size: 26),
                      onPressed: () async {
                        final confirmar = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Cerrar Sesión'),
                            content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Cerrar Sesión',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirmar == true) {
                          final controller = LoginController();
                          await controller.logout();

                          if (!mounted) return;

                          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ✅ FOTO DE PERFIL CON OPCIÓN DE CAMBIAR
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff073375).withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _imagenSeleccionada != null
                          ? FileImage(_imagenSeleccionada!)
                          : (perfilData!["foto"] != null
                          ? MemoryImage(base64Decode(perfilData!["foto"]))
                          : null),
                      child: (_imagenSeleccionada == null && perfilData!["foto"] == null)
                          ? const Icon(Icons.person, size: 45, color: Color(0xff073375))
                          : null,
                    ),
                  ),
                  if (editMode)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: isUpdatingFoto ? null : _mostrarOpcionesImagen,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xff073375),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: isUpdatingFoto
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              if (!editMode)
                Text(
                  "${perfilData!["nombre"]} ${perfilData!["apellido"]}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff073375),
                  ),
                ),

              if (!editMode)
                Text(
                  perfilData!["correo"],
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),

              if (_imagenSeleccionada != null && editMode)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.check_circle,
                          color: Colors.blue,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Imagen seleccionada",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildInfoCard(
                        title: "Informacion Personal",
                        items: {
                          "Nombre": nombreController,
                          "Apellido": apellidoController,
                          "Correo": correoController,
                          "Telefono": telefonoController,
                          "Direccion": perfilData!["direccion"],
                          "Genero": perfilData!["genero"],
                        },
                      ),

                      _buildPasswordCard(
                        onChangePasswordPressed: _showPasswordModal,
                      ),

                      _buildInfoCard(
                        title: "Informacion Laboral",
                        items: {
                          "Especialidad": perfilData!["especialidad_seguridad"],
                          "Experiencia": "${perfilData!["experiencia"]} anos",
                        },
                      ),

                      _buildInfoCard(
                        title: "Empresa",
                        items: {
                          "Nombre": empresa["nombre"],
                          "RUC": empresa["ruc"],
                          "Direccion": empresa["direccion"],
                          "Telefono": empresa["telefono"],
                        },
                      ),

                      const SizedBox(height: 20),

                      // BOTONES
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (!editMode) ...[
                            const SizedBox(width: 100),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 100,
                              child: ElevatedButton(
                                onPressed: () => setState(() => editMode = true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff073375),
                                ),
                                child: const Text("Editar", style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ] else ...[
                            SizedBox(
                              width: 100,
                              child: ElevatedButton(
                                onPressed: _handleCancel,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade300,
                                ),
                                child: const Text("Cancelar", style: TextStyle(color: Colors.black)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 100,
                              child: ElevatedButton(
                                onPressed: _handleSave,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff073375),
                                ),
                                child: const Text("Guardar", style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required Map<String, dynamic> items,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff073375),
            ),
          ),
          const Divider(),
          ...items.entries.map((e) {
            bool isTextEditingController = e.value is TextEditingController;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      e.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: isTextEditingController && editMode
                        ? TextField(
                      controller: e.value as TextEditingController,
                      inputFormatters: _getInputFormatters(e.key),
                      maxLength: _getMaxLength(e.key),
                      keyboardType: _getKeyboardType(e.key),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    )
                        : Text(
                      isTextEditingController
                          ? (e.value as TextEditingController).text
                          : e.value?.toString() ?? "-",
                      style: const TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  List<TextInputFormatter>? _getInputFormatters(String field) {
    switch (field) {
      case "Nombre":
      case "Apellido":
        return [
          FilteringTextInputFormatter.allow(
            RegExp(r"[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]"),
          ),
        ];
      case "Telefono":
        return [
          FilteringTextInputFormatter.digitsOnly,
        ];
      default:
        return null;
    }
  }

  TextInputType _getKeyboardType(String field) {
    switch (field) {
      case "Telefono":
        return TextInputType.phone;
      case "Correo":
        return TextInputType.emailAddress;
      default:
        return TextInputType.text;
    }
  }

  int? _getMaxLength(String field) {
    switch (field) {
      case "Nombre":
      case "Apellido":
        return 50;
      case "Telefono":
        return 10;
      default:
        return null;
    }
  }

  Widget _buildPasswordCard({required VoidCallback onChangePasswordPressed}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Seguridad",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff073375),
            ),
          ),
          const Divider(),
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Contraseña",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "••••••••",
                      style: TextStyle(color: Colors.black54),
                    ),
                    TextButton(
                      onPressed: onChangePasswordPressed,
                      child: const Text("Cambiar", style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPasswordModal() {
    setState(() {
      showPasswordModal = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: const Text(
                "Cambiar Contraseña",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: isLoadingToken
                    ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 60,
                      width: 60,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Enviando token a tu correo...",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xff073375),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Esto puede tardar unos segundos...",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
                    : passwordStep == "request"
                    ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Se enviará un token de validación a tu correo electrónico para verificar tu identidad.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            "Correo: ",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              correoController.text,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _handleRequestToken();
                          setModalState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff073375),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Enviar Token",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
                    : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Token de Validación",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: tokenController,
                            decoration: InputDecoration(
                              hintText: "Ingresa el token recibido",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              errorText: tokenError,
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.red, width: 1.5),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onChanged: (_) {
                              if (tokenError != null) {
                                setModalState(() {
                                  setState(() => tokenError = null);
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Nueva Contraseña",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: nuevaContraseaController,
                            obscureText: !showNewPassword,
                            decoration: InputDecoration(
                              hintText: "Mínimo 8 caracteres",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              errorText: nuevaContraseaError,
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.red, width: 1.5),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(showNewPassword ? Icons.visibility : Icons.visibility_off),
                                onPressed: () {
                                  setModalState(() {
                                    setState(() => showNewPassword = !showNewPassword);
                                  });
                                },
                              ),
                            ),
                            onChanged: (_) {
                              if (nuevaContraseaError != null) {
                                setModalState(() {
                                  setState(() => nuevaContraseaError = null);
                                });
                              }
                              setModalState(() {});
                            },
                          ),
                          if (nuevaContraseaController.text.isNotEmpty && nuevaContraseaError == null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Column(
                                children: [
                                  _buildPasswordRequirement(
                                    "Mínimo 8 caracteres",
                                    _getPasswordValidations()['minLength']!,
                                  ),
                                  _buildPasswordRequirement(
                                    "Al menos una minúscula",
                                    _getPasswordValidations()['hasLowercase']!,
                                  ),
                                  _buildPasswordRequirement(
                                    "Al menos una mayúscula",
                                    _getPasswordValidations()['hasUppercase']!,
                                  ),
                                  _buildPasswordRequirement(
                                    "Al menos un número",
                                    _getPasswordValidations()['hasNumber']!,
                                  ),
                                  _buildPasswordRequirement(
                                    "Al menos un caracter especial (@\$!%*#?&)",
                                    _getPasswordValidations()['hasSpecial']!,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Confirmar Contraseña",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: confirmarContraseaController,
                            obscureText: !showConfirmPassword,
                            decoration: InputDecoration(
                              hintText: "Repite la contraseña",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              errorText: confirmarContraseaError,
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.red, width: 1.5),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(showConfirmPassword ? Icons.visibility : Icons.visibility_off),
                                onPressed: () {
                                  setModalState(() {
                                    setState(() => showConfirmPassword = !showConfirmPassword);
                                  });
                                },
                              ),
                            ),
                            onChanged: (_) {
                              if (confirmarContraseaError != null) {
                                setModalState(() {
                                  setState(() => confirmarContraseaError = null);
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  setModalState(() {
                                    setState(() {
                                      passwordStep = "request";
                                      tokenController.clear();
                                      nuevaContraseaController.clear();
                                      confirmarContraseaController.clear();
                                      tokenError = null;
                                      nuevaContraseaError = null;
                                      confirmarContraseaError = null;
                                    });
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade300,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  "Atrás",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: isChangingPassword
                                    ? null
                                    : () async {
                                  await _handleChangePassword();
                                  setModalState(() {});
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff073375),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: isChangingPassword
                                    ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    strokeWidth: 2.5,
                                  ),
                                )
                                    : const Text(
                                  "Cambiar Contraseña",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _closePasswordModal();
                  },
                  child: const Text(
                    "Cerrar",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((_) => _closePasswordModal());
  }

  Widget _buildPasswordRequirement(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isValid ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isValid ? Colors.green : Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}