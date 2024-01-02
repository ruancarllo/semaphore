# [Semaphore](https://github.com/ruancarllo/semaphore) &middot; ![License](https://img.shields.io/badge/License-BSD--3--Clause_Clear-darkorchid?style=flat-square) ![Framework](https://img.shields.io/badge/Framework-Flutter-dodgerblue?style=flat-square) ![Language](https://img.shields.io/badge/Language-Dart-darkturquoise?style=flat-square)

Semaphore is a cross-platform application designed to organize and filter business tasks, arranging them in a date and price relationship. Its user interface is modern, allowing a simplified view of a complex set of orders.

<br>

<p align="center">
  <img src="./app/assets/icons/semaphore-icon-rounded.png" alt="Semaphore icon" width="250">
</p>


## Building

To distribute the application for the Android and iOS operating systems, install the latest version of [Flutter](https://flutter.dev) on your computer and follow the step-by-step guide, with steps based on Unix system commands:

1. Open your terminal in the [app](./app) folder:

```shell
cd app
```

2. Generate the necessary files with their respective dependencies:

```shell
flutter create --platforms android,ios .
```

3. Store program translations using Dart language resources:

```shell
flutter gen-l10n
```

4. Remove unnecessary files for the task:

```shell
rm -rf .idea .metadata .gitignore test app.iml README.md
```

5. Download the third-party font used in the interface:

```shell
curl "https://fonts.google.com/download?family=Archivo+Narrow" -o assets/fonts/ArchivoNarrow.zip
unzip assets/fonts/ArchivoNarrow.zip -d assets/fonts/ArchivoNarrow
rm -rf assets/fonts/ArchivoNarrow.zip
```

6. Set the application name to Semaphore:

```shell
dart run rename setAppName --targets android,ios --value "Semaphore"
```

7. Generate icons for both supported operating systems:

```shell
dart run flutter_launcher_icons
```

8. Build the distributable package and display it in the [mobile](./app/mobile) folder:

```shell
flutter build apk
cp build/app/outputs/flutter-apk/app-release.apk mobile/semaphore.apk
```

## Resetting

If you want to reset this project to its original repository conditions, run this command in the [app](./app) folder.

```shell
rm -rf .dart_tool .flutter-plugins .flutter-plugins-dependencies android ios build assets/fonts/ArchivoNarrow
```

## Preview

<p align="center">
  <img src="docs/Application preview 1.png" width="30%">
  <img src="docs/Application preview 3.png" width="30%">
  <img src="docs/Application preview 5.png" width="30%">
</p>