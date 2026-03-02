import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constant/app_colors.dart';

class AppTheme {
  static ThemeData getTheme() {
    const Color primaryColor = MainColor.blue5;
    final Map<int, Color> primaryColorMap = {
      50: primaryColor,
      100: primaryColor,
      200: primaryColor,
      300: primaryColor,
      400: primaryColor,
      500: primaryColor,
      600: primaryColor,
      700: primaryColor,
      800: primaryColor,
      900: primaryColor,
    };
    final MaterialColor primaryMaterialColor = MaterialColor(primaryColor.value, primaryColorMap);

    return ThemeData(
      visualDensity: VisualDensity.adaptivePlatformDensity,
      useMaterial3: true,
      primaryColor: primaryColor,
      primarySwatch: primaryMaterialColor,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      appBarTheme: AppBarTheme(
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(color: SecondaryColor.fontColour, fontSize: 18.sp, fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: MainColor.blue5,
          disabledBackgroundColor: SecondaryColor.neutral500,
          minimumSize: Size(double.infinity, 40.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(color: SecondaryColor.fontColour, fontSize: 30.sp),
        displayMedium: GoogleFonts.poppins(color: SecondaryColor.fontColour, fontSize: 25.sp),
        displaySmall: GoogleFonts.poppins(color: SecondaryColor.fontColour, fontSize: 20.sp),
        titleLarge: GoogleFonts.poppins(color: SecondaryColor.fontColour, fontSize: 20.sp),
        titleMedium: GoogleFonts.poppins(color: SecondaryColor.fontColour, fontSize: 15.sp),
        titleSmall: GoogleFonts.poppins(color: SecondaryColor.fontColour, fontSize: 12.sp),
        bodyLarge: GoogleFonts.poppins(color: SecondaryColor.fontColour, fontSize: 15.sp),
        bodyMedium: GoogleFonts.poppins(color: SecondaryColor.fontColour, fontSize: 12.sp),
        bodySmall: GoogleFonts.poppins(color: SecondaryColor.fontColour, fontSize: 8.sp),
        labelLarge: GoogleFonts.poppins(color: SecondaryColor.fontColour, fontSize: 15.sp),
        labelMedium: GoogleFonts.poppins(color: SecondaryColor.fontColour, fontSize: 12.sp),
        labelSmall: GoogleFonts.poppins(color: SecondaryColor.fontColour, fontSize: 8.sp),
      ),
    );
  }
}
