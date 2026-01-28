import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/propiedad_entity.dart';
import '../../data/data_sources/remote/propiedad_remote_data_source.dart';
import '../../data/repositories/propiedad_repository_impl.dart';
import '../../core/widgets/smart_network_image.dart';
import '../../core/utils/image_utils.dart';
import '../../core/widgets/screen_header_description.dart';

class SubirPropiedadPage extends StatefulWidget {
  const SubirPropiedadPage({super.key});

  @override
  State<SubirPropiedadPage> createState() => _SubirPropiedadPageState();
}

class _SubirPropiedadPageState extends State<SubirPropiedadPage> {
  late final PropiedadRepositoryImpl _repo;
  final _formKey = GlobalKey<FormState>(debugLabel: 'subirPropiedadFormKey');
  final _picker = ImagePicker();

  // State Variables
  bool _loading = false;
  bool _loadingCatalogs = true;
  PropiedadEntity? _propiedadEdicion;
  bool get _isEdit => _propiedadEdicion != null;

  // Controllers
  final _tituloCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _habitacionesCtrl = TextEditingController();
  final _baniosCtrl = TextEditingController();
  final _nivelesCtrl = TextEditingController();
  final _garageCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _areaLoteCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();

  // Catalog Data
  List<Map<String, dynamic>> _tipos = [];
  List<Map<String, dynamic>> _amenidades = [];
  List<Map<String, dynamic>> _provincias = [];
  List<Map<String, dynamic>> _cantones = [];

  // Form Fields (Remaining state)
  String? _tipoId;
  int _operacion = 1; // 1: Venta, 2: Renta
  String _antiguedad = '';
  String _video = '';
  String? _provinciaId;
  String? _cantonId;
  List<int> _amenidadesSeleccionadas = [];

  // Images
  File? _imagenPrincipal;
  List<File> _galeria = [];
  
  // Existing Images (Edit Mode)
  String? _existingImagenPrincipalUrl;
  List<String> _existingGaleriaUrls = [];

  @override
  void initState() {
    super.initState();
    _repo = PropiedadRepositoryImpl(
      remoteDataSource: PropiedadRemoteDataSource(),
    );
    _propiedadEdicion = Get.arguments as PropiedadEntity?;
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadInitialCatalogs();
    if (_isEdit) {
      await _loadPropiedadForEdit();
    }
  }

  Future<void> _loadPropiedadForEdit() async {
    setState(() => _loadingCatalogs = true);
    try {
      final full = await _repo.obtenerPropiedadPorId(_propiedadEdicion!.id);
      
      // La API de detalle debería devolver IDs en los campos tipo, provincia, canton
      // Pero si no, intentamos mapearlos desde lo que tenemos
      
      setState(() {
        _tituloCtrl.text = full.titulo;
        _descripcionCtrl.text = full.descripcion;
        _precioCtrl.text = full.precio.toString();
        _operacion = full.tipoOperacion.toLowerCase() == 'renta' || full.tipoOperacion.toLowerCase() == 'alquiler' ? 2 : 1;
        _habitacionesCtrl.text = full.habitaciones.toString();
        _baniosCtrl.text = full.banos.toString();
        _areaCtrl.text = full.area.toString();
        _areaLoteCtrl.text = full.areaLote.toString();
        _nivelesCtrl.text = full.niveles.toString();
        _garageCtrl.text = full.garage.toString();
        _antiguedad = full.antiguedad;
        _video = full.video;
        _direccionCtrl.text = full.direccion;
        
        print('🔍 DEBUG - Propiedad Full: ${full.titulo}');
        print('🔍 DEBUG - Tipo: ${full.tipoPropiedad}');
        print('🔍 DEBUG - Provincia: ${full.provincia}');
        print('🔍 DEBUG - Canton: ${full.ciudad}');
        print('🔍 DEBUG - Amenidades: ${full.amenidades}');
        print('🔍 DEBUG - Imagenes: ${full.imagenes}');

        // Cargar amenidades
        // Cargar amenidades
        // Las amenidades pueden venir como IDs o como Nombres, intentamos parsear
        print('🔍 DEBUG - Comenzando match de amenidades. Catalogo size: ${_amenidades.length}');
        _amenidadesSeleccionadas = full.amenidades
            .map((e) {
              final val = e.toString().trim();
              print('🔍 Chequeando amenidad: "$val"');
              
              // 1. Intentar ID directo
              final id = int.tryParse(val);
              if (id != null) {
                // Verificar si existe en el catalogo
                final exists = _amenidades.any((a) => a['id'].toString() == id.toString());
                if (exists) {
                   print('   -> Match por ID directo: $id');
                   return id;
                } else {
                   print('   -> ID $id parseado pero no esta en catalogo actual');
                }
              }
              
              // 2. Buscar por nombre
              final match = _amenidades.firstWhereOrNull((a) => a['nombre'].toString().toLowerCase() == val.toLowerCase());
              if (match != null) {
                final matchId = int.tryParse(match['id'].toString());
                print('   -> Match por Nombre: "${match['nombre']}" -> ID: $matchId');
                return matchId;
              }
              
              print('   -> ❌ Sin match para: "$val"');
              return null;
            })
            .whereType<int>()
            .toList();
        print('🔍 DEBUG - Amenidades Seleccionadas Finales: $_amenidadesSeleccionadas');

        // Cargar imágenes
        if (full.imagenes.isNotEmpty) {
          _existingImagenPrincipalUrl = full.imagenes.first;
          if (full.imagenes.length > 1) {
            _existingGaleriaUrls = full.imagenes.sublist(1);
          }
        }
        
        // Buscar ID Tipo (Case Insensitive y String vs Int check)
        final tipoMatch = _tipos.firstWhereOrNull((t) {
          final tNombre = t['nombre'].toString().toLowerCase().trim();
          final tId = t['id'].toString();
          final pPropiedad = full.tipoPropiedad.toLowerCase().trim();
          // Casuística especial para plurales
          if (tNombre == 'casas' && pPropiedad == 'casa') return true;
          if (tNombre == 'departamentos' && pPropiedad == 'departamento') return true;
          
          return tNombre == pPropiedad || tId == full.tipoPropiedad;
        });
        if (tipoMatch != null) {
          _tipoId = tipoMatch['id'].toString();
          print('✅ Tipo encontrado: $_tipoId');
        } else {
          print('❌ Tipo NO encontrado para: ${full.tipoPropiedad}');
        }

        // Buscar ID Provincia
        final provMatch = _provincias.firstWhereOrNull((p) {
          final pNombre = p['nombre'].toString().toLowerCase();
          final pId = p['id'].toString();
          final fProv = full.provincia.toLowerCase();
          return pNombre == fProv || pId == full.provincia;
        });
        
        if (provMatch != null) {
          _provinciaId = provMatch['id'].toString();
          print('✅ Provincia encontrada: $_provinciaId');
        } else {
          print('❌ Provincia NO encontrada para: ${full.provincia}');
        }
        
        _loadingCatalogs = false;
      });

      // Cargar cantones si hay provincia
      if (_provinciaId != null) {
        // Esperamos a que carguen los cantones
        await _onProvinciaChanged(_provinciaId, resetCanton: false);
        
        // Buscamos el cantón en la lista recién cargada
        final cantonMatch = _cantones.firstWhereOrNull((c) {
           final cNombre = c['nombre'].toString().toLowerCase();
           final cId = c['id'].toString();
           final fCiudad = full.ciudad.toLowerCase();
           return cNombre == fCiudad || cId == full.ciudad;
        });

        if (cantonMatch != null) {
          setState(() => _cantonId = cantonMatch['id'].toString());
          print('✅ Cantón encontrado: $_cantonId');
        } else {
          print('❌ Cantón NO encontrado para: ${full.ciudad}. Disponibles: ${_cantones.map((e) => e['nombre']).toList()}');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo cargar el detalle para editar: $e');
      setState(() => _loadingCatalogs = false);
    }
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _precioCtrl.dispose();
    _habitacionesCtrl.dispose();
    _baniosCtrl.dispose();
    _nivelesCtrl.dispose();
    _garageCtrl.dispose();
    _areaCtrl.dispose();
    _areaLoteCtrl.dispose();
    _direccionCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInitialCatalogs() async {
    setState(() => _loadingCatalogs = true);
    try {
      final results = await Future.wait([
        _repo.obtenerTiposInmueble(),
        _repo.obtenerAmenidades(),
        _repo.obtenerLocalidades(tipo: 'provincias'),
      ]);

      setState(() {
        _tipos = results[0];
        _amenidades = results[1];
        _provincias = results[2];
        _loadingCatalogs = false;
      });
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar los catálogos: $e', 
          backgroundColor: Colors.red, colorText: Colors.white, duration: const Duration(seconds: 5));
      setState(() => _loadingCatalogs = false);
    }
  }

  Future<void> _onProvinciaChanged(String? value, {bool resetCanton = true}) async {
    setState(() {
      _provinciaId = value;
      if (resetCanton) {
        _cantonId = null;
        _cantones = [];
      }
    });
    if (value != null) {
      try {
        final data = await _repo.obtenerLocalidades(tipo: 'cantones', parent: value);
        setState(() => _cantones = data);
      } catch (e) {
        Get.snackbar('Error', 'No se pudieron cargar los cantones');
      }
    }
  }

  Future<void> _pickPrincipal() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imagenPrincipal = File(picked.path));
    }
  }

  Future<void> _pickGaleria() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        _galeria.addAll(picked.map((e) => File(e.path)));
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_provinciaId == null || _cantonId == null || _tipoId == null) {
      Get.snackbar(
        'Campo requerido',
        'Por favor complete todos los campos obligatorios',
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (_imagenPrincipal == null && _existingImagenPrincipalUrl == null) {
      Get.snackbar(
        'Imagen requerida',
        'Debe subir una imagen principal para publicar',
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
        icon: const Icon(Icons.add_a_photo, color: Colors.white),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final datos = {
        if (_isEdit) 'id': _propiedadEdicion!.id,
        'titulo': _tituloCtrl.text,
        'tipo': _tipoId,
        'venta_alquiler': _operacion,
        'precio': double.tryParse(_precioCtrl.text) ?? 0,
        'habitaciones': int.tryParse(_habitacionesCtrl.text) ?? 0,
        'banios': int.tryParse(_baniosCtrl.text) ?? 0,
        'niveles': int.tryParse(_nivelesCtrl.text) ?? 0,
        'garage': int.tryParse(_garageCtrl.text) ?? 0,
        'area': double.tryParse(_areaCtrl.text) ?? 0,
        'area_lote': double.tryParse(_areaLoteCtrl.text) ?? 0,
        'antiguedad': _antiguedad,
        'video': _video,
        'provincia': _provinciaId,
        'canton': _cantonId,
        'direccion': _direccionCtrl.text,
        'descripcion': _descripcionCtrl.text,
        'amenidades': _amenidadesSeleccionadas,
      };

      await _repo.subirPropiedadCompleta(
        datos: datos,
        pathImagenPrincipal: _imagenPrincipal?.path,
        pathsGaleria: _galeria.map((e) => e.path).toList(),
      );

      Get.back(result: true);
      Get.snackbar('Éxito', _isEdit ? 'Propiedad actualizada correctamente' : 'Propiedad publicada correctamente',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar Propiedad' : 'Subir Propiedad'),
        backgroundColor: const Color(0xFF1a2c5b),
        foregroundColor: Colors.white,
      ),
      body: _loadingCatalogs 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ScreenHeaderDescription(
                    title: _isEdit ? 'Editar Propiedad' : 'Publicar Propiedad',
                    description: _isEdit 
                        ? 'Modifique los datos de su propiedad. Los cambios se reflejarán inmediatamente en el catálogo.'
                        : 'Complete el formulario para publicar una nueva propiedad. Asegúrese de incluir fotos de alta calidad.',
                    icon: _isEdit ? Icons.edit_note : Icons.add_home_work,
                  ),
                  _SectionHeader(title: 'Información Básica'),
                  TextFormField(
                    controller: _tituloCtrl,
                    decoration: const InputDecoration(labelText: 'Título del Inmueble (Modelo)'),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requerido';
                      if (v.length < 10) return 'Mínimo 10 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Tipo de Inmueble'),
                    value: _tipoId,
                    items: _tipos.map((e) => DropdownMenuItem(
                      value: e['id'].toString(),
                      child: Text(e['nombre']),
                    )).toList(),
                    onChanged: (v) => setState(() => _tipoId = v),
                    validator: (v) => v == null ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<int>(
                          title: const Text('Venta'),
                          value: 1,
                          groupValue: _operacion,
                          onChanged: (v) => setState(() => _operacion = v!),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<int>(
                          title: const Text('Renta'),
                          value: 2,
                          groupValue: _operacion,
                          onChanged: (v) => setState(() => _operacion = v!),
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: _precioCtrl,
                    decoration: const InputDecoration(labelText: 'Precio', prefixText: '\$'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requerido';
                      if (double.tryParse(v) == null) return 'Solo números';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _SectionHeader(title: 'Ubicación'),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Provincia'),
                    value: _provinciaId,
                    items: _provincias.map((e) => DropdownMenuItem(
                      value: e['id'].toString(),
                      child: Text(e['nombre']),
                    )).toList(),
                    onChanged: _onProvinciaChanged,
                    validator: (v) => v == null ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Cantón'),
                    value: _cantonId,
                    items: _cantones.map((e) => DropdownMenuItem(
                      value: e['id'].toString(),
                      child: Text(e['nombre']),
                    )).toList(),
                    onChanged: (v) => setState(() => _cantonId = v),
                    validator: (v) => v == null ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _direccionCtrl,
                    decoration: const InputDecoration(labelText: 'Dirección Exacta'),
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 24),
                  _SectionHeader(title: 'Características'),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _habitacionesCtrl,
                          decoration: const InputDecoration(labelText: 'Habitaciones'),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                             if (v == null || v.isEmpty) return 'Requerido';
                             if (int.tryParse(v) == null) return 'Solo números enteros';
                             return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _baniosCtrl,
                          decoration: const InputDecoration(labelText: 'Baños'),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                             if (v == null || v.isEmpty) return 'Requerido';
                             if (int.tryParse(v) == null) return 'Solo números enteros';
                             return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _areaCtrl,
                          decoration: const InputDecoration(labelText: 'Área Const. (m²)'),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                             if (v == null || v.isEmpty) return 'Requerido';
                             if (double.tryParse(v) == null) return 'Solo números';
                             return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _areaLoteCtrl,
                          decoration: const InputDecoration(labelText: 'Área Terreno (m²)'),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                             if (v == null || v.isEmpty) return 'Requerido';
                             if (double.tryParse(v) == null) return 'Solo números';
                             return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nivelesCtrl,
                          decoration: const InputDecoration(labelText: 'Niveles'),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                             if (v == null || v.isEmpty) return 'Requerido';
                             if (int.tryParse(v) == null) return 'Solo números enteros';
                             return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _garageCtrl,
                          decoration: const InputDecoration(labelText: 'Garage'),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                             if (v == null || v.isEmpty) return 'Requerido';
                             if (int.tryParse(v) == null) return 'Solo números enteros';
                             return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _SectionHeader(title: 'Amenidades'),
                  Wrap(
                    spacing: 8,
                    children: _amenidades.map((am) {
                      final id = int.parse(am['id'].toString());
                      final selected = _amenidadesSeleccionadas.contains(id);
                      return FilterChip(
                        label: Text(am['nombre']),
                        selected: selected,
                        onSelected: (val) {
                          setState(() {
                            if (val) _amenidadesSeleccionadas.add(id);
                            else _amenidadesSeleccionadas.remove(id);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  _SectionHeader(title: 'Galería de Fotos'),
                  _ImagePickerTile(
                    label: 'Imagen Principal',
                    file: _imagenPrincipal,
                    imageUrl: _existingImagenPrincipalUrl,
                    onTap: _pickPrincipal,
                  ),
                  const SizedBox(height: 12),
                  const Text('Fotos de la Galería', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // Imágenes existentes
                        ..._existingGaleriaUrls.map((url) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Stack(
                            children: [
                              SmartNetworkImage(src: url, width: 100, height: 100, fit: BoxFit.cover),
                              Positioned(
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => setState(() => _existingGaleriaUrls.remove(url)),
                                  child: Container(
                                    color: Colors.black54,
                                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                        // Nuevas imágenes seleccionadas
                        ..._galeria.map((f) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Stack(
                            children: [
                              Image.file(f, width: 100, height: 100, fit: BoxFit.cover),
                              Positioned(
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => setState(() => _galeria.remove(f)),
                                  child: Container(
                                    color: Colors.black54,
                                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                        InkWell(
                          onTap: _pickGaleria,
                          child: Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.add_a_photo, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descripcionCtrl,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    maxLines: 4,
                    validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 32),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                side: const BorderSide(color: Color(0xFF1a2c5b)),
                              ),
                              child: const Text('CANCELAR', style: TextStyle(color: Color(0xFF1a2c5b), fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _loading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1a2c5b),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: _loading 
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text(_isEdit ? 'GUARDAR' : 'PUBLICAR', 
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1a2c5b))),
          const Divider(),
        ],
      ),
    );
  }
}

class _ImagePickerTile extends StatelessWidget {
  final String label;
  final File? file;
  final String? imageUrl;
  final VoidCallback onTap;
  const _ImagePickerTile({required this.label, this.file, this.imageUrl, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: (file != null || (imageUrl != null && imageUrl!.isNotEmpty))
          ? Stack(
              fit: StackFit.expand,
              children: [
                file != null
                  ? Image.file(file!, fit: BoxFit.cover)
                  : SmartNetworkImage(src: imageUrl, fit: BoxFit.cover),
                Container(
                  color: Colors.black12,
                  child: const Center(
                    child: Icon(Icons.camera_alt, color: Colors.white70, size: 40),
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_a_photo, color: Colors.grey, size: 32),
                const SizedBox(height: 4),
                Text(label, style: const TextStyle(color: Colors.grey)),
              ],
            ),
      ),
    );
  }
}
