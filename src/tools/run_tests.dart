import 'dart:io';
import 'package:path/path.dart' as path;

// Run me with 'dart run_tests.dart'
void main() {
  runSuite('test/scenarios_test.dart');
}

runSuite(file) {
  print("Running unit tests for the ${file} suite ...");

  var scriptDir = path.dirname(Platform.script.toFilePath());
  var p = path.join(scriptDir, "../");

  Process.run('/usr/lib/dart/bin/pub', ['run', 'test', '-p', 'dartium', file],
      workingDirectory: p)
    .then((ProcessResult results) {
      print(results.stdout);
      print(results.stderr);
      print("... DONE");
  });
}