double? extractAmount(String? qrCodeText) {
  if (qrCodeText == null) {
    return null;
  }
  final lines = qrCodeText.split('\n');

  for (int i = 1; i < lines.length; i++) {
    if (lines[i].trim() == 'CHF') {
      // try to parse, if fail continue
      try {
        return double.parse(lines[i - 1].trim());
      } catch (e) {
        continue;
      }
    }
  }

  return null; // CHF not found or it's the first line
}
