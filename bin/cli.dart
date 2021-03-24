import 'package:args/args.dart';
import 'package:mxflutter_cli/proxy_builder.dart' as proxy_builder;

var argParser = ArgParser()
  ..addOption('pubspec', help: 'pubspec.yaml path')
  ..addOption('entry-point', help: 'main.dart path')
  ..addOption('sdk', help: 'dart sdk path, default DART_HOME')
  ..addOption('output', abbr: 'o', help: 'output path, defalut current path')
  ..addOption('filter-mode',
      defaultsTo: 'black', help: 'chose filter mode black or white')
  ..addOption('type', defaultsTo: 'all', help: 'all ts dart js')
  ..addOption('build-config', help: 'build proxy confing filePath')
  ..addFlag('help',
      abbr: 'h', negatable: false, help: 'Displays this help information.');
void main(List<String> arguments) {
  var argResults = argParser.parse(arguments);
  if (argResults['help'] || arguments.isEmpty) {
    print('''
${argParser.usage}
    ''');
  }
  proxy_builder.run(argResults);
}
