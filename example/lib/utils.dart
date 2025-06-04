String? extractAmount(String? qrCodeText) {
  if (qrCodeText == null) {
    return null;
  }
  final lines = qrCodeText.split('\n');

  for (int i = 1; i < lines.length; i++) {
    if (lines[i].trim() == 'CHF') {
      return lines[i - 1].trim();
    }
  }

  return null; // CHF not found or it's the first line
}
