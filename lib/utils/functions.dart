String capitalizeFirst(String input) {
  if (input.length <= 1) {
    return input;
  }
  return input[0].toUpperCase() + input.substring(1);
}

String? capitalizeWords(String? input) {
  if (input == null || input.isEmpty) {
    return input;
  }

  List<String> words = input.split(' ');

  for (int i = 0; i < words.length; i++) {
    if (words[i].isNotEmpty) {
      words[i] =
          words[i][0].toUpperCase() + words[i].substring(1).toLowerCase();
    }
  }

  return words.join(' ');
}
