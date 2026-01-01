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

    setState(() => isLoadingToken = false);

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
        setState(() => passwordStep = "verify");
      }
    } else {
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
      setState(() => nuevaContraseaError = "La contrasena es obligatoria");
      return;
    }

    if (confirmarContraseaController.text.trim().isEmpty) {
      setState(
              () => confirmarContraseaError = "Debes confirmar la contrasena");
      return;
    }

    if (nuevaContraseaController.text.length < 8) {
      setState(
              () => nuevaContraseaError = "La contrasena debe tener minimo 8 caracteres");
      return;
    }

    if (nuevaContraseaController.text != confirmarContraseaController.text) {
      setState(
              () => confirmarContraseaError = "Las contrasenas no coinciden");
      return;
    }

    if (perfilData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo identificar el usuario')),
      );
      return;
    }

    setState(() => isChangingPassword = true);

    final result = await cambioContraController.confirmar(
      tokenController.text,
      nuevaContraseaController.text,
      perfilData!['id_persona'],
    );

    setState(() => isChangingPassword = false);

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contrasena actualizada correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      _closePasswordModal();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['mensaje'] ?? 'Error al cambiar contrasena'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _closePasswordModal() {
    setState(() {
      showPasswordModal = false;
      passwordStep = "request";
      isLoadingToken = false;
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
                    backgroundImage:
                    perfilData!["foto"] != null
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
                  style:
                  const TextStyle(fontSize: 14, color: Colors.black54),
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
                          "Especialidad":
                          perfilData!["especialidad_seguridad"],
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
                                onPressed: () =>
                                    Navigator.pop(context),
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
                                  backgroundColor:
                                  const Color(0xff073375),
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
                                  backgroundColor:
                                  const Color(0xff073375),
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
            bool isTextEditingController =
            e.value is TextEditingController;

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
                        contentPadding:
                        const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    )
                        : Text(
                      isTextEditingController
                          ? (e.value as TextEditingController)
                          .text
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

  Widget _buildPasswordCard(
      {required VoidCallback onChangePasswordPressed}) {
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
                  "Contrasena",
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
                      child: const Text("Cambiar",
                          style: TextStyle(fontSize: 12)),
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Cambiar Contrasena"),
              content: SizedBox(
                width: double.maxFinite,
                child: isLoadingToken
                    ? const Center(
                  child: CircularProgressIndicator(),
                )
                    : passwordStep == "request"
                    ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                        "Se enviara un token a tu correo electronico"),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        correoController.text,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _handleRequestToken,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xff073375),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text("Enviar Token",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                )
                    : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: tokenController,
                        decoration: InputDecoration(
                          labelText: "Token de Validacion",
                          hintText:
                          "Ingresa el token recibido",
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(8),
                          ),
                          errorText: tokenError,
                        ),
                        onChanged: (_) => setState(() {
                          if (tokenError != null) {
                            tokenError = null;
                          }
                        }),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: nuevaContraseaController,
                        obscureText: !showNewPassword,
                        decoration: InputDecoration(
                          labelText: "Nueva Contrasena",
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(8),
                          ),
                          errorText: nuevaContraseaError,
                          suffixIcon: IconButton(
                            icon: Icon(showNewPassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () => setState(() =>
                            showNewPassword =
                            !showNewPassword),
                          ),
                        ),
                        onChanged: (_) => setState(() {
                          if (nuevaContraseaError != null) {
                            nuevaContraseaError = null;
                          }
                        }),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: confirmarContraseaController,
                        obscureText: !showConfirmPassword,
                        decoration: InputDecoration(
                          labelText: "Confirmar Contrasena",
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(8),
                          ),
                          errorText: confirmarContraseaError,
                          suffixIcon: IconButton(
                            icon: Icon(showConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () => setState(() =>
                            showConfirmPassword =
                            !showConfirmPassword),
                          ),
                        ),
                        onChanged: (_) => setState(() {
                          if (confirmarContraseaError != null) {
                            confirmarContraseaError = null;
                          }
                        }),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => setState(() {
                                passwordStep = "request";
                                tokenController.clear();
                                nuevaContraseaController
                                    .clear();
                                confirmarContraseaController
                                    .clear();
                              }),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                Colors.grey.shade300,
                              ),
                              child: const Text("Atras",
                                  style: TextStyle(
                                      color: Colors.black)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _handleChangePassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                const Color(0xff073375),
                              ),
                              child: isChangingPassword
                                  ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                CircularProgressIndicator(
                                  valueColor:
                                  AlwaysStoppedAnimation<
                                      Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                                  : const Text(
                                "Cambiar Contrasena",
                                style: TextStyle(
                                    color: Colors.white),
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
                  onPressed: _closePasswordModal,
                  child: const Text("Cerrar"),
                ),
              ],
            );
          },
        );
      },
    ).then((_) => _closePasswordModal());
  }
}