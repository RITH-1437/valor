import 'dart:io';

void main() {
  final content = File('pubspec.yaml').readAsStringSync();
  final lines = content.split('\n');
  bool inFlutter = false;
  for (final line in lines) {
    if (line.startsWith('flutter:') && !line.startsWith('  ')) {
      inFlutter = true;
    } else if (inFlutter && line.startsWith(RegExp(r'^\w'))) {
      inFlutter = false;
    }
    if (inFlutter) stdout.writeln(line);
  }
}
