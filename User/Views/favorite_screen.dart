import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:resep_tuang/User/Provider/favorite_provider.dart';
import 'package:resep_tuang/User/Utils/constants.dart';
import 'package:resep_tuang/User/Views/recipe_detail_screen.dart'; // Pastikan untuk mengimpor RecipeDetailScreen
import 'package:iconsax/iconsax.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = FavoriteProvider.of(context);
    final favoriteItems = provider.favorites;

    return Scaffold(
      backgroundColor: kbackgroundColor,
      appBar: AppBar(
        backgroundColor: kbackgroundColor,
        centerTitle: true,
        title: const Text(
          "Favorites",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: favoriteItems.isEmpty
          ? const Center(
              child: Text(
                "No Favorites yet",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : ListView.builder(
              itemCount: favoriteItems.length,
              itemBuilder: (context, index) {
                String favorite = favoriteItems[index];
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection("list-Menu")
                      .doc(favorite)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data == null) {
                      return const Center(
                        child: Text("Error loading favorites"),
                      );
                    }
                    var favoriteItem = snapshot.data!;

                    return GestureDetector(
                      onTap: () {
                        // Navigasi ke RecipeDetailScreen saat item ditekan
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeDetailScreen(
                              documentSnapshot: favoriteItem,
                            ),
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                              ),
                              child: Row(
                                children: [
                                  // Menggunakan Image.network untuk menampilkan gambar
                                  Container(
                                    width: 100,
                                    height: 80,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        favoriteItem['image'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (BuildContext context,
                                            Object error,
                                            StackTrace? stackTrace) {
                                          return const Center(
                                            child: Text(
                                                'Gambar tidak dapat dimuat'),
                                          );
                                        },
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      (loadingProgress
                                                              .expectedTotalBytes ??
                                                          1)
                                                  : null,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        favoriteItem['name'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          const Icon(
                                            Iconsax.flash_1,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          Text(
                                            "${favoriteItem['cal']} Cal",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
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
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            "${favoriteItem['time']} Min",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Tombol untuk menghapus item dari favorit
                          Positioned(
                            top: 50,
                            right: 35,
                            child: GestureDetector(
                              onTap: () {
                                // Menampilkan dialog konfirmasi sebelum menghapus
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Konfirmasi"),
                                      content: const Text(
                                          "Apakah Anda yakin ingin menghapus item ini dari favorit?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Menutup dialog
                                          },
                                          child: const Text("Batal"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              provider
                                                  .toggleFavorite(favoriteItem);
                                            });
                                            Navigator.of(context)
                                                .pop(); // Menutup dialog
                                          },
                                          child: const Text("Hapus"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
