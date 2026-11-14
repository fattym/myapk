/// Turns raw OCR lines from a photographed booklist into plausible book
/// titles: strips numbering, drops prices/noise/headers, removes duplicates.
List<String> cleanBooklistLines(List<String> raw, {int max = 30}) {
  final seen = <String>{};
  final out = <String>[];
  for (var line in raw) {
    line = line
        .replaceAll(RegExp(r'^[\s\d]+[.)\-:]+\s*'), '')
        .replaceAll(RegExp(r'[|_~]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final letters = RegExp(r'[A-Za-z]').allMatches(line).length;
    if (letters < 5) continue;
    if (RegExp(
      r'^(name|class|grade|school|term|year|date|booklist|book list)\b',
      caseSensitive: false,
    ).hasMatch(line)) {
      continue;
    }
    if (seen.add(line.toLowerCase())) out.add(line);
    if (out.length >= max) break;
  }
  return out;
}

Set<String> _words(String s) => RegExp(r'[a-z0-9]+')
    .allMatches(s.toLowerCase())
    .map((m) => m.group(0)!)
    .where((w) => w.length >= 3)
    .toSet();

/// Share of the OCR line's words that also appear in a product title (0..1).
/// Used to decide whether a catalogue hit really is the book on the list.
double matchScore(String line, String title) {
  final lineWords = _words(line);
  if (lineWords.isEmpty) return 0;
  final titleWords = _words(title);
  return lineWords.where(titleWords.contains).length / lineWords.length;
}
