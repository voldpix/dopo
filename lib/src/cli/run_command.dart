import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dopo/dopo.dart';

import 'console_formatter.dart';

class RunCommand extends Command<void> {
  @override
  final String name = 'run';

  @override
  final String description = 'Executes a .dopo request file.';

  RunCommand() {
    argParser.addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Show detailed request and response information, including headers.',
    );
  }

  @override
  Future<void> run() async {
    if (argResults!.rest.isEmpty) {
      usageException('Please provide a file to run.');
    }

    final filePath = argResults!.rest.first;

    if (!filePath.endsWith(".dopo")) {
      usageException('Invalid file type. Only .dopo files are supported.');
    }

    final file = File(filePath);
    if (!await file.exists()) {
      ConsoleFormatter.error('File not found at "$filePath"');
      exit(1);
    }

    final content = await file.readAsString();
    final parser = DslParser();
    final result = parser.parse(content);

    if (result.hasErrors) {
      ConsoleFormatter.parseErrors(file.uri.pathSegments.last, result.errors);
      exit(1);
    }

    final isVerbose = argResults!['verbose'] as bool;

    final req = result.request!;
    ConsoleFormatter.requestLine(req, verbose: isVerbose);

    final runner = HttpRunner();
    try {
      final response = await runner.run(req);
      ConsoleFormatter.response(response, verbose: isVerbose);
    } catch (e) {
      ConsoleFormatter.error('Network error: $e');
      exit(1);
    } finally {
      runner.close();
    }
  }
}
