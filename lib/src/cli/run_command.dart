import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dopo/dopo.dart';
import 'package:dopo/src/parser/template_engine.dart';
import 'package:http/http.dart' as http;

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

    argParser.addOption(
      'timeout',
      abbr: 't',
      defaultsTo: '30',
      help: 'Timeout in seconds before aborting the request.',
      valueHelp: 'SECONDS',
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

    final rawContent = await file.readAsString();

    String hydratedContent;
    try {
      hydratedContent = TemplateEngine.process(rawContent, Platform.environment);
    } on TemplateException catch (e) {
      ConsoleFormatter.error('Template Error: ${e.message}');
      ConsoleFormatter.error('↳ Hint: Ensure the variable is defined in your environment.');
      exit(1);
    }

    final parser = DslParser();
    final result = parser.parse(hydratedContent);

    if (result.hasErrors) {
      ConsoleFormatter.parseErrors(file.uri.pathSegments.last, result.errors);
      exit(1);
    }

    final isVerbose = argResults!['verbose'] as bool;
    final timeoutSecs = int.tryParse(argResults!['timeout'] as String) ?? 30;
    final timeout = Duration(seconds: timeoutSecs);

    final req = result.request!;
    ConsoleFormatter.requestLine(req, verbose: isVerbose);

    final runner = HttpRunner();
    try {
      final response = await runner.run(req, timeout: timeout);
      ConsoleFormatter.response(response, verbose: isVerbose);
    } on TimeoutException {
      ConsoleFormatter.error('Request timed out after ${timeout.inSeconds} seconds.');
      exit(1);
    } on SocketException catch (e) {
      ConsoleFormatter.error('Network Connection Failed.');
      ConsoleFormatter.error('↳ Hint: Check your internet connection or verify the domain name is correct.');
      if (isVerbose) print('\n$e');
      exit(1);
    } on http.ClientException catch (e) {
      ConsoleFormatter.error('HTTP Client Error: ${e.message}');
      exit(1);
    } catch (e) {
      ConsoleFormatter.error('Unexpected Error: $e');
      exit(1);
    } finally {
      runner.close();
    }
  }
}
