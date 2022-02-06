# F29SO - Team 1

## Group Members

- cb304 - Cameron Barker
- rjf2 - Pyra Firkins
- cm2013 - Craig MacGregor
- cm138 - Chloe Man
- hm108 - Harry McFarland
- ar233 - Amber Roe
- lms9 - Laura Schauer
- xz2021 - Aaron Zhang

## Setup Flutter (For Windows. For other platforms - https://docs.flutter.dev/get-started/install)

1. Install Git for Windows and make sure PowerShell 5^ is installed.
2. Install flutter sdk `git clone https://github.com/flutter/flutter.git -b stable` or from https://docs.flutter.dev/development/tools/sdk/releases so that the `flutter` folder is in your Documents folder.
3. Update your PATH user variable so that it includes `Documents\flutter\bin`
4. Run `flutter doctor`. This tells you that status of your flutter install and what platforms you havev debuging environments installed for. For the Chrome option even if you don't have Chrome installed you can use Edge(Chromium based versions). To debug Android install Android Studio which allows you to install the Android SKD and emulator. To debug iOS you need a MacOS device.

## Setup Android Development Environment

1. Install Android Studio and make sure Android SDK, Android SDK Command-line Tools, and Android SDK Build-Tools get installed. May need to install these manually, to do this open Android Studio, click 'More Actions' > 'SDK Manager' > 'SDK Tools' and make sure the needed options are ticked.
2. Install Android Emulator, to do this open Android Studio, click 'More Actions' > 'AVD Manager' > 'Create Virtual Device' and make sure to enable hardware acceleration.
3. Run `flutter doctor --android-licenses` to agree to the android licenses.
4. Run `flutter doctor` and make sure the 'Android toolchain' is ticked.

## Setup VS Code Editor

1. Install VS Code - https://code.visualstudio.com/
2. Install Flutter extension.
3. Run `flutter doctor` to make sure 'VS Code' is ticked.
