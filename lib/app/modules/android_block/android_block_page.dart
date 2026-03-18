import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AndroidBlockApp extends StatelessWidget {
  const AndroidBlockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BPR AMS',
      theme: ThemeData(
        fontFamily: 'Inter',
        colorSchemeSeed: const Color(0xff1E3A5F),
        brightness: Brightness.light,
      ),
      home: const AndroidBlockPage(),
    );
  }
}

class AndroidBlockPage extends StatelessWidget {
  const AndroidBlockPage({super.key});

  // TODO: Ganti dengan link Play Store yang benar
  static const _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.bpr.ams';

  Future<void> _openPlayStore() async {
    final uri = Uri.parse(_playStoreUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xff1E3A5F).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone_android_rounded,
                    size: 52,
                    color: Color(0xff1E3A5F),
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                const Text(
                  'Gunakan Aplikasi Android',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xff1E3A5F),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  'Perangkat Android terdeteksi.\n'
                  'Silakan gunakan aplikasi BPR AMS yang sudah terinstall '
                  'untuk melakukan absensi.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 36),

                // Download button
                SizedBox(
                  width: size.width * 0.7,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _openPlayStore,
                    icon: const Icon(Icons.download_rounded, size: 22),
                    label: const Text(
                      'Download Aplikasi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1E3A5F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Info text
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xffFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xffFFE082),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 20,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Versi web hanya tersedia untuk pengguna iPhone/iPad.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
