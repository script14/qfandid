
# qFandid
qFandid is a Qt frontend for the social media Fandid created by Krestek

# Prebuilt binaries available in [https://fandid.app](https://fandid.app)

# Build instructions:

# Linux:
1. Install the dependencies `qt5-base` and `qt5-webview` for your distribution
2. Execute the following:
```bash
git clone "https://gitlab.com/exuberantdev/qfandid"
cd qfandid
mkdir build-dir && cd build-dir
qmake  ../qFandid.pro -spec linux-g++ CONFIG+=qtquickcompiler
make install
```

You will now have qFandid installed in `/opt/qFandid/bin`. Alternatively you can only run `make -f Makefile` to compile the app without copying the executable elsewhere. From there you can place it yourself wherever you want.

# Windows 10 64-bit:

1. Install Visual Studio Community 2019 with the default components from the `Desktop development with C++` kit **and also** `C++ Clang tools for Windows`. This step is necessary because the C++ toolchain provided with Qt, MinGW, does not support Qt WebEngine needed for account registration.
2. Download the open source version of Qt from https://www.qt.io/download-qt-installer.
3. Register a Qt account to log into the installer.
4. Start the installer, when you need to select which components to install, open the subdirectory `Qt/Qt 5.15.2`. From there choose the components:
- MSVC 2019 64-bit
- Qt WebEngine
5. Now go to `Developer and Designer Tools` and choose the following components:
- Ninja 1.10.0
- OpenSSL 1.1.1j Toolkit
6. Continue with the installation and finish it. You should now have Qt and Qt Creator installed on your computer and the main Qt SDK folder should be located in `C:\Qt`.
7. Download the source code.
8. Open Qt Creator and import the project.
9. You should be in the projects page. If not, choose `Projects` from the top left.
10. Choose the kit called  `Desktop Qt 5.15.2 MSVC2019 64bit`. It should be set up automatically after installing the prerequisites mentioned above.
11. A little above the kit, there will be a button called `Manage Kits...`. Click on it, then you will see several automatically detected kits. Click on `Desktop Qt 5.15.2 MSVC2019 64bit`. In the extra settings revealed below, go to the `Compiler:` section, and change the `C:` compiler from `Microsoft Visual C++ Compiler ...` to `Default LLVM 64 bit based on MSVC 2019`. You can now close this page.
12. From the top of the `Projects` page, where it says `Build Settings`, next to `Edit build configuration` change `Debug` to `Release`.
13. Select a build directory or leave the default.
14. In the `Build Steps` section, click on the `Details` button on the `qmake` step to reveal extra options. In the `Additional arguments:` field, paste the following `-spec win32-clang-msvc`.
15. Click the hammer button on the bottom left to build the program and wait for it to finish. You can then close Qt Creator.
16. Open the build directory, go to the `release` folder and delete everything from there **except** the `Fandid.exe` file.
17. Open a command prompt and execute `"C:\Qt\5.15.2\msvc2019_64\bin\windeployqt.exe" --release --no-translations --qmldir "path\to\folder\containing\the\source\code" "path\to\build\directory\release\Fandid.exe"`
18. Now because `windeployqt.exe` is a bit unreliable some manual intervention is needed. Go to the build folder and create a new directory called `plugins`. Then move the `webview` folder inside `plugins`.
19. Go to the folder `C:\Qt\Tools\OpenSSL\Win_x64\bin` and copy the following files to the same folder as the exe:
- `libcrypto-1_1-x64.dll`
- `libssl-1_1-x64.dll`
20. Install Microsoft Visual C++ Redistributable Package (x64) version 2010 from https://www.microsoft.com/en-us/download/details.aspx?id=13523 because OpenSSL depends on it.

You will now have a usable qFandid Windows 10 64-bit version. Start `Fandid.exe` to launch it.

# Android:
The following steps are performed on a Linux host operating system, but the steps should be similar on Windows as well. This will produce a multi-ABI APK for the architectures `armeabi-v7a` and `arm64-v8a`. Other supported architectures are `x86` and `x86_64`. It is possible to compile an APK for all 4 ABIS, but then the final APK will be very large.

1. Download the open source version of Qt from https://www.qt.io/download-qt-installer.
2. Register a Qt account to log into the installer.
3. Start the installer, when you need to select which components to install, open the subdirectory `Qt/Qt 5.15.2`. From there choose the components:
- Desktop gcc 64-bit
- Android
- Qt WebEngine
4. Now go to `Developer and Designer Tools` and choose the following components:
- CMake 3.19.2
- Conan 1.33
- Ninja 1.10.0
5. The main Qt SDK folder should be located in `$HOME/Qt`.
6. Install Android Studio.
7. Open Android Studio and click on `Configure`, then `SDK Manager` and you should be in the `SDK Platforms` tab.
8. Install an SDK such as `Android 11`. The SDK is not as important here compared to native Android applications because the features we can use in the application depend on the Qt version. Qt 5.15 should support Android versions from `Android 5` (API Level 21) and above.
9. Go to the `SDK Tools` tab and click on `Show Package Details` from the bottom of the settings window.
10. Drop down `Android SDK Build-Tools` and select version `30.0.2`.
11. Drop down `NDK (Side by side)` and select exactly version `21.3.*`.
12. Drop down `Android SDK Command-line Tools (latest)` and select `Android SDK Command-line Tools (latest)`.
13. Click ok and let it download and install everything necessary.
14. Open Qt Creator, go to `Tools` from the top menu, click on `Options`, then in the new window select `Devices` from the list on the left and choose the `Android` tab.
15. Check that the `JDK location` is valid. If you do not have JDK, install the latest version such as `jre-openjdk`. If this is ready Qt Creator will display a check mark and output `Java Settings are OK`.
16. Confirm that Qt Creator has successfully found the SDK and NDK by checking `Android SDK location` and `Android NDK list`. If it has not managed to find the correct directories, paste them in manually. If this is ready Qt Creator will display a check mark and output `Android Settings are OK. (SDK Version: 4.0, NDK Version: 21.3.*)`.
17. Make sure Qt Creator has placed a check mark on the following requirements:
- Android SDK path exists.
- Android SDK path writable.
- SDK tools installed.
- Build tools installed.
- SDK mnager runs (SDK Tools versions <= 26.x require exactly Java 1.8).
- Platform SDK installed.
- All essential packages installed for all installed Qt versions.
18. When entering the `Android` tab, if Qt Creator warns you that any packages are missing and offers to install them automatically, accept it.
19. In the `Android OpenSSL settings (Optional)` section, click on the button `Download OpenSSL` and wait for Qt Creator to install and setup OpenSSL for Android. OpenSSL is required because all network connections are done over SSL.
20. All prerequisites should now be set up. Go to the `Kits` page in the options window and confirm that Qt Creator has automatically created kits for Android.
21. I recommend building the APK on a fast device such as an SSD or in the `/tmp` directory, otherwise the compilation could take multiple minutes on a mechanical hard drive.
22. Execute the following:
```bash
git clone "https://gitlab.com/exuberantdev/qfandid"
cd qfandid
mkdir build-dir && cd build-dir
ANDROID_NDK_ROOT=$HOME/Android/Sdk/ndk/21.3.6528147 $HOME/Qt/5.15.2/android/bin/qmake ../qFandid.pro -spec android-clang CONFIG+=qtquickcompiler 'ANDROID_ABIS=armeabi-v7a arm64-v8a'
$HOME/Android/Sdk/ndk/21.3.6528147/prebuilt/linux-x86_64/bin/make -f Makefile qmake_all
$HOME/Android/Sdk/ndk/21.3.6528147/prebuilt/linux-x86_64/bin/make -j$(nproc)
$HOME/Android/Sdk/ndk/21.3.6528147/prebuilt/linux-x86_64/bin/make INSTALL_ROOT="$PWD/output" install
ANDROID_SDK_ROOT=$HOME/Android/Sdk $HOME/Qt/5.15.2/android/bin/androiddeployqt --input "$PWD/android-Fandid-deployment-settings.json" --output "$PWD/output" --android-platform android-30 --jdk /usr/lib/jvm/java-15-openjdk --gradle
```
23. You can now find the finished APK file in the directory `output/build/outputs/apk/debug/output-debug.apk`. You can now copy it to an Android phone and install it like any other APK.

You will now have an unsigned debug build of qFandid for Android. Alternatively, you can import the project in Qt Creator, go to the `Projects` tab, choose the Android kit, create a certificate and then compile a signed release build.