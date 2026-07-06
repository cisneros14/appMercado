import 'dart:developer' as developer;
import 'dart:async';
import 'package:get/get.dart';
import '../../data/data_sources/remote/mired_remote_data_source.dart';

class MiRedController extends GetxController {
  final MiRedRemoteDataSource _remote;

  MiRedController({MiRedRemoteDataSource? remote})
    : _remote = remote ?? MiRedRemoteDataSource();

  final RxList<Map<String, dynamic>> contactos = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> agentes = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> invitaciones =
      <Map<String, dynamic>>[].obs;

  final RxBool isLoadingContactos = false.obs;
  final RxBool isLoadingAgentes = false.obs;
  final RxBool isLoadingInvitaciones = false.obs;
  // Flags para evitar reintentos infinitos si el endpoint falla
  final RxBool agentesLoadFailed = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    await Future.wait([fetchContactos(), fetchAgentes(), fetchInvitaciones()]);
  }

  Future<void> fetchContactos() async {
    try {
      isLoadingContactos.value = true;
      final res = await _remote.getContactos();
      // Algunos endpoints devuelven entradas con 'id' nulo pero con datos (nombre, imagen).
      // Para no ocultar información útil al usuario, incluimos esas entradas marcándolas
      // como 'incompletas' y asignando un id temporal negativo para que la UI pueda listarlas.
      final List<Map<String, dynamic>> parsed = [];
      int syntheticId = -1;
      for (final e in res) {
        final id = e['id'];
        final nombre = (e['nombre'] ?? '').toString().trim();
        if (id != null) {
          parsed.add(Map<String, dynamic>.from(e));
        } else if (nombre.isNotEmpty) {
          final copy = Map<String, dynamic>.from(e);
          copy['id'] = syntheticId; // id temporal
          copy['incompleto'] = true;
          parsed.add(copy);
          syntheticId--;
        } else {
          final telefono = (e['telefono'] ?? '').toString().trim();
          final email = (e['email'] ?? '').toString().trim();
          if (telefono.isNotEmpty || email.isNotEmpty) {
            final copy = Map<String, dynamic>.from(e);
            copy['id'] = syntheticId;
            copy['incompleto'] = true;
            parsed.add(copy);
            syntheticId--;
          }
        }
      }
      developer.log(
        'MiRedController.fetchContactos -> recibidos=${res.length} incluidos=${parsed.length}',
        name: 'MiRedController',
      );
      contactos.assignAll(parsed);
    } catch (e) {
      developer.log('Error fetchContactos: $e', name: 'MiRedController');
    } finally {
      isLoadingContactos.value = false;
    }
  }

  Future<void> fetchAgentes({String? busqueda}) async {
    try {
      agentesLoadFailed.value = false;
      isLoadingAgentes.value = true;
      final res = await _remote.buscarAgentes(busqueda: busqueda);
      agentes.assignAll(res);
    } catch (e) {
      agentesLoadFailed.value = true;
      developer.log('Error fetchAgentes: $e', name: 'MiRedController');
    } finally {
      isLoadingAgentes.value = false;
    }
  }

  Timer? _debounce;

  void onSearchChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchAgentes(busqueda: val);
    });
  }
  
  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
  Future<void> fetchInvitaciones() async {
    try {
      isLoadingInvitaciones.value = true;
      final res = await _remote.getInvitaciones();
      invitaciones.assignAll(res);
    } catch (e) {
      developer.log('Error fetchInvitaciones: $e', name: 'MiRedController');
    } finally {
      isLoadingInvitaciones.value = false;
    }
  }

  Future<bool> enviarInvitacion(int idVendedor) async {
    try {
      final success = await _remote.enviarInvitacion(idVendedor);
      if (success) {
        await fetchAgentes();
      }
      return success;
    } catch (e) {
      developer.log('Error enviarInvitacion: $e', name: 'MiRedController');
      return false;
    }
  }

  Future<bool> aceptarInvitacion(int idMired) async {
    try {
      final success = await _remote.aceptarInvitacion(idMired);
      if (success) {
        await fetchAll();
      }
      return success;
    } catch (e) {
      developer.log('Error aceptarInvitacion: $e', name: 'MiRedController');
      return false;
    }
  }

  Future<bool> rechazarInvitacion(int idMired) async {
    try {
      final success = await _remote.rechazarInvitacion(idMired);
      if (success) {
        await fetchInvitaciones();
      }
      return success;
    } catch (e) {
      developer.log('Error rechazarInvitacion: $e', name: 'MiRedController');
      return false;
    }
  }
}
