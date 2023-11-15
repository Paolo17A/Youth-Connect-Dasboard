import 'dart:math';

bool isAlphanumeric(String input) {
  // Define a regular expression pattern to match alphanumeric characters
  // The pattern ^[a-zA-Z0-9]+$ means:
  // ^: Start of the string
  // [a-zA-Z0-9]: Any letter (uppercase or lowercase) or digit
  // +: One or more of the previous pattern
  // $: End of the string
  final alphanumericRegex = RegExp(r'^[a-zA-Z0-9]+$');

  // Use the regex to match the input string
  return alphanumericRegex.hasMatch(input);
}

String generateRandomHexString(int length) {
  final random = Random();
  final codeUnits = List.generate(length ~/ 2, (index) {
    return random.nextInt(255);
  });

  final hexString =
      codeUnits.map((value) => value.toRadixString(16).padLeft(2, '0')).join();
  return hexString;
}
