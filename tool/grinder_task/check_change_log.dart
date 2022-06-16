part of '../grind.dart';

// monoさんのやつ
// https://gist.github.com/mono0926/c1f959cb05328e7f19da0bd275a282e0/
@Task('pubspec.lockに差分がある時change logを開く')
void checkChangelog() {
  _openUpgradedPackageChangelog(
    [
      '.',
    ],
  );
}

void _openUpgradedPackageChangelog(List<String> directories) {
  final nameRegex = RegExp('       name: (.+)\n');
  final versionRegex = RegExp(r'\+    version: "(.+)"');
  final preReleaseRegex = RegExp(r'\d+\.\d+.\d+-.+');
  final urls = Set.of(directories.map((directory) {
    final diff = run(
      'git',
      arguments: [
        'diff',
        './$directory/pubspec.lock',
      ],
    );
    final packages = diff.split('@@');

    return packages.map((package) {
      final nameMatch = nameRegex.firstMatch(package);
      final versionMatch = versionRegex.firstMatch(package);
      if (nameMatch == null || versionMatch == null) {
        return null;
      }
      // ignore: avoid-non-null-assertion
      final name = nameMatch.group(1)!;
      // ignore: avoid-non-null-assertion
      final version = versionMatch.group(1)!;
      final versionAdjusted = version.replaceAll(RegExp(r'\.|\+'), '');
      final isPreRelease = preReleaseRegex.firstMatch(version) != null;
      final preReleasePath = isPreRelease ? '/versions/$version' : '';

      return 'https://pub.dev/packages/$name$preReleasePath/changelog#$versionAdjusted';
    }).whereNotNull();
  }).expand((e) => e));

  for (final url in urls) {
    run('open', arguments: [url]);
  }
}
