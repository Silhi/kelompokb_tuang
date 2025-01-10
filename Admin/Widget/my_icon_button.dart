import 'package:flutter/material.dart';

class MyIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback pressed;
  final Color backgroundColor;

  const MyIconButton({
    super.key,
    required this.icon,
    required this.pressed,
    this.backgroundColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor, // Terapkan warna latar belakang
        borderRadius: BorderRadius.circular(15), // Radius untuk sudut
      ),
      child: IconButton(
        onPressed: pressed,
        icon: Icon(icon),
        iconSize: 24, // Ukuran ikon
      ),
    );
  }
}
