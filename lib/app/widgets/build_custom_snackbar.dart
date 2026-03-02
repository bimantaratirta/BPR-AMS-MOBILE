import 'dart:async';

import 'package:bpr_ams/app/common/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../common/constant/app_assets.dart';

enum CustomSnackbarType { success, warning, error, loading }

class CustomSnackbar {
  final String message;
  final CustomSnackbarType type;

  static final _overlayDuration = const Duration(seconds: 2);
  static OverlayEntry? _currentOverlay;

  CustomSnackbar({required this.message, required this.type});

  void show(BuildContext context) {
    // Tutup overlay aktif
    dismiss();

    try {
      late OverlayEntry entry;
      entry = OverlayEntry(
        builder:
            (context) => _SnackbarOverlay(
              message: message,
              type: type,
              onRemove: () {
                if (entry.mounted) entry.remove();
                if (identical(_currentOverlay, entry)) _currentOverlay = null;
              },
            ),
      );

      _currentOverlay = entry;

      // --- Cari OverlayState yang valid dengan fallback ---
      OverlayState? overlayState =
          Overlay.maybeOf(context, rootOverlay: true) ??
          Navigator.of(context, rootNavigator: true).overlay ??
          (Get.overlayContext != null ? Overlay.maybeOf(Get.overlayContext!, rootOverlay: true) : null);

      if (overlayState == null) {
        // Masih belum ada? Tunda sampai frame berikutnya.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final os =
              Overlay.maybeOf(context, rootOverlay: true) ??
              Navigator.of(context, rootNavigator: true).overlay ??
              (Get.overlayContext != null ? Overlay.maybeOf(Get.overlayContext!, rootOverlay: true) : null);
          os?.insert(entry);
          if (os == null) {
            // Gagal total: bersihkan state agar nggak nyangkut
            _currentOverlay = null;
          }
        });
      } else {
        overlayState.insert(entry);
      }
    } catch (e) {
      // Jika terjadi error, bersihkan state agar nggak nyangkut
      _currentOverlay = null;
    }
  }

  static void dismiss() {
    final entry = _currentOverlay;
    if (entry != null) {
      try {
        if (entry.mounted) entry.remove();
      } catch (_) {
        // ignore
      } finally {
        _currentOverlay = null;
      }
    }
  }
}

class _SnackbarOverlay extends StatefulWidget {
  final String message;
  final CustomSnackbarType type;
  final VoidCallback onRemove;

  const _SnackbarOverlay({required this.message, required this.type, required this.onRemove});

  @override
  State<_SnackbarOverlay> createState() => _SnackbarOverlayState();
}

class _SnackbarOverlayState extends State<_SnackbarOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _autoHideTimer; // Tambahkan timer reference

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300))..forward();

    if (widget.type != CustomSnackbarType.loading) {
      _autoHideTimer = Timer(CustomSnackbar._overlayDuration, () {
        _hide();
      });
    }
  }

  void _hide() {
    if (!mounted) return;
    _controller.reverse().then((_) {
      widget.onRemove();
    });
  }

  @override
  Widget build(BuildContext context) {
    String? icon;
    switch (widget.type) {
      case CustomSnackbarType.success:
        icon = IconAssets.success;
        break;
      case CustomSnackbarType.warning:
        icon = IconAssets.warning;
        break;
      case CustomSnackbarType.error:
        icon = IconAssets.danger;
        break;
      case CustomSnackbarType.loading:
        icon = null;
        break;
    }

    return Positioned(
      top: MediaQuery.of(context).size.height * 0.03,
      left: 0,
      right: 0,
      child: IgnorePointer(
        // Tambahkan ini agar tidak menghalangi interaksi
        ignoring: widget.type != CustomSnackbarType.loading, // Hanya loading yang menghalangi
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: FadeTransition(
              opacity: _controller,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                decoration: BoxDecoration(color: SecondaryColor.blackCharcoal, borderRadius: BorderRadius.circular(50)),
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.type == CustomSnackbarType.loading)
                      SpinKitFadingCircle(color: SecondaryColor.white, size: 25.w)
                    else
                      SvgPicture.asset(icon!, width: 25.w),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        textAlign: TextAlign.center,
                        style: Get.textTheme.labelMedium!.copyWith(color: SecondaryColor.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel(); // Cancel timer sebelum dispose
    _controller.dispose();
    super.dispose();
  }
}
