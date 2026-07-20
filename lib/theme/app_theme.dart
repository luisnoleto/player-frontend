import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildAppTheme() {
  final theme = FlexColorScheme.light(
    scheme: FlexScheme.deepPurple,
    useMaterial3: true,
  ).toTheme;

  return theme.copyWith(textTheme: GoogleFonts.interTextTheme(theme.textTheme));
}
