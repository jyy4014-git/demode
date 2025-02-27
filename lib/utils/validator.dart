class Validator {
  static Map<String, String> validatePayload(Map<String, dynamic> payload, List<String> requiredFields) {
    Map<String, String> errors = {};
    
    for (var field in requiredFields) {
      if (!payload.containsKey(field) || payload[field] == null || payload[field].toString().isEmpty) {
        errors[field] = '$field is required';
      }
    }

    if (payload.containsKey('email') && payload['email'] != null) {
      String email = payload['email'].toString();
      bool emailValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
      if (!emailValid) {
        errors['email'] = 'Invalid email format';
      }
    }

    if (payload.containsKey('price') && payload['price'] != null) {
      try {
        int price = int.parse(payload['price'].toString());
        if (price < 0) {
          errors['price'] = 'Price must be a positive number';
        }
      } catch (e) {
        errors['price'] = 'Price must be a number';
      }
    }

    return errors;
  }
}
