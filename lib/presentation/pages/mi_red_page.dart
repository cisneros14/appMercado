import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/mi_red_controller.dart';
import '../../core/utils/image_utils.dart';

class MiRedPage extends StatelessWidget {
  const MiRedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final MiRedController controller = Get.put(MiRedController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mi Red'),
          backgroundColor: const Color(0xFF1a2c5b),
          foregroundColor: Colors.white,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: 'Mis contactos'),
              Tab(text: 'Buscar agentes'),
              Tab(text: 'Invitaciones'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Mis contactos
            Obx(() {
              if (controller.isLoadingContactos.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.contactos.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () => controller.fetchContactos(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 40),
                      _emptyState(
                        icon: Icons.people,
                        title: 'No tienes contactos todavía',
                        subtitle: 'Aún no has agregado contactos a tu red.',
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () => controller.fetchContactos(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: controller.contactos.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final c = controller.contactos[index];
                    final bool incompleto = c['incompleto'] == true;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          normalizeImage(c['imagen']),
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              c['nombre']?.toString().trim().isEmpty == true
                                  ? 'Sin nombre'
                                  : (c['nombre'] ?? 'Sin nombre'),
                            ),
                          ),
                          if (incompleto) ...[
                            const SizedBox(width: 8),
                            const Chip(
                              label: Text(
                                'Incompleto',
                                style: TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Color(0xFFFFF3E0),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if ((c['ciudad'] ?? '').toString().isNotEmpty)
                            Text(c['ciudad']),
                          if ((c['telefono'] ?? '').toString().isNotEmpty)
                            Text(c['telefono']),
                          if ((c['email'] ?? '').toString().isNotEmpty)
                            Text(c['email']),
                        ],
                      ),
                      trailing: Text(
                        c['calificacion'] != null
                            ? '${c['calificacion']['promedio'] ?? ''}'
                            : '',
                      ),
                      onTap: incompleto
                          ? null
                          : () {
                              // Aquí podríamos navegar al detalle del contacto si tiene id válido
                              // TODO: implementar navegación a detalle de contacto
                            },
                    );
                  },
                ),
              );
            }),

            // Buscar agentes
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    onChanged: controller.onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre o email...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    if (!controller.isLoadingAgentes.value &&
                        controller.agentes.isEmpty &&
                        !controller.agentesLoadFailed.value) {
                      Future.microtask(() => controller.fetchAgentes());
                    }

                    if (controller.isLoadingAgentes.value &&
                        controller.agentes.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (controller.agentes.isEmpty) {
                      if (controller.agentesLoadFailed.value) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _emptyState(
                                icon: Icons.error,
                                title: 'Error al cargar agentes',
                                subtitle:
                                    'No fue posible conectar con el servidor. Intenta de nuevo.',
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () => controller.fetchAgentes(),
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () => controller.fetchAgentes(),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 40),
                            _emptyState(
                              icon: Icons.search,
                              title: 'No se encontraron agentes',
                              subtitle:
                                  'Intenta con otra búsqueda o revisa más tarde.',
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => controller.fetchAgentes(),
                      child: ListView.separated(
                        padding: const EdgeInsets.only(
                          left: 12,
                          right: 12,
                          bottom: 12,
                          top: 0,
                        ),
                        itemCount: controller.agentes.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final a = controller.agentes[index];
                          final bool yaInvitado = a['ya_invitado'] == true;
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 4,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Colors.grey[200],
                                    backgroundImage: NetworkImage(
                                      normalizeImage(a['imagen']),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          a['nombre'] ?? 'Sin nombre',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Color(0xFF1a2c5b),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        if (a['ciudad'] != null)
                                          Text(
                                            a['ciudad'],
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        if (a['telefono'] != null)
                                          Text(
                                            a['telefono'],
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        if (a['email'] != null)
                                          Text(
                                            a['email'],
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (yaInvitado)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.green),
                                      ),
                                      child: const Text(
                                        'Invitado',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  else
                                    SizedBox(
                                      height: 36,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF1a2c5b,
                                          ),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          elevation: 0,
                                        ),
                                        onPressed: () async {
                                          final idAgente = int.tryParse(a['id']?.toString() ?? '') ?? 0;
                                          if (idAgente > 0) {
                                            final success = await controller.enviarInvitacion(idAgente);
                                            if (success) {
                                              Get.snackbar(
                                                'Éxito',
                                                'Invitación enviada con éxito',
                                                snackPosition: SnackPosition.BOTTOM,
                                                backgroundColor: Colors.green,
                                                colorText: Colors.white,
                                              );
                                            } else {
                                              Get.snackbar(
                                                'Error',
                                                'No se pudo enviar la invitación',
                                                snackPosition: SnackPosition.BOTTOM,
                                                backgroundColor: Colors.red,
                                                colorText: Colors.white,
                                              );
                                            }
                                          }
                                        },
                                        child: const Text(
                                          'Invitar',
                                          style: TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),

            // Invitaciones
            Obx(() {
              if (controller.isLoadingInvitaciones.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.invitaciones.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () => controller.fetchInvitaciones(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 40),
                      _emptyState(
                        icon: Icons.mail_outline,
                        title: 'No tienes invitaciones todavía',
                        subtitle: 'Cuando alguien te invite, aparecerá aquí.',
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () => controller.fetchInvitaciones(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: controller.invitaciones.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final inv = controller.invitaciones[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          normalizeImage(inv['imagen']),
                        ),
                      ),
                      title: Text(inv['nombre'] ?? 'Sin nombre'),
                      subtitle: Text(inv['fecha_invitacion'] ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () async {
                              final idMired = int.tryParse(inv['id_mired']?.toString() ?? '') ?? 0;
                              if (idMired > 0) {
                                final success = await controller.aceptarInvitacion(idMired);
                                if (success) {
                                  Get.snackbar(
                                    'Éxito',
                                    'Invitación aceptada',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                  );
                                }
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () async {
                              final idMired = int.tryParse(inv['id_mired']?.toString() ?? '') ?? 0;
                              if (idMired > 0) {
                                final success = await controller.rechazarInvitacion(idMired);
                                if (success) {
                                  Get.snackbar(
                                    'Éxito',
                                    'Invitación rechazada',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.orange,
                                    colorText: Colors.white,
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // image normalization moved to `lib/core/utils/image_utils.dart`

  /// Widget reutilizable para estado vacío estilizado
  Widget _emptyState({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFF1a2c5b).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: const Color(0xFF1a2c5b)),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a2c5b),
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
