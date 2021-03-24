import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:process_run/shell_run.dart';

var shell = Shell();

class ProxyBuilder {
  String entryPath;
  String pubspecPath;
  String outputPath;
  String dartSdkPath;
  String filterMode = 'black';
  String type = 'all';
  String config;
  String mxProxyBuildProjectPath;
  String binPath;
  String librariesPath;
  ProxyBuilder(ArgResults argResults) {
    var env = Platform.environment;
    entryPath = argResults['entry-point'];
    pubspecPath = argResults['pubspec'];
    outputPath = argResults['output'] ?? p.current;
    dartSdkPath = argResults['sdk'] ?? env['DART_HOME'];
    filterMode = argResults['filter-mode'];
    type = argResults['type'];
    config = argResults['build-config'];
    var binDir = File(p.dirname(Platform.script.path));
    binPath = binDir.path;
    mxProxyBuildProjectPath = binDir.parent.path;
  }
  void run() async {
    if (!checkNotNull(entryPath, 'entry-point') ||
        !checkNotNull(dartSdkPath, 'sdk')) {
      print('build proxy filed');
      return;
    }
    await setUpProject();
    await rewriteLibrariesFile();
    await buildProxy();
  }

  void setUpProject() async {
    if (pubspecPath == null) {
      return;
    }
    var pubSpecFile = File(pubspecPath);
    if (!pubSpecFile.existsSync()) {
      print('$pubspecPath not exists, please check pubspec path');
      return;
    }
    var project = pubSpecFile.parent.path;
    print(project);
    shell = shell.pushd(project);
    await shell.run('flutter pub get');
    shell = shell.popd();
  }

  void rewriteLibrariesFile() async {
    var bin = p.dirname(Platform.script.path);
    var librariesFile =
        File(p.join(bin, 'flutter_web_sdk', 'libraries.json'));
    var json = librariesFile.readAsStringSync();
    var tempLibrariesFile =
        File(p.join(bin, 'flutter_web_sdk', 'temp_libraries.json'));
    librariesPath = tempLibrariesFile.path;
    tempLibrariesFile.writeAsStringSync(json.replaceAll('../dart-sdk', dartSdkPath));
  }

  void buildProxy() async {
    shell = shell.pushd(mxProxyBuildProjectPath);
    var frontendServer = p.join(binPath, 'flutter_frontend_server.dill');
    var mxConifgCommand = config == null ? '' : '--mx-config-file $config';
    var sdkRoot = p.join(binPath, 'flutter_web_sdk');
    var platform = p.join(binPath, 'flutter_web_sdk', 'kernel', 'flutter_ddc_sdk.dill');
    print('start build proxy...');
    await shell.run('''
  dart $frontendServer --target=dartdevc --sdk-root "$sdkRoot" --platform "$platform" --libraries-file "$librariesPath" --dart-sdk-summary "$platform" "$entryPath"  --mxflutter-out-dir "$outputPath" --mxflutter-fliter-mode "$filterMode" --mxflutter-language "$type" $mxConifgCommand
    ''');
    shell = shell.popd();
    print('build proxy success');
  }
}

bool checkNotNull(dynamic obj, String name) {
  if (obj == null) {
    print('arg $name is null, please check.');
    return false;
  }
  return true;
}

void run(ArgResults argResults) {
  var proxyBuilder = ProxyBuilder(argResults);
  proxyBuilder.run();
}
