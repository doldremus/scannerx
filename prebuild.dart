import 'dart:io';
import 'package:path/path.dart' as p;

main() async {
  await run('flutter', ['pub', 'get']);
  await run('flutter', ['pub', 'run', 'pigeon', '--input', p.normalize('pigeons/scanner.dart')]);
  await run('flutter', ['pub', 'run', 'pigeon', '--input', p.normalize('pigeons/barcode.dart')]);
  await run('flutter', ['pub', 'run', 'pigeon', '--input', p.normalize('pigeons/logger.dart')]);
}

run(String executable, List<String> arguments) async {
  final r = await Process.run(executable, arguments, runInShell: true);
  stdout.write(r.stdout);
  stderr.write(r.stderr);
}