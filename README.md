# Shorebird Release

[![ci](https://github.com/shorebirdtech/release-shorebird/actions/workflows/main.yaml/badge.svg)](https://github.com/shorebirdtech/release-shorebird/actions/workflows/main.yaml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)

Create a new release using the [Shorebird CLI](https://github.com/shorebirdtech/shorebird) for use in GitHub Actions.

## Features

✅ Configures the specified version of Flutter

✅ Create new Android releases

✅ Create new iOS releases

## Usage

```yaml
steps:
  - uses: shorebirdtech/release-shorebird@v0
    id: shorebird-release
    with:
      platform: android
      flutter-version: 3.10.6

  - run: echo release-version ${{ steps.shorebird-release.outputs.release-version }}
    shell: bash
```

## Inputs

The action takes the following inputs:

- `flutter-version`: Which version of Flutter to install alongside Shorebird (e.g. `3.10.6`)
- `platform`: Which platform to create a release for (e.g. `android` or `ios-alpha`)

## Outputs

The actions outputs the following:

- `release-version`: The version of the release that was successfully created.
