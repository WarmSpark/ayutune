class RomanizeHindi {
  static const Map<String, String> _vowels = {
    'अ': 'a',
    'आ': 'aa',
    'इ': 'i',
    'ई': 'ee',
    'उ': 'u',
    'ऊ': 'oo',
    'ऋ': 'ri',
    'ए': 'e',
    'ऐ': 'ai',
    'ओ': 'o',
    'औ': 'au',
    'अं': 'an',
    'अः': 'ah',
  };

  static const Map<String, String> _consonants = {
    'क': 'k',
    'ख': 'kh',
    'ग': 'g',
    'घ': 'gh',
    'ङ': 'ng',
    'च': 'ch',
    'छ': 'chh',
    'ज': 'j',
    'झ': 'jh',
    'ञ': 'ny',
    'ट': 't',
    'ठ': 'th',
    'ड': 'd',
    'ढ': 'dh',
    'ण': 'n',
    'त': 't',
    'थ': 'th',
    'द': 'd',
    'ध': 'dh',
    'न': 'n',
    'प': 'p',
    'फ': 'ph',
    'ब': 'b',
    'भ': 'bh',
    'म': 'm',
    'य': 'y',
    'र': 'r',
    'ल': 'l',
    'व': 'v',
    'श': 'sh',
    'ष': 'sh',
    'स': 's',
    'ह': 'h',
    'क़': 'q',
    'ख़': 'kh',
    'ग़': 'gh',
    'ज़': 'z',
    'ड़': 'd',
    'ढ़': 'dh',
    'फ़': 'f',
  };

  static const Map<String, String> _matras = {
    'ा': 'a',
    'ि': 'i',
    'ी': 'ee',
    'ु': 'u',
    'ू': 'oo',
    'ृ': 'ri',
    'े': 'e',
    'ै': 'ai',
    'ो': 'o',
    'ौ': 'au',
    'ं': 'n',
    'ँ': 'n',
    'ः': 'h',
  };

  static final RegExp _devanagariCheck = RegExp(r'[\u0900-\u097F]');

  static bool hasDevanagari(String text) {
    return _devanagariCheck.hasMatch(text);
  }

  static String convert(String text) {
    if (!hasDevanagari(text)) return text;

    final buffer = StringBuffer();
    final chars = text.split('');
    final len = chars.length;

    for (int i = 0; i < len; i++) {
      final c = chars[i];

      if (_consonants.containsKey(c)) {
        final rom = _consonants[c]!;
        if (i + 1 < len) {
          final nextC = chars[i + 1];
          if (nextC == '्') {
            buffer.write(rom);
            i++;
          } else if (_matras.containsKey(nextC)) {
            buffer.write(rom);
            buffer.write(_matras[nextC]);
            i++;
          } else if (_consonants.containsKey(nextC)) {
            buffer.write('${rom}a');
          } else {
            buffer.write(rom);
          }
        } else {
          buffer.write(rom);
        }
      } else if (_vowels.containsKey(c)) {
        buffer.write(_vowels[c]);
      } else if (_matras.containsKey(c)) {
        buffer.write(_matras[c]);
      } else if (c == '्') {
        continue;
      } else {
        buffer.write(c);
      }
    }

    return buffer.toString();
  }
}
