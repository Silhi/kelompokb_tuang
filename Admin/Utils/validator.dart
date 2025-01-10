// validator_add_menu.dart

String? validateRate(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter a rate';
  }

  // Mengganti koma dengan titik dan mengonversi ke angka
  value = value.replaceAll(',', '.');
  final rateValue = double.tryParse(value);

  if (rateValue == null) {
    return 'Rate must be a number';
  }

  if (rateValue < 1 || rateValue > 5) {
    return 'Rate must be between 1 and 5';
  }

  return null;
}

String? validateNumeric(String? value, String fieldName) {
  if (value == null || value.isEmpty) {
    return 'Please enter $fieldName';
  }
  if (double.tryParse(value) == null) {
    return '$fieldName must be a number';
  }
  return null;
}

String? validateImageUrl(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter an image URL';
  }
  if (!value.startsWith('https://')) {
    return 'Image URL must start with "https://"';
  }
  return null;
}
