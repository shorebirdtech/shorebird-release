# Shorebird Release

[![ci](https://github.com/shorebirdtech/release-shorebird/actions/workflows/main.yaml/badge.svg)](https://github.com/shorebirdtech/release-shorebird/actions/workflows/main.yaml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)

Create a new release using the [Shorebird CLI](https://github.com/shorebirdtech/shorebird) for use in GitHub Actions.

## Features

✅ Create new Android releases

✅ Create new iOS releases

✅ Outputs the release version

## Usage

```yaml
steps:
  - uses: shorebirdtech/setup-shorebird@v0
  - uses: shorebirdtech/release-shorebird@v0
    id: shorebird-release
    with:
      platform: android
      working-directory: ./path/to/app

  - run: echo release-version ${{ steps.shorebird-release.outputs.release-version }}
    shell: bash
```

## Inputs

The action takes the following inputs:

- `platform`: Which platform to create a release for (e.g. `android` or `ios-alpha`)
- `working-directory`: Which directory to run `shorebird release` in.

## Outputs

The actions outputs the following:

- `release-version`: The version of the release that was successfully created.
