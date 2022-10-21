// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTitle extends StatelessWidget {
  final String title;
  final TextAlign? textAling;
  AppTitle(this.title, {this.textAling});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: textAling,
      style: GoogleFonts.inter(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
