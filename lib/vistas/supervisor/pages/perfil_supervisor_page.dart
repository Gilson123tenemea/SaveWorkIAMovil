import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../sesion/user_session.dart';
import '../../../controlador/supervisor/perfil_supervisor_controller.dart';
import '../../../controlador/supervisor/cambio_contra_controller.dart';

class PerfilSupervisorPage extends StatefulWidget {
  const PerfilSupervisorPage({super.key});

  @override
  State<PerfilSupervisorPage> createState() => _PerfilSupervisorPageState();
}

class _PerfilSupervisorPageState extends State<PerfilSupervisorPage> {
  final PerfilSupervisorController controller = PerfilSupervisorController();
  final CambioContraController cambioContraController =
  CambioContraController();

  late Future<Map<String, dynamic>> futurePerfil;
  bool editMode = false;
  bool showPasswordModal = false;
  String passwordStep = "request";
  bool isLoadingToken = false;
  bool isChangingPassword = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;

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

  String? selectedImagePath;

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

  // Validaciones de contraseña
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      selectedImagePath = pickedFile.path;

      final bytes = await File(pickedFile.path).readAsBytes();
      final base64Image = base64Encode(bytes);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subiendo foto...')),
      );

      final result = await controller.actualizarFoto(
        perfilData!['id_persona'],
        base64Image,
      );

      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto actualizada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          perfilData!['foto'] = base64Image;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['mensaje'] ?? 'Error al actualizar foto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleSave() async {
    if (nombreController.text.isEmpty ||
        apellidoController.text.isEmpty ||
        correoController.text.isEmpty ||
        telefonoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    if (!correoController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El correo no es valido')),
      );
      return;
    }

    final result = await controller.actualizar(
      UserSession().idSupervisor!,
      nombreController.text,
      apellidoController.text,
      correoController.text,
      telefonoController.text,
    );

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        perfilData!['nombre'] = nombreController.text;
        perfilData!['apellido'] = apellidoController.text;
        perfilData!['correo'] = correoController.text;
        perfilData!['telefono'] = telefonoController.text;
        editMode = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['mensaje'] ?? 'Error al guardar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleCancel() {
    if (perfilData != null) {
      _loadFormData(perfilData!);
    }
    setState(() {
      editMode = false;
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

    // 🔹 Validaciones locales (NO se tocan)
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
      setState(() => nuevaContraseaError =
      "La contraseña debe tener mínimo 8 caracteres");
      return;
    }

    if (!_isPasswordValid()) {
      setState(() => nuevaContraseaError =
      "La contraseña debe tener mayúsculas, minúsculas, números y caracteres especiales (@\$!%*#?&)");
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
      // ✅ SI EL BACKEND FALLA → AQUÍ LANZA EXCEPTION
      await cambioContraController.confirmar(
        tokenController.text,
        nuevaContraseaController.text,
        perfilData!['id_persona'],
      );

      if (!mounted) return;

      // ✅ SOLO SI TODO FUE CORRECTO
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
      final errorMessage =
      e.toString().replaceAll('Exception: ', '').toLowerCase();

      // 🔴 ERRORES DE TOKEN
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
      }

      // 🔴 ERRORES DE CONTRASEÑA
      else if (errorMessage.contains('contraseña') ||
          errorMessage.contains('mayúscula') ||
          errorMessage.contains('minúscula') ||
          errorMessage.contains('número') ||
          errorMessage.contains('caracter')) {
        setState(() => nuevaContraseaError = errorMessage);
      }

      // 🔴 OTROS ERRORES
      else {
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
                      icon: const Icon(Icons.logout,
                          color: Colors.white, size: 26),
                      onPressed: () {
                        UserSession().clear();
                        Navigator.pushReplacementNamed(context, "/login");
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // FOTO + NOMBRE
              Stack(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: perfilData!["foto"] != null
                        ? MemoryImage(base64Decode(perfilData!["foto"]))
                        : null,
                    child: perfilData!["foto"] == null
                        ? const Icon(Icons.person, size: 45)
                        : null,
                  ),
                  if (editMode)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xff073375),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 20),
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

              const SizedBox(height: 20),

              // CONTENIDO
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
                            SizedBox(
                              width: 100,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade300,
                                ),
                                child: const Text("Cerrar",
                                    style: TextStyle(color: Colors.black)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 100,
                              child: ElevatedButton(
                                onPressed: () =>
                                    setState(() => editMode = true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff073375),
                                ),
                                child: const Text("Editar",
                                    style: TextStyle(color: Colors.white)),
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
                                child: const Text("Cancelar",
                                    style: TextStyle(color: Colors.black)),
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
                                child: const Text("Guardar",
                                    style: TextStyle(color: Colors.white)),
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
                      child:
                      const Text("Cambiar", style: TextStyle(fontSize: 12)),
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
                    // Progress Bar
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
                      // TOKEN
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
                                borderRadius:
                                BorderRadius.circular(10),
                              ),
                              errorText: tokenError,
                              errorBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.red, width: 1.5),
                              ),
                              contentPadding:
                              const EdgeInsets.symmetric(
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

                      // NUEVA CONTRASEÑA
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
                                borderRadius:
                                BorderRadius.circular(10),
                              ),
                              errorText: nuevaContraseaError,
                              errorBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.red, width: 1.5),
                              ),
                              contentPadding:
                              const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(showNewPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: () {
                                  setModalState(() {
                                    setState(() =>
                                    showNewPassword =
                                    !showNewPassword);
                                  });
                                },
                              ),
                            ),
                            onChanged: (_) {
                              if (nuevaContraseaError != null) {
                                setModalState(() {
                                  setState(
                                          () => nuevaContraseaError = null);
                                });
                              }
                              setModalState(() {});
                            },
                          ),
                          // Indicadores de requisitos
                          if (nuevaContraseaController.text.isNotEmpty &&
                              nuevaContraseaError == null)
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

                      // CONFIRMAR CONTRASEÑA
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
                                borderRadius:
                                BorderRadius.circular(10),
                              ),
                              errorText: confirmarContraseaError,
                              errorBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.red, width: 1.5),
                              ),
                              contentPadding:
                              const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(showConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: () {
                                  setModalState(() {
                                    setState(() =>
                                    showConfirmPassword =
                                    !showConfirmPassword);
                                  });
                                },
                              ),
                            ),
                            onChanged: (_) {
                              if (confirmarContraseaError != null) {
                                setModalState(() {
                                  setState(() =>
                                  confirmarContraseaError = null);
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // BOTONES
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
                                      confirmarContraseaController
                                          .clear();
                                      tokenError = null;
                                      nuevaContraseaError = null;
                                      confirmarContraseaError = null;
                                    });
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  Colors.grey.shade300,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(10),
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
                                  backgroundColor:
                                  const Color(0xff073375),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(10),
                                  ),
                                ),
                                child: isChangingPassword
                                    ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child:
                                  CircularProgressIndicator(
                                    valueColor:
                                    AlwaysStoppedAnimation<
                                        Color>(
                                      Colors.white,
                                    ),
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