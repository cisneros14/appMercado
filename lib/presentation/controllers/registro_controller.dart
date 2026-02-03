
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/data_sources/remote/auth_remote_datasource.dart';
import '../../data/data_sources/local/auth_local_datasource.dart';

class RegistroController extends GetxController {
  final AuthRepository _authRepository;

  RegistroController()
      : _authRepository = Get.find<AuthRepositoryImpl>();

  // Text Controllers
  final nombresController = TextEditingController();
  final apellidosController = TextEditingController();
  final emailController = TextEditingController();
  final celularController = TextEditingController();
  final matriculaController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  // Observables para Selectors
  final RxString selectedProvincia = ''.obs;
  final RxString selectedCiudad = ''.obs;
  final RxBool aceptoPrivacidad = false.obs;
  
  // File Picker
  final RxString selectedFilePath = ''.obs;
  final RxString selectedFileName = ''.obs;

  // Data
  final RxMap<String, List<String>> provinciasData = <String, List<String>>{}.obs;
  final RxList<String> ciudadesDisponibles = <String>[].obs;

  // State
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    loadProvincias();
  }
  
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  Future<void> loadProvincias() async {
    try {
      isLoading.value = true;
      final data = await _authRepository.getProvincias();
      provinciasData.assignAll(data);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar las provincias: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void onProvinciaChanged(String? newValue) {
    if (newValue != null && provinciasData.containsKey(newValue)) {
      selectedProvincia.value = newValue;
      ciudadesDisponibles.assignAll(provinciasData[newValue]!);
      selectedCiudad.value = ''; // Reset ciudad
    }
  }

  void onCiudadChanged(String? newValue) {
    if (newValue != null) {
      selectedCiudad.value = newValue;
    }
  }

  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        selectedFilePath.value = result.files.single.path!;
        selectedFileName.value = result.files.single.name;
      }
    } catch (e) {
       // Si hay error (ej: permisos denegados)
       Get.snackbar('Error', 'No se pudo seleccionar el archivo: $e', 
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // Validaciones
  String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || !GetUtils.isEmail(value)) {
      return 'Ingrese un correo válido';
    }
    return null;
  }
  
  String? validateCelular(String? value) {
     if (value == null || !RegExp(r'^09[0-9]{8}$').hasMatch(value)) {
      return 'Formato inválido (09XXXXXXXX)';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.length < 2) {
       return 'Mínimo 2 caracteres';
    }
    return null;
  }
  
  String? validateConfirmPassword(String? value) {
    if (value != passwordController.text) {
       return 'Las contraseñas no coinciden';
    }
    return null;
  }

  Future<void> registrar() async {
    if (!formKey.currentState!.validate()) return;
    
    if (selectedProvincia.isEmpty) {
      Get.snackbar('Error', 'Seleccione una provincia', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (selectedCiudad.isEmpty) {
      Get.snackbar('Error', 'Seleccione una ciudad', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (selectedFilePath.isEmpty) {
      Get.snackbar('Error', 'Debe adjuntar su documento (licencia)', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (!aceptoPrivacidad.value) {
      Get.snackbar('Error', 'Debe aceptar las políticas de privacidad', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      
      await _authRepository.registerUser(
        nombres: nombresController.text,
        apellidos: apellidosController.text,
        email: emailController.text,
        celular: celularController.text,
        matricula: matriculaController.text,
        password: passwordController.text,
        provincia: selectedProvincia.value,
        ciudad: selectedCiudad.value,
        aceptoPrivacidad: aceptoPrivacidad.value,
        filePath: selectedFilePath.value,
      );

      // Éxito
      Get.back(); // Volver al login
      Get.snackbar(
        '¡Registro Exitoso!',
        'Revisa tu correo para continuar. Tu cuenta está pendiente de aprobación.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );

    } catch (e) {
      Get.snackbar(
        'Error en Registro',
        e.toString().replaceAll('Exception:', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nombresController.dispose();
    apellidosController.dispose();
    emailController.dispose();
    celularController.dispose();
    matriculaController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
