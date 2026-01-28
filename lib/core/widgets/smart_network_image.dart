import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/image_utils.dart';

/// Widget que intenta cargar varias variantes de una URL de imagen y cae en
/// la siguiente variante si la anterior falla (útil cuando el backend usa
/// rutas inconsistentes entre /admin/img y /images/img).
class SmartNetworkImage extends StatefulWidget {
  final dynamic src;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final Widget? placeholder;

  const SmartNetworkImage({
    super.key,
    required this.src,
    this.fit,
    this.width,
    this.height,
    this.placeholder,
  });

  @override
  State<SmartNetworkImage> createState() => _SmartNetworkImageState();
}

class _SmartNetworkImageState extends State<SmartNetworkImage> {
  List<String> _candidates = [];
  int _idx = 0;

  @override
  void initState() {
    super.initState();
    _candidates = normalizeImageVariants(widget.src);
  }

  @override
  void didUpdateWidget(covariant SmartNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.src != widget.src) {
      setState(() {
        _idx = 0;
        _candidates = normalizeImageVariants(widget.src);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_candidates.isEmpty)
      return widget.placeholder ?? const SizedBox.shrink();

    final url = _candidates[_idx];
    print('🖼️ SmartNetworkImage: Intentando cargar ($_idx/${_candidates.length}): $url');
    
    // Si es una ruta de archivo local (para propiedades recién subidas)
    if (url.startsWith('file:')) {
      final path = url.replaceFirst('file://', '').replaceFirst('file:', '');
      return Image.file(
        File(path),
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        errorBuilder: (context, error, stackTrace) {
          print('❌ SmartNetworkImage: Error en imagen local: $path');
          return widget.placeholder ?? const SizedBox.shrink();
        },
      );
    }

    return Image.network(
      url,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      errorBuilder: (context, error, stackTrace) {
        print('⚠️ SmartNetworkImage: Falló carga de $url');
        // Intentar siguiente variante si existe
        if (_idx < _candidates.length - 1) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              print('🔄 SmartNetworkImage: Probando variante ${_idx + 1}');
              setState(() => _idx++);
            }
          });
          // Mientras tanto, mostrar el placeholder/transición
          return widget.placeholder ?? const SizedBox.shrink();
        }
        print('❌ SmartNetworkImage: Todas las variantes fallaron para ${widget.src}');
        // Ninguna variante funcionó
        return widget.placeholder ?? const SizedBox.shrink();
      },
    );
  }
}
