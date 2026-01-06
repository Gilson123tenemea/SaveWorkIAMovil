import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../sesion/user_session.dart';
import '../../../controlador/inspector/inspectores_controller.dart';
import '../../../controlador/auth/foto_perfil_controller.dart';
import '../../../controlador/supervisor/cambio_contra_controller.dart';

class PerfilInspectorPage extends StatefulWidget {
  const PerfilInspectorPage({super.key});

  @override
  State<PerfilInspectorPage> createState() => _PerfilInspectorPageState();
}

class _PerfilInspectorPageState extends State<PerfilInspectorPage> {
  final InspectoresController controller = InspectoresController();
  late Future<Map<String, dynamic>> futurePerfil;

  // Controladores de edición
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();

  // Estado de edición
  bool isEditing = false;
  bool isSaving = false;
  bool isUpdatingFoto = false;
  Map<String, String> errores = {};
  bool _controlersInitialized = false;

  // Variables para foto
  File? _imagenSeleccionada;
  String? _fotoBase64Preparada;
  final FotoPerfilController _fotoController = FotoPerfilController();
  final ImagePicker _imagePicker = ImagePicker();

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
    final idInspector = UserSession().idInspector!;
    tokenController = TextEditingController();
    nuevaContraseaController = TextEditingController();
    confirmarContraseaController = TextEditingController();
    futurePerfil = controller.obtenerPerfilInspector(idInspector);
  }

  @override
  void dispose() {
    super.dispose();
    nombreController.dispose();
    apellidoController.dispose();
    correoController.dispose();
    telefonoController.dispose();
    tokenController.dispose();
    nuevaContraseaController.dispose();
    confirmarContraseaController.dispose();
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
      idPersona,
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

  // =============================
  // MÉTODOS PARA FOTO
  // =============================
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

  // Validar nombre (solo letras y espacios)
  bool _validarNombre(String value) {
    if (value.isEmpty) {
      errores['nombre'] = "El nombre es obligatorio";
      return false;
    }
    if (value.length > 30) {
      errores['nombre'] = "Máximo 30 caracteres";
      return false;
    }
    if (!RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚ\s]+$").hasMatch(value)) {
      errores['nombre'] = "Solo letras permitidas";
      return false;
    }
    errores.remove('nombre');
    return true;
  }

  // Validar apellido (solo letras y espacios)
  bool _validarApellido(String value) {
    if (value.isEmpty) {
      errores['apellido'] = "El apellido es obligatorio";
      return false;
    }
    if (value.length > 30) {
      errores['apellido'] = "Máximo 30 caracteres";
      return false;
    }
    if (!RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚ\s]+$").hasMatch(value)) {
      errores['apellido'] = "Solo letras permitidas";
      return false;
    }
    errores.remove('apellido');
    return true;
  }

  // Validar correo
  bool _validarCorreo(String value) {
    if (value.isEmpty) {
      errores['correo'] = "El correo es obligatorio";
      return false;
    }
    if (value.length > 50) {
      errores['correo'] = "Máximo 50 caracteres";
      return false;
    }
    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
        .hasMatch(value)) {
      errores['correo'] = "Formato de correo inválido";
      return false;
    }
    errores.remove('correo');
    return true;
  }

  // Validar teléfono (solo 10 dígitos)
  bool _validarTelefono(String value) {
    if (value.isEmpty) {
      errores['telefono'] = "El teléfono es obligatorio";
      return false;
    }
    if (!RegExp(r"^\d{10}$").hasMatch(value)) {
      errores['telefono'] = "Solo 10 dígitos permitidos";
      return false;
    }
    errores.remove('telefono');
    return true;
  }

  // Validar todos los campos
  bool _validarTodos() {
    setState(() {
      errores.clear();
      _validarNombre(nombreController.text);
      _validarApellido(apellidoController.text);
      _validarCorreo(correoController.text);
      _validarTelefono(telefonoController.text);
    });
    return errores.isEmpty;
  }

  // Guardar cambios
  void _guardarCambios() async {
    if (!_validarTodos()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Por favor corrige los errores"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final idInspector = UserSession().idInspector!;
      final datos = {
        "nombre": nombreController.text.trim(),
        "apellido": apellidoController.text.trim(),
        "correo": correoController.text.trim(),
        "telefono": telefonoController.text.trim(),
      };

      await controller.actualizarPerfilInspector(idInspector, datos);

      // Subir foto si fue seleccionada
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

      setState(() {
        isEditing = false;
        isSaving = false;
        _imagenSeleccionada = null;
        _fotoBase64Preparada = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Perfil actualizado exitosamente"),
          backgroundColor: Colors.green,
        ),
      );

      // Recargar los datos
      final idInsp = UserSession().idInspector!;
      futurePerfil = controller.obtenerPerfilInspector(idInsp);
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => isSaving = false);
    }
  }

  // Cancelar edición
  void _cancelarEdicion() {
    setState(() {
      isEditing = false;
      _imagenSeleccionada = null;
      _fotoBase64Preparada = null;
      errores.clear();
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
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
            );
          }

          final data = snapshot.data!;

          // Inicializar controladores con datos una sola vez
          if (!_controlersInitialized) {
            nombreController.text = data["nombre"] ?? "";
            apellidoController.text = data["apellido"] ?? "";
            correoController.text = data["correo"] ?? "";
            telefonoController.text = data["telefono"] ?? "";
            _controlersInitialized = true;
          }

          return SingleChildScrollView(
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
                        "Perfil del Inspector",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 30,
                      right: 12,
                      child: IconButton(
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.white,
                          size: 26,
                        ),
                        tooltip: "Cerrar sesión",
                        onPressed: () {
                          UserSession().clear();
                          Navigator.pushReplacementNamed(context, "/login");
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
                                  : (data["fotoBase64"] != null && data["fotoBase64"].toString().isNotEmpty
                                  ? MemoryImage(base64Decode(data["fotoBase64"]))
                                  : null),
                              child: (_imagenSeleccionada == null &&
                                  (data["fotoBase64"] == null || data["fotoBase64"].toString().isEmpty))
                                  ? const Icon(Icons.person,
                                  size: 50, color: Color(0xff073375))
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
                      if (!isEditing)
                        Text(
                          "${data["nombre"]} ${data["apellido"]}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff073375),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      if (!isEditing)
                        const SizedBox(height: 6),
                      if (!isEditing)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xff073375).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            data["correo"],
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
                      // Nombre
                      _buildEditableField(
                        label: "Nombre",
                        controller: nombreController,
                        icon: Icons.person,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r"[a-zA-ZáéíóúÁÉÍÓÚ\s]"))
                        ],
                        maxLength: 30,
                        error: errores['nombre'],
                        onChanged: (_) => _validarNombre(nombreController.text),
                      ),
                      Divider(color: Colors.grey.withOpacity(0.2)),

                      // Apellido
                      _buildEditableField(
                        label: "Apellido",
                        controller: apellidoController,
                        icon: Icons.person,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r"[a-zA-ZáéíóúÁÉÍÓÚ\s]"))
                        ],
                        maxLength: 30,
                        error: errores['apellido'],
                        onChanged: (_) =>
                            _validarApellido(apellidoController.text),
                      ),
                      Divider(color: Colors.grey.withOpacity(0.2)),

                      // Correo
                      _buildEditableField(
                        label: "Correo",
                        controller: correoController,
                        icon: Icons.email,
                        maxLength: 50,
                        error: errores['correo'],
                        onChanged: (_) => _validarCorreo(correoController.text),
                      ),
                      Divider(color: Colors.grey.withOpacity(0.2)),

                      // Teléfono
                      _buildEditableField(
                        label: "Teléfono",
                        controller: telefonoController,
                        icon: Icons.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        maxLength: 10,
                        error: errores['telefono'],
                        onChanged: (_) =>
                            _validarTelefono(telefonoController.text),
                      ),
                      Divider(color: Colors.grey.withOpacity(0.2)),

                      // Información no editable
                      _buildInfoRow(
                        icon: Icons.credit_card,
                        label: "Cédula",
                        value: data["cedula"],
                      ),
                      Divider(color: Colors.grey.withOpacity(0.2)),
                      _buildInfoRow(
                        icon: Icons.location_on,
                        label: "Dirección",
                        value: data["direccion"],
                      ),
                      Divider(color: Colors.grey.withOpacity(0.2)),
                      _buildInfoRow(
                        icon: Icons.person_outline,
                        label: "Género",
                        value: data["genero"],
                      ),
                      Divider(color: Colors.grey.withOpacity(0.2)),
                      _buildInfoRow(
                        icon: Icons.cake,
                        label: "Fecha nacimiento",
                        value: data["fecha_nacimiento"],
                        isLast: true,
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

                const SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Información Profesional",
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
                        icon: Icons.schedule,
                        label: "Frecuencia de visita",
                        value: data["frecuenciaVisita"],
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Botones Editar / Cancelar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // Botón Editar
                      if (!isEditing)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() => isEditing = true);
                            },
                            icon: const Icon(Icons.edit, color: Colors.white),
                            label: const Text(
                              "Editar Perfil",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff073375),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),

                      if (isEditing) ...[
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isSaving ? null : _guardarCambios,
                            icon: isSaving
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : const Icon(Icons.save, color: Colors.white),
                            label: Text(
                              isSaving ? "Guardando..." : "Guardar",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff073375),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isSaving ? null : _cancelarEdicion,
                            icon: const Icon(Icons.close, color: Colors.white),
                            label: const Text(
                              "Cancelar",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[400],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ]

                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Campo editable con validación
  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    List<TextInputFormatter>? inputFormatters,
    int maxLength = 100,
    String? error,
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    const SizedBox(height: 6),
                    if (isEditing)
                      TextField(
                        controller: controller,
                        inputFormatters: inputFormatters,
                        maxLength: maxLength,
                        onChanged: onChanged,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: error != null ? Colors.red : Colors.grey,
                              width: error != null ? 2 : 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: error != null ? Colors.red : Colors.grey,
                              width: error != null ? 2 : 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xff073375),
                              width: 2,
                            ),
                          ),
                          hintText: "Ingrese $label",
                          hintStyle: TextStyle(
                            color: Colors.grey.withOpacity(0.6),
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      Text(
                        controller.text,
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
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 54),
              child: Text(
                error,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Campo solo lectura
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required dynamic value,
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
}