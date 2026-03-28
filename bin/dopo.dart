import 'dart:io';
import 'package:args/args.dart';
import 'package:dopo/dopo.dart';

void main(List<String> args) async {
  final parser = ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show usage information.',
    );

  final ArgResults argResults;
  try {
    argResults = parser.parse(args);
  } catch (e) {
    print('Argument Error: ${e.toString()}');
    exit(1);
  }

  if (argResults['help'] as bool || argResults.rest.isEmpty) {
    print('Usage: dopo <file.dopo>\n');
    print(parser.usage);
    exit(0);
  }

  final filePath = argResults.rest.first;
  final file = File(filePath);

  if (!await file.exists()) {
    print('Error: File not found at "$filePath"');
    exit(1);
  }

  final content = await file.readAsString();
  final dslParser = DslParser();
  final result = dslParser.parse(content);

  print('── Parsing: ${file.uri.pathSegments.last} ──\n');

  if (result.hasErrors) {
    print('Failed with ${result.errors.length} error(s):\n');
    for (final error in result.errors) {
      print('   Near: "${error.line}"');
      print('   Hint: ${error.hint}\n');
    }
    exit(1);
  }
  final req = result.request!;

  print('Parsed Successfully\n');
  print('Sending: ${req.method.name.toUpperCase()} ${req.url}');

  if (req.headers.isNotEmpty) {
    print('\nHeaders:');
    for (final h in req.headers) print('  • $h');
  }

  if (req.queryParams.isNotEmpty) {
    print('\nQuery Params:');
    for (final q in req.queryParams) print('  • $q');
  }

  if (req.hasBody) {
    print('\nBody:\n${req.body}');
  }

  final runner = HttpRunner();
  try {
    final response = await runner.run(req);
    final color = response.statusCode >= 200 && response.statusCode < 300
        ? '\x1B[32m'
        : '\x1B[31m';
    print(
      '$color${response.statusCode}\x1B[0m in ${response.duration.inMilliseconds}ms',
    );

    if (response.body.isNotEmpty) {
      print('\n${response.body}');
    }
  } catch (e) {
    print('Network Error: $e');
  } finally {
    runner.close();
  }
}
