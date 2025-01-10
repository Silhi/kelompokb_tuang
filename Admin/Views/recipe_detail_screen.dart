import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:resep_tuang/Admin/Widget/my_icon_button.dart';
import 'package:iconsax/iconsax.dart';
import 'edit_menu_screen.dart'; // Import EditMenuScreen

class RecipeDetailScreen extends StatefulWidget {
  final DocumentSnapshot<Object?> documentSnapshot;

  const RecipeDetailScreen({super.key, required this.documentSnapshot});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _deleteRecipe() async {
    // Menghapus dokumen dari Firestore
    await FirebaseFirestore.instance
        .collection('list-Menu')
        .doc(widget.documentSnapshot.id)
        .delete();
    Navigator.pop(context);
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Penghapusan'),
          content: const Text('Apakah Anda yakin ingin menghapus menu ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                _deleteRecipe(); // Panggil fungsi untuk menghapus
                Navigator.of(context).pop(); // Menutup dialog
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                // Menggunakan Image.network untuk menampilkan gambar
                Container(
                  height: MediaQuery.of(context).size.height / 2.1,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                    child: Image.network(
                      widget.documentSnapshot['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext context, Object error,
                          StackTrace? stackTrace) {
                        return const Center(
                          child: Text('Gambar tidak dapat dimuat'),
                        );
                      },
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Tombol kembali
                Positioned(
                  top: 40,
                  left: 10,
                  right: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MyIconButton(
                        icon: Icons.arrow_back_ios_new,
                        backgroundColor: Colors.white,
                        pressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Spacer(),
                      MyIconButton(
                        icon: Iconsax.edit,
                        backgroundColor: Colors.blueGrey.shade100,
                        pressed: () {
                          // Navigasi ke EditMenuScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditMenuScreen(
                                documentSnapshot: widget.documentSnapshot,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: 10),
                      MyIconButton(
                        icon: Iconsax.trash,
                        backgroundColor: Colors.red,
                        pressed: _showDeleteConfirmationDialog,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: MediaQuery.of(context).size.width,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.documentSnapshot['name'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Iconsax.flash_1,
                        size: 20,
                        color: Colors.grey,
                      ),
                      Text(
                        "${widget.documentSnapshot['cal']} Cal",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const Text(
                        " · ",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.grey,
                        ),
                      ),
                      const Icon(
                        Iconsax.clock,
                        size: 20,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "${widget.documentSnapshot['time']} Min",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Rating
                  Row(
                    children: [
                      const Icon(
                        Iconsax.star1,
                        color: Colors.amberAccent,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.documentSnapshot['rate'].toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text("/5"),
                      const SizedBox(width: 5),
                      Text(
                        "${widget.documentSnapshot['reviews']} Reviews",
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Bahan yang diperlukan
                  Text(
                    "Bahan yang diperlukan",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: [
                      Row(
                        children: [
                          // Nama bahan
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: widget.documentSnapshot['ingredientsName']
                                .asMap()
                                .entries
                                .map<Widget>((entry) {
                              int index = entry.key;
                              String ingredient = entry.value;
                              return SizedBox(
                                height: 40,
                                child: Center(
                                  child: Text(
                                    "${index + 1}. $ingredient", // Tambahkan nomor
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          // Jumlah bahan
                          const Spacer(),
                          Column(
                            children: widget
                                .documentSnapshot['ingredientsAmount']
                                .asMap()
                                .entries
                                .map<Widget>((entry) {
                              //int index = entry.key;
                              String amount = entry.value;
                              return SizedBox(
                                height: 40,
                                child: Center(
                                  child: Text(
                                    amount,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Langkah-langkah
                  Text(
                    "Langkah - Langkah",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.documentSnapshot['steps']
                        .asMap()
                        .entries
                        .map<Widget>((entry) {
                      int index = entry.key;
                      String step = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          "${index + 1}. $step",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
