
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/registro_controller.dart';

class RegistroPage extends StatelessWidget {
  const RegistroPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject controller
    final controller = Get.put(RegistroController());

    return Scaffold(
      backgroundColor: const Color(0xFF1a2c5b),
      appBar: AppBar(
        title: const Text('Registro de Asesor', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Crea tu cuenta',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Únete a la plataforma para asesores inmobiliarios.',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 24),
              
              Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    // Nombres
                    _buildTextField(
                      controller: controller.nombresController,
                      label: 'Nombres',
                      icon: Icons.person_outline,
                      validator: controller.validateRequired,
                    ),
                    const SizedBox(height: 16),
                    // Apellidos
                    _buildTextField(
                      controller: controller.apellidosController,
                      label: 'Apellidos',
                      icon: Icons.person,
                      validator: controller.validateRequired,
                    ),
                    const SizedBox(height: 16),
                    // Email
                    _buildTextField(
                      controller: controller.emailController,
                      label: 'Correo Electrónico',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: controller.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    // Celular
                    _buildTextField(
                      controller: controller.celularController,
                      label: 'Celular (09XXXXXXXX)',
                      icon: Icons.phone_android,
                      keyboardType: TextInputType.phone,
                      validator: controller.validateCelular,
                    ),
                    const SizedBox(height: 16),
                    // Matrícula
                    _buildTextField(
                      controller: controller.matriculaController,
                      label: 'Cód. Licencia / Matrícula',
                      icon: Icons.badge_outlined,
                      validator: controller.validateRequired,
                    ),
                    const SizedBox(height: 16),
                    
                    // Provincia (Dropdown)
                    Obx(() => _buildDropdown(
                      label: 'Provincia',
                      value: controller.selectedProvincia.value.isEmpty ? null : controller.selectedProvincia.value,
                      items: controller.provinciasData.keys.toList(),
                      onChanged: controller.onProvinciaChanged,
                      isLoading: controller.isLoading.value && controller.provinciasData.isEmpty,
                    )),
                    const SizedBox(height: 16),
                    
                    // Ciudad (Dropdown)
                    Obx(() => _buildDropdown(
                      label: 'Ciudad',
                      value: controller.selectedCiudad.value.isEmpty ? null : controller.selectedCiudad.value,
                      items: controller.ciudadesDisponibles,
                      onChanged: controller.onCiudadChanged,
                      enabled: controller.selectedProvincia.isNotEmpty,
                    )),
                    const SizedBox(height: 16),

                    // Password
                    Obx(() => _buildTextField(
                      controller: controller.passwordController,
                      label: 'Contraseña',
                      icon: Icons.lock_outline,
                      obscureText: !controller.isPasswordVisible.value,
                      validator: controller.validatePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isPasswordVisible.value ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                    )),
                    const SizedBox(height: 16),
                    // Confirm Password
                    Obx(() => _buildTextField(
                      controller: controller.confirmPasswordController,
                      label: 'Confirmar Contraseña',
                      icon: Icons.lock,
                      obscureText: !controller.isConfirmPasswordVisible.value,
                      validator: controller.validateConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isConfirmPasswordVisible.value ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: controller.toggleConfirmPasswordVisibility,
                      ),
                    )),
                    const SizedBox(height: 24),
                    
                    // Documento Picker
                    const Text(
                      'Documento Habilitante (Licencia/Certificado)',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => InkWell(
                      onTap: controller.pickFile,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white70, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withOpacity(0.05),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              controller.selectedFilePath.isEmpty ? Icons.cloud_upload_outlined : Icons.check_circle,
                              color: controller.selectedFilePath.isEmpty ? Colors.white70 : Colors.green,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                controller.selectedFileName.isEmpty 
                                    ? 'Subir Foto del Documento' 
                                    : controller.selectedFileName.value,
                                style: const TextStyle(color: Colors.white70),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                    const SizedBox(height: 24),
                    
                    // Checkbox Privacidad
                    Obx(() => Row(
                      children: [
                        Checkbox(
                          value: controller.aceptoPrivacidad.value,
                          onChanged: (v) => controller.aceptoPrivacidad.value = v ?? false,
                          fillColor: MaterialStateProperty.all(Colors.white),
                          checkColor: const Color(0xFF1a2c5b),
                        ),
                        const Expanded(
                          child: Text(
                            'Acepto las políticas de privacidad y términos de uso.',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ),
                      ],
                    )),

                    const SizedBox(height: 32),
                    
                    // Botón Registrar
                    Obx(() => SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value ? null : controller.registrar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1a2c5b),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: controller.isLoading.value 
                          ? const SizedBox(
                              width: 24, height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Color(0xFF1a2c5b))),
                            )
                          : const Text('REGISTRARME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    )),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white, width: 2)),
        errorStyle: const TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool isLoading = false,
    bool enabled = true,
  }) {
    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : null,
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        labelText: isLoading ? 'Cargando $label...' : label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(Icons.location_on_outlined, color: enabled ? Colors.white70 : Colors.white30),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
      ),
      style: const TextStyle(color: Colors.white),
      dropdownColor: const Color(0xFF1a2c5b),
      iconEnabledColor: Colors.white,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      validator: (v) => v == null ? 'Seleccione una opción' : null,
    );
  }
}
