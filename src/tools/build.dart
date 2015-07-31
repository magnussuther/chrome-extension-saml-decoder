import 'dart:io';
import 'package:path/path.dart' as path;

void main() {
  var scriptDir = path.dirname(Platform.script.toFilePath());
  var p = path.join(scriptDir, "../");
  Process.run('/usr/lib/dart/bin/pub', ['build', '--mode', 'release'], workingDirectory: "${p}").then((ProcessResult results) {
    print(results.stdout);
    print(results.stderr);

    new File(path.join(p, "manifest.json")).copy(path.join(p, "build", "manifest.json"));
    new File(path.join(p, "icon_128.png")).copy(path.join(p, "build", "icon_128.png"));
    new File(path.join(p, "icon_48.png")).copy(path.join(p, "build", "icon_48.png"));
    new File(path.join(p, "icon_16.png")).copy(path.join(p, "build", "icon_16.png"));
  });
}