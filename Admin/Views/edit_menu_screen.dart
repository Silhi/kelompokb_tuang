import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resep_tuang/Admin/Utils/validator.dart'; // Import validator

class EditMenuScreen extends StatefulWidget {
  final DocumentSnapshot<Object?> documentSnapshot;

  const EditMenuScreen({Key? key, required this.documentSnapshot})
      : super(key: key);

  @override
  _EditMenuScreenState createState() => _EditMenuScreenState();
}

class _EditMenuScreenState extends State<EditMenuScreen> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String rate = '';
  String reviews = '';
  int time = 0; // Change type to int
  String cal = '';
  String category = 'Meat'; // Default category
  String image = '';
  List<String> ingredientsName = [];
  List<String> ingredientsAmount = [];
  List<String> steps = [];

  final TextEditingController _ingredientNameController =
      TextEditingController();
  final TextEditingController _ingredientAmountController =
      TextEditingController();
  final TextEditingController _stepController = TextEditingController();
  final TextEditingController _timeController =
      TextEditingController(); // Controller for time input

  @override
  void initState() {
    super.initState();
    // Initialize fields with data from Firestore
    name = widget.documentSnapshot['name'];
    rate = widget.documentSnapshot['rate'].toString();
    reviews = widget.documentSnapshot['reviews'].toString();
    time = widget.documentSnapshot['time']; // Use int for time
    cal = widget.documentSnapshot['cal'];
    category = widget.documentSnapshot['category'];
    image = widget.documentSnapshot['image'];
    ingredientsName =
        List<String>.from(widget.documentSnapshot['ingredientsName']);
    ingredientsAmount =
        List<String>.from(widget.documentSnapshot['ingredientsAmount']);
    steps = List<String>.from(widget.documentSnapshot['steps']);
    _timeController.text = _convertTimeToString(time); // Set initial time value
  }

  String _convertTimeToString(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  Future<void> _selectTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );

    if (pickedTime != null) {
      int totalMinutes = pickedTime.hour * 60 + pickedTime.minute;
      setState(() {
        time = totalMinutes; // Update time in minutes
        _timeController.text =
            _convertTimeToString(totalMinutes); // Update the controller
      });
    }
  }

  void _addIngredient() {
    setState(() {
      ingredientsName.add(_ingredientNameController.text);
      ingredientsAmount.add(_ingredientAmountController.text);
      _ingredientNameController.clear();
      _ingredientAmountController.clear();
    });
  }

  void _addStep() {
    setState(() {
      steps.add(_stepController.text);
      _stepController.clear();
    });
  }

  void _editIngredient(int index) {
    _ingredientNameController.text = ingredientsName[index];
    _ingredientAmountController.text = ingredientsAmount[index];
    _showIngredientDialog(index);
  }

  void _showIngredientDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Bahan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _ingredientNameController,
                decoration: InputDecoration(labelText: 'Nama Bahan'),
              ),
              TextField(
                controller: _ingredientAmountController,
                decoration: InputDecoration(labelText: 'Jumlah Bahan'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  ingredientsName[index] = _ingredientNameController.text;
                  ingredientsAmount[index] = _ingredientAmountController.text;
                });
                Navigator.of(context).pop();
              },
              child: Text('Simpan'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  void _deleteIngredient(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Anda yakin ingin menghapus bahan ini?'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  ingredientsName.removeAt(index);
                  ingredientsAmount.removeAt(index);
                });
                Navigator.of(context).pop();
              },
              child: Text('Ya'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Tidak'),
            ),
          ],
        );
      },
    );
  }

  void _editStep(int index) {
    _stepController.text = steps[index];
    _showStepDialog(index);
  }

  void _showStepDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Langkah-Langkah'),
          content: TextField(
            controller: _stepController,
            decoration: InputDecoration(labelText: 'Langkah-Langkah'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  steps[index] = _stepController.text;
                });
                Navigator.of(context).pop();
              },
              child: Text('Simpan'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  void _deleteStep(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Anda yakin ingin menghapus langkah ini?'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  steps.removeAt(index);
                });
                Navigator.of(context).pop();
              },
              child: Text('Ya'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Tidak'),
            ),
          ],
        );
      },
    );
  }

  void _saveRecipe() {
    if (_formKey.currentState!.validate()) {
      // Validasi dan konversi data
      try {
        final int parsedReviews = int.parse(reviews);
        final int parsedTime = time; // Time is already in minutes

        // Update the recipe in Firestore
        FirebaseFirestore.instance
            .collection('list-Menu')
            .doc(widget.documentSnapshot.id)
            .update({
          'name': name,
          'rate': rate,
          'reviews': parsedReviews,
          'time': parsedTime,
          'cal': cal,
          'category': category,
          'image': image,
          'ingredientsName': ingredientsName,
          'ingredientsAmount': ingredientsAmount,
          'steps': steps,
        }).then((_) {
          Navigator.pop(context); // Navigate back after saving
        }).catchError((error) {
          // Tangani kesalahan jika ada
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update recipe: $error')),
          );
        });
      } catch (e) {
        // Tangani kesalahan parsing
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid input: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Menu'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: 'Nama Resep'),
                onChanged: (value) => name = value,
                validator: (value) =>
                    value!.isEmpty ? 'Nama Resep belum diisi!' : null,
              ),
              TextFormField(
                initialValue: rate,
                decoration: const InputDecoration(labelText: 'Rate'),
                onChanged: (value) => rate = value,
                validator: validateRate,
              ),
              TextFormField(
                initialValue: reviews,
                decoration: const InputDecoration(labelText: 'Jumlah Ulasan'),
                onChanged: (value) => reviews = value,
                validator: (value) => validateNumeric(value, 'Jumlah Ulasan'),
              ),
              GestureDetector(
                onTap: _selectTime,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _timeController,
                    decoration:
                        const InputDecoration(labelText: 'Waktu Masak (JJ:MM)'),
                    validator: (value) =>
                        value!.isEmpty ? 'Waktu belum diisi!' : null,
                  ),
                ),
              ),
              TextFormField(
                initialValue: cal,
                decoration: const InputDecoration(labelText: 'Kalori'),
                onChanged: (value) => cal = value,
                validator: (value) => validateNumeric(value, 'Kalori'),
              ),
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: [
                  'Meat',
                  'Soups',
                  'Noodles',
                  'Vegetables',
                  'Beverages',
                  'Desserts',
                  'Breakfast',
                  'Cereals',
                  'Salads',
                  'Seafood',
                ].map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    category = value!;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a category' : null,
              ),
              TextFormField(
                initialValue: image,
                decoration: const InputDecoration(labelText: 'Image URL'),
                onChanged: (value) => image = value,
                validator: validateImageUrl,
              ),
              const SizedBox(height: 20),
              Text('Bahan-Bahan'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ingredientNameController,
                      decoration:
                          const InputDecoration(labelText: 'Nama Bahan'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _ingredientAmountController,
                      decoration:
                          const InputDecoration(labelText: 'Jumlah Bahan'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addIngredient,
                  ),
                ],
              ),
              ...List.generate(
                ingredientsName.length,
                (index) => Row(
                  children: [
                    Expanded(child: Text(ingredientsName[index])),
                    const SizedBox(width: 10),
                    Expanded(child: Text(ingredientsAmount[index])),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editIngredient(index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteIngredient(index),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              //Text(''),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stepController,
                      decoration:
                          const InputDecoration(labelText: 'Langkah-Langkah'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addStep,
                  ),
                ],
              ),
              ...List.generate(
                steps.length,
                (index) => Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text('${index + 1}. ${steps[index]}'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editStep(index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteStep(index),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveRecipe,
                child: const Text('Perbarui Menu'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50), // Width and height
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
