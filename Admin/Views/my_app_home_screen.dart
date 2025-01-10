import 'package:flutter/material.dart';
import 'package:resep_tuang/Admin/Utils/constants.dart';
import 'package:resep_tuang/Admin/Widget/food_items_display.dart';
import 'package:resep_tuang/Admin/Widget/my_icon_button.dart';
import 'package:resep_tuang/Admin/Views/add_menu_screen.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';

class MyAppHomeScreen extends StatefulWidget {
  const MyAppHomeScreen({super.key});

  @override
  State<MyAppHomeScreen> createState() => _MyAppHomeScreenState();
}

class _MyAppHomeScreenState extends State<MyAppHomeScreen> {
  String category = "All";
  final CollectionReference categoriesItems =
      FirebaseFirestore.instance.collection("app-Category");

  Query get filteredRecipes =>
      FirebaseFirestore.instance.collection("list-Menu").where(
            'category',
            isEqualTo: category,
          );
  Query get allRecipes => FirebaseFirestore.instance.collection("list-Menu");
  Query get selectedRecipes => category == "All" ? allRecipes : filteredRecipes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headerParts(),
                    mySearchBar(),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "Categories",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    selectedCategory(),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              StreamBuilder(
                stream: selectedRecipes.snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    final List<DocumentSnapshot> recipes =
                        snapshot.data?.docs ?? [];
                    return Padding(
                      padding:
                          const EdgeInsets.only(top: 5, left: 15, right: 15),
                      child: ListView.separated(
                        itemCount: recipes.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        separatorBuilder: (context, index) =>
                            const Divider(height: 20),
                        itemBuilder: (context, index) {
                          return FoodItemsDisplay(
                              documentSnapshot: recipes[index]);
                        },
                      ),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> selectedCategory() {
    return StreamBuilder(
      stream: categoriesItems.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
        if (streamSnapshot.hasData) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                streamSnapshot.data!.docs.length,
                (index) => GestureDetector(
                  onTap: () {
                    setState(() {
                      category = streamSnapshot.data!.docs[index]['name'];
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color:
                          category == streamSnapshot.data!.docs[index]['name']
                              ? kprimaryColor
                              : Colors.white,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    margin: const EdgeInsets.only(right: 20),
                    child: Text(
                      streamSnapshot.data!.docs[index]['name'],
                      style: TextStyle(
                        color:
                            category == streamSnapshot.data!.docs[index]['name']
                                ? Colors.white
                                : Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Padding mySearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          prefixIcon: const Icon(Iconsax.search_normal),
          fillColor: Colors.white,
          border: InputBorder.none,
          hintText: "Search any recipes",
          hintStyle: const TextStyle(
            color: Colors.grey,
          ),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Row headerParts() {
    return Row(
      children: [
        const Text(
          "Resep Tuang",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
        const Spacer(),
        MyIconButton(
          icon: Iconsax.add,
          pressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddMenuScreen()),
            );
          },
        ),
        MyIconButton(
          icon: Iconsax.additem5,
          pressed: () {
            _showImportDialog(context);
          },
        ),
      ],
    );
  }

  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Import Data Menu'),
          content: const Text(
            'Silakan pilih file CSV untuk mengimpor rincian menu. File CSV harus berisi kolom-kolom berikut:\n'
            '1. Name\n'
            '2. Category\n'
            '3. Ingredients (comma-separated)\n'
            '4. Ingredients Amount (comma-separated)\n'
            '5. Steps (comma-separated)\n'
            '6. Image URL\n'
            '7. Calories\n'
            '8. Time\n'
            '9. Rating\n'
            '10. Reviews',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _importCSV();
              },
              child: const Text('Select CSV'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _importCSV() async {
    try {
      final result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
      if (result != null) {
        final fileBytes = result.files.single.bytes;
        if (fileBytes != null) {
          final csvData = CsvToListConverter()
              .convert(String.fromCharCodes(fileBytes), eol: '\n');

          for (var row in csvData.skip(1)) {
            if (row.length >= 10) {
              await FirebaseFirestore.instance.collection("list-Menu").add({
                'name': row[0],
                'category': row[1],
                'ingredientsName': row[2].split(','),
                'ingredientsAmount': row[3].split(','),
                'steps': row[4].split(','),
                'image': row[5],
                'cal': row[6].toString(),
                'time': int.tryParse(row[7].toString()) ?? 0,
                'rate': row[8].toString(),
                'reviews': int.tryParse(row[9].toString()) ?? 0,
              });
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('CSV file successfully imported!')),
          );
        }
      }
    } catch (e) {
      print("Error importing data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to import csv file.')),
      );
    }
  }
}
