# Shorebird Release

[![ci](https://github.com/shorebirdtech/shorebird-release/actions/workflows/main.yaml/badge.svg)](https://github.com/shorebirdtech/shorebird-release/actions/workflows/main.yaml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)

Create a new release using the [Shorebird CLI](https://github.com/shorebirdtech/shorebird) for use in GitHub Actions.

## Features

✅ Create new Android releases

✅ Create new iOS releases

✅ Outputs the release version

## Usage

Standard usage:

```yaml
steps:
  - uses: shorebirdtech/setup-shorebird@v0
  - uses: shorebirdtech/shorebird-release@v0
    id: shorebird-release
    with:
      platform: android
      working-directory: ./path/to/app

  - run: echo release-version ${{ steps.shorebird-release.outputs.release-version }}
    shell: bash
```

If you need to provide arguments to the release command, you can do so like this:

```yaml
steps:
  - uses: shorebirdtech/setup-shorebird@v0
  - uses: shorebirdtech/shorebird-release@v0
    id: shorebird-release
    with:
      args: --verbose --flavor=my-flavor --target=lib/special_main.dart
      flutter-version: 3.29.2
      platform: android
      working-directory: ./path/to/app
```

## Inputs

The action takes the following inputs:

- `args`: Any arguments to pass to `shorebird release`. For example, if you need
  to specify a flavor, you can pass `--flavor=<FLAVOR>`.
  - Use an extra `--` to pass arguments to Flutter (e.g. `-- --dart-define=KEY=VALUE`)
- `flutter-version`: Which Flutter version to build the release with.
  - Defaults to `latest` which uses the latest stable Flutter version supported by Shorebird.
- `platform`: Which platform to create a release for (e.g. `android` or `ios`)
- `working-directory`: Which directory to run `shorebird release` in.

## Outputs

The actions outputs the following:

- `release-version`: The version of the release that was successfully created.
