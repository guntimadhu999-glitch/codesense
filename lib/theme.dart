import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central palette + typography for CodeSense.
class AppColors {
  AppColors._();

  static const Color bg = Color(0xFF0D1117);
  static const Color card = Color(0xFF161B22);
  static const Color cyan = Color(0xFF22D3EE);
  static const Color cyanBright = Color(0xFF67E8F9);
  static const Color electricBlue = Color(0xFF3B82F6);
  static const Color textPrimary = Color(0xFFF0F6FC);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFFBBF24);
  static const Color danger = Color(0xFFF87171);

  /// Returns the score colour band used across the app.
  static Color forScore(int score) {
    if (score >= 75) return success;
    if (score >= 50) return warning;
    return danger;
  }
}

class AppTheme {
  AppTheme._();

  static TextStyle ui(
      {double size = 14,
      FontWeight weight = FontWeight.w400,
      Color color = AppColors.textPrimary,
      double? height,
      double? letterSpacing}) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle mono(
      {double size = 13,
      FontWeight weight = FontWeight.w400,
      Color color = AppColors.textPrimary,
      double? height}) {
    return GoogleFonts.jetBrainsMono(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );
  }

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [AppColors.cyan, AppColors.electricBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient midnightGradient = LinearGradient(
    colors: [Color(0xFF0D1117), Color(0xFF161B22), Color(0xFF0B1F2A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.cyan,
        secondary: AppColors.electricBlue,
        surface: AppColors.card,
        error: AppColors.danger,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bg,
        elevation: 0,
        centerTitle: false,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    );
  }
}

/// Slide-from-right page route used for forward navigation.
class SlideRightRoute<T> extends PageRouteBuilder<T> {
  SlideRightRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(curved),
              child: FadeTransition(opacity: curved, child: child),
            );
          },
        );

  final Widget page;
}
