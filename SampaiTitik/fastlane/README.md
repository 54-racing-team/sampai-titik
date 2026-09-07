fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### sync_certs

```sh
[bundle exec] fastlane sync_certs
```



----


## iOS

### ios dev_patch_release

```sh
[bundle exec] fastlane ios dev_patch_release
```

Push to dev branch -> patch bump + TestFlight

### ios dev_build_release

```sh
[bundle exec] fastlane ios dev_build_release
```

Push to dev without bump patch version

### ios release

```sh
[bundle exec] fastlane ios release
```

GitHub Release published in main -> set version from tag + TestFlight

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
