import 'dart:io';

// Run me with 'dart run_tests.dart'
void main() {
  runSuite('test/scenarios_test.dart');
}

runSuite(file) {
  print("Running unit tests for the ${file} suite ...");
  Process.run('/usr/lib/dart/bin/pub', ['run', 'test', '-p', 'dartium', file],
      workingDirectory: '../')
    .then((ProcessResult results) {
      print(results.stdout);
      print(results.stderr);
      print("... DONE");
  });
}