import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resep_tuang/Admin/Utils/validator.dart'; // Import validator

class AddMenuScreen extends StatefulWidget {
  @override
  _AddMenuScreenState createState() => _AddMenuScreenState();
}

class _AddMenuScreenState extends State<AddMenuScreen> {
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
  final TextEditingController _hourController = TextEditingController();
  final TextEditingController _minuteController = TextEditingController();

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

  void _selectTime() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Waktu Masak'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _hourController,
                decoration: InputDecoration(labelText: 'Jam (0-23)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _minuteController,
                decoration: InputDecoration(labelText: 'Menit (0-59)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                int hours = int.parse(_hourController.text);
                int minutes = int.parse(_minuteController.text);
                int totalMinutes = (hours * 60) + minutes;

                setState(() {
                  time = totalMinutes; // Update time in minutes
                });

                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _saveRecipe() {
    if (_formKey.currentState!.validate()) {
      // Save the recipe to Firestore
      FirebaseFirestore.instance.collection('list-Menu').add({
        'name': name,
        'rate': rate,
        'reviews': int.parse(reviews),
        'time': time,
        'cal': cal,
        'category': category,
        'image': image,
        'ingredientsName': ingredientsName,
        'ingredientsAmount': ingredientsAmount,
        'steps': steps,
      }).then((_) {
        Navigator.pop(context); // Navigate back after saving
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Menu'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nama Resep'),
                onChanged: (value) => name = value,
                validator: (value) =>
                    value!.isEmpty ? 'Nama Resep belum diisi!' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Rate'),
                onChanged: (value) => rate = value,
                validator: validateRate,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Ulasan'),
                onChanged: (value) => reviews = value,
                validator: (value) => validateNumeric(value, 'Ulasan'),
              ),
              GestureDetector(
                onTap: _selectTime,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration:
                        InputDecoration(labelText: 'Waktu Masak (JJ:MM)'),
                    controller: TextEditingController(text: time.toString()),
                    validator: (value) =>
                        value!.isEmpty ? 'Waktu belum diisi!' : null,
                  ),
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Kalori'),
                onChanged: (value) => cal = value,
                validator: (value) =>
                    value!.isEmpty ? 'Kalori belum diisi!' : null,
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
                        child: Text(
                            '${index + 1}. ${steps[index]}'), // Step numbering
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
                child: const Text('Tambah Menu'),
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
