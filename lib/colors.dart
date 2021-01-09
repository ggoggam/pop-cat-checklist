library checklist.colors;

import 'package:flutter/material.dart';

////////////////////////////
/// CUSTOM MATERIALCOLOR ///
////////////////////////////

MaterialColor createMaterialColor(int colorHex) {
  Color color = Color(colorHex);
  // Custom MaterialColor generator
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1.0,
    );
  });
  return MaterialColor(color.value, swatch);
}

// We need this custom color class for data persistence
// MaterialColor cannot be saved as JSON format, if not 
// properly serialized with JSON Serializable.
final Map<int, MaterialColor> colorMap = {
  0xFF00022E: createMaterialColor(0xFF00022E), // theme
  0xFF1F1F1F: createMaterialColor(0xFF1F1F1F), // text
  0xFFAA0000: createMaterialColor(0xFFAA0000),
  0xFFD56E0D: createMaterialColor(0xFFD56E0D),
  0xFFEAA514: createMaterialColor(0xFFEAA514),
  0xFFFFDC1A: createMaterialColor(0xFFFFDC1A),
  0xFFD8ED7C: createMaterialColor(0xFFD8ED7C),
  0xFFB1FEDE: createMaterialColor(0xFFB1FEDE),
  0xFFCAE4FF: createMaterialColor(0xFFCAE4FF),
  0xFFE0CDFF: createMaterialColor(0xFFE0CDFF),
  0xFFA89BCB: createMaterialColor(0xFFA89BCB),
  0xFF706897: createMaterialColor(0xFF706897),
};

List<MaterialColor> colorPickerList = [
  colorMap[0xFFAA0000],
  colorMap[0xFFD56E0D],
  colorMap[0xFFEAA514],
  colorMap[0xFFFFDC1A],
  colorMap[0xFFD8ED7C],
  colorMap[0xFFB1FEDE],
  colorMap[0xFFCAE4FF],
  colorMap[0xFFE0CDFF],
  colorMap[0xFFA89BCB],
  colorMap[0xFF706897]
];