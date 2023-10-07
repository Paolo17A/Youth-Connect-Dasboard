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
