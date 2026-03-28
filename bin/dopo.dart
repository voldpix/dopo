import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dopo/src/cli/run_command.dart';
import 'package:dopo/src/constants.dart';

void main(List<String> args) async {
  final runner = CommandRunner<void>(appName, 'A lightweight HTTP testing and mocking tool.')..addCommand(RunCommand());

  runner.argParser.addFlag('version', abbr: 'v', negatable: false, help: 'Print the tool version.');

  try {
    final topLevelResults = runner.parse(args);
    if (topLevelResults['version'] == true) {
      print('$appName version: $appVersion');
      exit(0);
    }

    await runner.run(args);
  } on UsageException catch (e) {
    print('${e.message}\n');
    print(e.usage);
    exit(64);
  } catch (e) {
    print('An unexpected error occurred: $e');
    exit(1);
  }
}
