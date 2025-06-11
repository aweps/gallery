# Flutter Gallery

**NOTE**: The Flutter Gallery is now deprecated, and no longer being active maintained.

Flutter Gallery was a resource to help developers evaluate and use Flutter.
It is now being used primarily for testing.

We recommend Flutter developers check out the following resources:

* **Wonderous**
([web demo](https://wonderous.app/web/),
[App Store](https://apps.apple.com/us/app/wonderous/id1612491897),
[Google Play](https://play.google.com/store/apps/details?id=com.gskinner.flutter.wonders),
[source code](https://github.com/gskinnerTeam/flutter-wonderous-app)):<br>
A Flutter app that showcases Flutter's support for elegant design and rich animations.

* **Material 3 Demo**
([web demo](https://flutter.github.io/samples/web/material_3_demo/),
[source code](https://github.com/flutter/samples/tree/main/material_3_demo)):<br>
A Flutter app that showcases Material 3 features in the Flutter Material library.

* **Flutter Samples**
([samples](https://flutter.github.io/samples), [source code](https://github.com/flutter/samples)):<br>
A collection of open source samples that illustrate best practices for Flutter.

* **Widget catalogs**
([Material](https://docs.flutter.dev/ui/widgets/material), [Cupertino](https://docs.flutter.dev/ui/widgets/cupertino)):<br>
Catalogs for Material, Cupertino, and other widgets available for use in UI.


***************

Flutter Gallery is a resource to help developers evaluate and use Flutter.
It is a collection of Material Design & Cupertino widgets, behaviors, and vignettes
implemented with Flutter. We often get asked how one can see Flutter in action,
and this gallery demonstrates what Flutter provides and how it behaves in the
wild.

![Flutter Gallery](https://user-images.githubusercontent.com/6655696/73928238-0d7fcc80-48d3-11ea-8a7e-ea7dc5d6e713.png)

## Features

- Showcase for `material`, `cupertino`, and other widgets
- [Adaptive layout](lib/layout/adaptive.dart) for mobile and desktop
- State restoration support
- Settings to text scaling, text direction, locale, theme, and more...
- Demo for `animations`
- Foldable support and demo for `dual_screen`
- Deferred loading
- CI/CD
- ...and much more!

## Supported Platforms

Flutter Gallery has been built to support multiple platforms.
These include:

- Android ([Google Play Store](https://play.google.com/store/apps/details?id=com.webkrux.gallery), [.apk][latest release])
- iOS (locally)
- web ([gallery.flutter.dev](https://gallery.flutter.dev/))
- macOS ([.zip][latest release])
- Linux ([.tar.gz][latest release])
- Windows ([.zip][latest release], [.msix](https://www.microsoft.com/store/productId/9PDWCTDFC7QQ))

## Running

One can run the gallery locally for any of these platforms. For desktop platforms,
please see the [Flutter docs](https://docs.flutter.dev/desktop) for the latest
requirements.

```bash
cd gallery/
flutter pub get
flutter run
```

<details>
<summary>Troubleshooting</summary>

### Flutter `master` channel

The Flutter Gallery targets Flutter's master channel. As such, it can take advantage
of new SDK features that haven't landed in the stable channel.

If you'd like to run the Flutter Gallery, make sure to switch to the master channel
first:

```bash
flutter channel master
flutter upgrade
```

When you're done, use this command to return to the safety of the stable
channel:

```bash
flutter channel stable
flutter upgrade
```

## Supported Platforms

Flutter Gallery has been built to support multiple platforms.
This includes:

- Android
- iOS
- web
- macOS
- Linux
- Windows

An APK, macOS, Linux, and Windows builds are available for [download](https://github.com/flutter/gallery/releases). You can find it on the web at [gallery.flutter.dev](https://gallery.flutter.dev/) and on the [Google Play Store](https://play.google.com/store/apps/details?id=com.webkrux.demo.gallery).

You can build from source yourself for any of these platforms, though, please note desktop support must [be enabled](
https://github.com/flutter/flutter/wiki/Desktop-shells#tooling). For
example, to run the app on Windows:

```bash
cd gallery/
flutter config --enable-windows-desktop
flutter create .
flutter run -d windows
```

Additionally, the UI adapts between mobile and desktop layouts regardless of the
platform it runs on. This is determined based on window size as outlined in
[adaptive.dart](lib/layout/adaptive.dart).

## To include a new splash animation

1. Convert your animation to a `.gif` file.
   Ideally, use a background color of `0xFF030303` to ensure the animation
   blends into the background of the app.

2. Add your new `.gif` file to the assets directory under
   `assets/splash_effects`. Ensure the name follows the format
   `splash_effect_$num.gif`. The number should be the next number after the
   current largest number in the repository.

3. Update the map `_effectDurations` in
[splash.dart](lib/pages/splash.dart) to include the number of the
new `.gif` as well as its estimated duration. The duration is used to
determine how long to display the splash animation at launch.
</details>

## Releasing

*must be a `flutter-hackers` member*

A set of GitHub workflows are available to help with releasing the Flutter Gallery, one per releasing platform.

1. For Android, download the relevant [Firebase configuration file](https://firebase.corp.google.com/u/0/project/gallery-flutter-dev/settings/general) (e.g. `google-services.json`).
1. Bump the `pubspec.yaml` version number. This can be in a PR making a change or a separate PR.
Use [semantic versioning](https://semver.org/) to determine
which part to increment. **The version number after the `+` should also be incremented**. For example `1.2.3+010203`
with a patch should become `1.2.4+010204`.

1. Run GitHub workflow.
- [Deploy to web](https://github.com/flutter/gallery/actions/workflows/release_deploy_web.yml): Deploys a web build to the Firebase-hosted [staging](https://gallery-flutter-staging.web.app) or [production](https://gallery.flutter.dev) site.
- [Deploy to Play Store](https://github.com/flutter/gallery/actions/workflows/release_deploy_play_store.yml): Uses Fastlane to create a [beta](https://play.google.com/console/u/0/developers/7661132837216938445/app/4974617875198505129/tracks/open-testing) (freely available on the [Play Store](https://play.google.com/apps/testing/com.webkrux.gallery)) or promote an existing beta to [production](https://play.google.com/console/u/0/developers/7661132837216938445/app/4974617875198505129/tracks/production) ([Play Store](https://play.google.com/store/apps/details?id=com.webkrux.gallery)).
  > **Note**
  > Once an .aab is created with a particular version number, it can't be replaced. The pubspec version number must be incremented again.

- [Draft GitHub release](https://github.com/flutter/gallery/actions/workflows/release_draft_github_release.yml): Drafts a GitHub release, including packaged builds for Android, macOS, Linux, and Windows. Release notes can be automatically generated. The release draft is private until published. Upon being published, the specified version tag will be created.
- [Publish on Windows Store](): Releasing to the Windows Store.
  > **Note**
  > This repository is not currently set up to publish new versions of [the current Windows Store listing](https://www.microsoft.com/store/productId/9PDWCTDFC7QQ). Requires running `msstore init` within the repository and setting repository/environment secrets .
  > See the instructions in the [documentation](https://docs.flutter.dev/deployment/windows#github-actions-cicd) for more information.

<details>
  <summary>Escape hatch</summary>

If the above GitHub workflows aren't functional (#759), releasing can be done semi-manually. Since this requires obtaining environment secrets, this can only be done by a Googler. See go/flutter-gallery-manual-deployment.


</details>

## Tests

The gallery has its own set of unit, golden, and integration tests.

In addition, Flutter itself uses the gallery in tests. To enable breaking changes, the gallery version is pinned in two places:

- `flutter analyze`: https://github.com/flutter/tests/blob/master/registry/flutter_gallery.test
- DeviceLab tests: https://github.com/flutter/flutter/blob/master/dev/devicelab/lib/versions/gallery.dart

[latest release]: https://github.com/flutter/gallery/releases/latest


## Generating localized strings and highlighted code segments

To generate localized strings or highlighted code segments, make sure that you
have [grinder](https://pub.dev/packages/grinder) installed by running 
```bash
flutter pub get
```

To generate localized strings (see separate [README](lib/l10n/README.md)
for more details):

```bash
flutter pub run grinder l10n
```

To generate code segments (see separate [README](tool/codeviewer_cli/README.md) for
more details):
```bash
flutter pub run grinder update-code-segments
```

## Creating a new release (for Flutter org members)

1. Bump the version number up in the `pubspec.yaml`. Use semantic versioning to determine
   which number to increment. For example `2.2.0+020200` should become `2.3.0+020300`.

2. Publish the firebase hosted web release.
    * Log in to the account that has write access to `gallery-flutter-dev` with `firebase login`
    * `flutter build web`
    * `firebase deploy -P prod` to deploy to production (equivalent to `firebase deploy`).
    * `firebase deploy -P staging` to deploy to staging. Check with the team to see if the staging
       instance is currently used for a special purpose.

3. Publish the Android release
    * Ensure you have the correct signing certificates.
    * Create the app bundle with `flutter build appbundle`.
    * Upload to the Play store console.
    * Publish the Play store release.
    * Create the APK with `flutter build apk` (this is for the Github release).

4. Draft a release in Github, calling the release `Flutter Gallery 2.x`
    * The tag should be `v2.x` and the target `master`.
    * Upload the Android APK from above.
    * Create and upload the macOS build by running `flutter build macos` and zipping the 
      app inside `build/macos/Build/Products/Release`.
    * On a Linux machine, create and upload the Linux build by running `flutter build linux`
      and compress the contents of `build/linux/release/bundle`.
    * On a Windows machine, create and upload the Windows build by running `flutter build windows`
       and zipping the contents of `build/windows/release`.
    * Publish the release.



## Run Commands

### Local Development

1. **Build the local container:**
   ```bash
   docker build -t hello-world .
   ```

2. **Run the local container:**
   ```bash
   docker run --rm -it -p 8083:8080 hello-world
   ```

3. **Access the application:**
   Browse at `http://<MACHINE_IP>:8083`

### CI/CD (Drone/CircleCI/GitHub)

1. **Pull the container from the shared registry:**
   ```bash
   docker pull registry.hub.docker.com/dockerdig/gallery-dev:<ci_used>
   ```

2. **Run the container:**
   ```bash
   docker run --rm -it -p 8083:8080 registry.hub.docker.com/dockerdig/gallery-dev:<ci_used>
   ```

---

## Flutter Commands

### General

Run the `runner` script for various tasks:
```bash
bash runner
```

### iOS (MacOS, Non-Docker)

1. **Clean generated files:**
   ```bash
   bash runner clean
   ```

2. **Build for iOS:**
   ```bash
   bash runner ios-build
   ```

3. **Run on iOS simulator:**
   ```bash
   bash runner ios-run
   ```

### Android

1. **Build for Android:**
   ```bash
   bash runner android-build
   ```

2. **Run on Android simulator:**
   ```bash
   bash runner android-run
   ```

---

## Additional Notes

- Use `_ops/.env.temp` to override `_ops/.env` properties locally.
- Set `USE_DOCKER=false` for native MacOS development.

### Version Management

- **Bump version:** Increment the version in `pubspec.yaml` for incremental builds and deployments:
  ```bash
  bash _ops/utils/bump.sh
# Tags are used to control ops deployment to testflight/appstore
  ```

### Update Mac environment
brew update
brew upgrade
brew install cocoapods
which ruby && ruby -v
# make sure ruby is brew version else,
brew link ruby
~/flutter/flutter/bin/flutter upgrade
gem update
# find Podfiles and update in those folders
find ./ -type f -name Podfile
pod update
# find Gemfiles and bundle update in those folders
find ./ -type f -name Gemfile
bundle update
### upgrade flutter
export FLUTTER_HOME=$HOME/flutter/flutter/bin
$FLUTTER_HOME/flutter upgrade
### upgrade android
export ANDROID_HOME=$HOME/Library/Android/sdk/cmdline-tools/latest/bin
$ANDROID_HOME/sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0" "ndk;27.0.12077973"

