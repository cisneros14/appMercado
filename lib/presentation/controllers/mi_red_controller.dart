import 'dart:developer' as developer;
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
}
