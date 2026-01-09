import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../sesion/user_session.dart';
import '../../../servicios/trabajador_api.dart';
import '../../../controlador/auth/foto_perfil_controller.dart';
import '../../../controlador/supervisor/cambio_contra_controller.dart';
import '../../../controlador/auth/login_controller.dart';

class PerfilTrabajadorPage extends StatefulWidget {
  const PerfilTrabajadorPage({super.key});

  @override
  State<PerfilTrabajadorPage> createState() => _PerfilTrabajadorPageState();
}

class _PerfilTrabajadorPageState extends State<PerfilTrabajadorPage> {
  bool loading = true;
  bool isEditing = false;
  bool isUpdating = false;
  bool isUpdatingFoto = false;
  Map<String, dynamic>? perfil;
  File? _imagenSeleccionada;
  String? _fotoBase64Preparada;

  late TextEditingController nombreController;
  late TextEditingController apellidoController;
  late TextEditingController correoController;
  late TextEditingController telefonoController;
  late TextEditingController cargoController;

  final FotoPerfilController _fotoController = FotoPerfilController();
  final ImagePicker _imagePicker = ImagePicker();

  // =============================
  // VARIABLES PARA CAMBIO DE CONTRASEÑA
  // =============================
  final CambioContraController cambioContraController = CambioContraController();
  bool showPasswordModal = false;
  String passwordStep = "request";
  bool isLoadingToken = false;
  bool isChangingPassword = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;

  late TextEditingController tokenController;
  late TextEditingController nuevaContraseaController;
  late TextEditingController confirmarContraseaController;

  String? tokenError;
  String? nuevaContraseaError;
  String? confirmarContraseaError;

  @override
  void initState() {
    super.initState();
    tokenController = TextEditingController();
    nuevaContraseaController = TextEditingController();
    confirmarContraseaController = TextEditingController();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    final idTrabajador = UserSession().idTrabajador;
    final idPersona = UserSession().idPersona;

    if (idTrabajador == null) return;
    if (idPersona == null) return;

    final data = await TrabajadorApi.obtenerPerfil(idTrabajador);

    if (data.containsKey('foto_base64') && !data.containsKey('fotoBase64')) {
      data['fotoBase64'] = data['foto_base64'];
    }

    setState(() {
      perfil = data;
      _inicializarControllers();
      loading = false;
    });
  }

  void _inicializarControllers() {
    nombreController = TextEditingController(text: perfil!["nombre"] ?? "");
    apellidoController = TextEditingController(text: perfil!["apellido"] ?? "");
    correoController = TextEditingController(text: perfil!["correo"] ?? "");
    telefonoController = TextEditingController(text: perfil!["telefono"] ?? "");
    cargoController = TextEditingController(text: perfil!["cargo"] ?? "");
  }

  void _cancelarEdicion() {
    setState(() {
      isEditing = false;
      _imagenSeleccionada = null;
      _fotoBase64Preparada = null;
      _inicializarControllers();
    });
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

  Future<void> _actualizarFotoPerfil() async {
    if (_imagenSeleccionada == null) {
      _mostrarError("Debes seleccionar una imagen");
      return;
    }

    setState(() => isUpdatingFoto = true);

    try {
      final bytes = await _imagenSeleccionada!.readAsBytes();
      final base64 = base64Encode(bytes);

      final idPersona = UserSession().idPersona;
      if (idPersona == null) {
        _mostrarError("ID de persona no disponible");
        setState(() => isUpdatingFoto = false);
        return;
      }

      print('📤 Actualizando foto para ID Persona: $idPersona');

      final resultado = await _fotoController.actualizarFotoPerfilActual(base64);

      if (resultado['success']) {
        setState(() {
          perfil!["fotoBase64"] = base64;
          _imagenSeleccionada = null;
          isUpdatingFoto = false;
        });

        _mostrarExito("Foto actualizada correctamente");
      } else {
        _mostrarError(resultado['mensaje']);
        setState(() => isUpdatingFoto = false);
      }
    } catch (e) {
      _mostrarError("Error al actualizar foto: $e");
      setState(() => isUpdatingFoto = false);
    }
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

  Future<void> _guardarCambios() async {
    if (!_validarDatos()) return;

    final idTrabajador = UserSession().idTrabajador;
    if (idTrabajador == null) return;

    setState(() => isUpdating = true);

    try {
      await TrabajadorApi.actualizarTrabajador(
        idTrabajador,
        nombre: nombreController.text.trim(),
        apellido: apellidoController.text.trim(),
        correo: correoController.text.trim(),
        telefono: telefonoController.text.trim(),
        cargo: cargoController.text.trim(),
      );

      if (_fotoBase64Preparada != null) {
        final idPersona = UserSession().idPersona;
        if (idPersona != null) {
          print('📤 Subiendo foto para ID Persona: $idPersona');
          final resultado = await _fotoController.actualizarFotoPerfilActual(_fotoBase64Preparada!);

          if (!resultado['success']) {
            _mostrarError("Datos guardados pero hay error con foto: ${resultado['mensaje']}");
          } else {
            print('✅ Foto guardada correctamente');
          }
        }
      }

      await _cargarPerfil();

      setState(() {
        isEditing = false;
        isUpdating = false;
        _imagenSeleccionada = null;
        _fotoBase64Preparada = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✓ Perfil actualizado correctamente"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() => isUpdating = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  bool _validarDatos() {
    if (nombreController.text.trim().isEmpty) {
      _mostrarError("El nombre no puede estar vacío");
      return false;
    }
    if (apellidoController.text.trim().isEmpty) {
      _mostrarError("El apellido no puede estar vacío");
      return false;
    }
    if (correoController.text.trim().isEmpty) {
      _mostrarError("El correo no puede estar vacío");
      return false;
    }
    if (!_esCorreoValido(correoController.text.trim())) {
      _mostrarError("El correo no tiene un formato válido");
      return false;
    }
    if (telefonoController.text.trim().isNotEmpty &&
        telefonoController.text.trim().length != 10) {
      _mostrarError("El teléfono debe tener exactamente 10 dígitos");
      return false;
    }
    if (cargoController.text.trim().isEmpty) {
      _mostrarError("El cargo no puede estar vacío");
      return false;
    }
    return true;
  }

  bool _esCorreoValido(String correo) {
    final regex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[A-Za-z]{2,}$");
    return regex.hasMatch(correo);
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

  // =============================
  // MÉTODOS PARA CAMBIO DE CONTRASEÑA
  // =============================
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

  Future<void> _handleRequestToken() async {
    if (correoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El correo es requerido')),
      );
      return;
    }

    final idPersona = UserSession().idPersona;
    if (idPersona == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo identificar el usuario')),
      );
      return;
    }

    setState(() => isLoadingToken = true);

    final result = await cambioContraController.solicitar(
      correoController.text,
      idPersona,  // ← Usar el valor de sesión
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

    final idPersona = UserSession().idPersona;
    if (idPersona == null) {
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
        idPersona,
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

  @override
  void dispose() {
    nombreController.dispose();
    apellidoController.dispose();
    correoController.dispose();
    telefonoController.dispose();
    cargoController.dispose();
    tokenController.dispose();
    nuevaContraseaController.dispose();
    confirmarContraseaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 110,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xff073375), Color(0xff073375)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(5),
                      bottomRight: Radius.circular(5),
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
                  top: 60,
                  left: 0,
                  right: 0,
                  child: Text(
                    "Perfil del Trabajador",
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
                      // Mostrar diálogo de confirmación
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
                        // Cerrar sesión usando el LoginController
                        final controller = LoginController();
                        await controller.logout();

                        if (!mounted) return;

                        // Redirigir al login eliminando todo el historial
                        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
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
                          radius: 50,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: _imagenSeleccionada != null
                              ? FileImage(_imagenSeleccionada!)
                              : (perfil!["fotoBase64"] != null && perfil!["fotoBase64"].toString().isNotEmpty
                              ? MemoryImage(base64Decode(perfil!["fotoBase64"]))
                              : null),
                          child: (_imagenSeleccionada == null &&
                              (perfil!["fotoBase64"] == null || perfil!["fotoBase64"].toString().isEmpty))
                              ? const Icon(Icons.person, size: 50, color: Color(0xff073375))
                              : null,
                        ),
                      ),
                      if (isEditing)
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

                  const SizedBox(height: 16),

                  Text(
                    "${perfil!["nombre"]} ${perfil!["apellido"]}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff073375),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 6),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xff073375).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      perfil!["correo"],
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xff073375),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  if (_imagenSeleccionada != null && isEditing)
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
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.blue,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            const Text(
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
                ],
              ),
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Información Personal",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff073375),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    icon: Icons.credit_card,
                    label: "Cédula",
                    value: perfil!["cedula"],
                    isEditable: false,
                  ),
                  Divider(color: Colors.grey.withOpacity(0.2)),

                  isEditing
                      ? _buildEditableField(
                    icon: Icons.person,
                    label: "Nombre",
                    controller: nombreController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r"[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]"),
                      ),
                    ],
                    maxLength: 50,
                  )
                      : _buildInfoRow(
                    icon: Icons.person,
                    label: "Nombre",
                    value: perfil!["nombre"],
                    isEditable: false,
                  ),
                  Divider(color: Colors.grey.withOpacity(0.2)),

                  isEditing
                      ? _buildEditableField(
                    icon: Icons.person_outline,
                    label: "Apellido",
                    controller: apellidoController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r"[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]"),
                      ),
                    ],
                    maxLength: 50,
                  )
                      : _buildInfoRow(
                    icon: Icons.person_outline,
                    label: "Apellido",
                    value: perfil!["apellido"],
                    isEditable: false,
                  ),
                  Divider(color: Colors.grey.withOpacity(0.2)),

                  isEditing
                      ? _buildEditableField(
                    icon: Icons.email,
                    label: "Correo",
                    controller: correoController,
                    maxLength: 150,
                    keyboardType: TextInputType.emailAddress,
                  )
                      : _buildInfoRow(
                    icon: Icons.email,
                    label: "Correo",
                    value: perfil!["correo"],
                    isEditable: false,
                  ),
                  Divider(color: Colors.grey.withOpacity(0.2)),

                  isEditing
                      ? _buildEditableField(
                    icon: Icons.phone,
                    label: "Teléfono",
                    controller: telefonoController,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    maxLength: 10,
                    keyboardType: TextInputType.phone,
                  )
                      : _buildInfoRow(
                    icon: Icons.phone,
                    label: "Teléfono",
                    value: perfil!["telefono"] ?? "-",
                    isEditable: false,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // =============================
            // SEGURIDAD (CONTRASEÑA)
            // =============================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Seguridad",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff073375),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xff073375).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.lock,
                      color: Color(0xff073375),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Contraseña",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black45,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "••••••••",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _showPasswordModal,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text(
                      "Cambiar",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Información Laboral",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff073375),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: isEditing
                  ? _buildEditableField(
                icon: Icons.work,
                label: "Cargo",
                controller: cargoController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r"[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]"),
                  ),
                ],
                maxLength: 50,
              )
                  : _buildInfoRow(
                icon: Icons.work,
                label: "Cargo",
                value: perfil!["cargo"],
                isEditable: false,
                isLast: true,
              ),
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Información de Empresa",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff073375),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    icon: Icons.business_center,
                    label: "Nombre Empresa",
                    value: perfil!["empresa"]["nombreEmpresa"],
                    isEditable: false,
                  ),
                  Divider(color: Colors.grey.withOpacity(0.2)),
                  _buildInfoRow(
                    icon: Icons.code,
                    label: "RUC",
                    value: perfil!["empresa"]["ruc"],
                    isEditable: false,
                  ),
                  Divider(color: Colors.grey.withOpacity(0.2)),
                  _buildInfoRow(
                    icon: Icons.category,
                    label: "Sector",
                    value: perfil!["empresa"]["sector"],
                    isEditable: false,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            if (perfil!["zona_asignada"] != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Zona Asignada",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff073375),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 5,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xff073375),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            perfil!["zona_asignada"]["nombreZona"],
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff073375),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildInfoRow(
                      icon: Icons.location_on,
                      label: "Latitud",
                      value: perfil!["zona_asignada"]["latitud"].toString(),
                      isEditable: false,
                    ),
                    const SizedBox(height: 14),
                    _buildInfoRow(
                      icon: Icons.location_on,
                      label: "Longitud",
                      value: perfil!["zona_asignada"]["longitud"].toString(),
                      isEditable: false,
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
            ],

            if (isEditing)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isUpdating ? null : _cancelarEdicion,
                        icon: const Icon(Icons.close),
                        label: const Text("Cancelar"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[400],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isUpdating ? null : _guardarCambios,
                        icon: isUpdating
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : const Icon(Icons.save),
                        label: Text(isUpdating ? "Guardando..." : "Guardar"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff073375),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() => isEditing = true);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Editar Perfil"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff073375),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required dynamic value,
    bool isEditable = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: 12, bottom: isLast ? 0 : 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xff073375).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xff073375),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value?.toString() ?? "-",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xff073375).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xff073375),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          TextField(
            controller: controller,
            enabled: !isUpdating,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            maxLength: maxLength,
            decoration: InputDecoration(
              hintText: "Ingresa $label",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.black12,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.black12,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xff073375),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              counterText: "",
            ),
          ),
        ],
      ),
    );
  }
}