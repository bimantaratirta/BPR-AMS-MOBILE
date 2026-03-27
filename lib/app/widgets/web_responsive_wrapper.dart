import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bpr_ams/app/common/constant/app_colors.dart';

/// Wrapper yang constrain lebar app ke ukuran mobile saat dibuka di desktop browser.
/// Di mobile/native, child ditampilkan apa adanya tanpa constraint.
class WebResponsiveWrapper extends StatelessWidget {
  final Widget child;

  /// Max width untuk simulasi layar mobile (iPhone 14 Pro Max = 430px)
  static const double maxMobileWidth = 430;

  const WebResponsiveWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Kalau layar sudah kecil (mobile browser), tampilkan apa adanya
        if (constraints.maxWidth <= maxMobileWidth) {
          return child;
        }

        // Desktop browser: center app dengan max width
        return Container(
          color: const Color(0xFFF0F2F5),
          child: Center(
            child: Container(
              width: maxMobileWidth,
              constraints: BoxConstraints(
                maxHeight: constraints.maxHeight,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  size: Size(maxMobileWidth, constraints.maxHeight),
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
