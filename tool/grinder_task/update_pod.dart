part of '../grind.dart';

@Task('CocoaPodsのアップデート(パッケージアプデ時に使う)')
void updatePods() {
  run(
    'rm',
    arguments: ['-rf', 'Pods/'],
    workingDirectory: 'ios',
  );
  run(
    'rm',
    arguments: ['-rf', 'Podfile.lock'],
    workingDirectory: 'ios',
  );
  run(
    'flutter',
    arguments: ['clean'],
  );
  run(
    'flutter',
    arguments: ['pub', 'get'],
  );
  run(
    'pod',
    arguments: ['install', '--repo-update'],
    workingDirectory: 'ios',
  );
}
