
# qFandid
qFandid is a Qt frontend for the social media Fandid created by Krestek

# Build instructions

**Linux:**
- The main dependencies are `qt5-base` and `qt5-webview`
- Clone the source code in a directory of your choosing
- cd to that directory and execute the following
1. `mkdir build-dir && cd build-dir`
2. `qmake  ../qFandid.pro -spec linux-g++ CONFIG+=qtquickcompiler`
3. `make install`

You will now have qFandid installed in `/opt/qFandid/bin`. Alternatively you can only run `make -f Makefile` to compile the app without copying the executable elsewhere. From there you can place it yourself wherever you want.

**Windows 10 64-bit:**

1. Install Visual Studio Community 2019 with the default components from the `Desktop development with C++` kit **and also** `C++ Clang tools for Windows`. This step is necessary because the C++ toolchain provided with Qt, MinGW, does not support Qt WebEngine needed for account registration.
2. Download the open source version of Qt from https://www.qt.io/download-qt-installer
3. Register a Qt account to log into the installer
4. Start the installer, when you need to select which components to install, open the subdirectory Qt / Qt 5.15.2. From there choose the components
- MSVC 2019 64-bit
- Qt WebEngine
5. Now go to `Developer and Designer Tools` and choose the following components
- Ninja 1.10.0
- OpenSSL 1.1.1j Toolkit
6. Continue with the installation and finish it. You should now have Qt and Qt Creator installed on your computer and the main Qt SDK folder should be located in `C:\Qt`
7. Download the source code
8. Open Qt Creator and import the project
9. You should be in the projects page. If not, choose `Projects` from the top left.
10. Choose the kit called  `Desktop Qt 5.15.2 MSVC2019 64bit`. It should be set up automatically after installing the prerequisites mentioned above.
11. A little above the kit, there will be a button called `Manage Kits...`. Click on it, then you will see several automatically detected kits. Click on `Desktop Qt 5.15.2 MSVC2019 64bit`. In the extra settings revealed below, go to the `Compiler:` section, and change the `C:` compiler from `Microsoft Visual C++ Compiler ...` to `Default LLVM 64 bit based on MSVC 2019`. You can now close this page
12. From the top of the `Projects` page, where it says `Build Settings`, next to `Edit build configuration` change `Debug` to `Release`
13. Select a build directory or leave the default.
14. In the `Build Steps` section, click on the `Details` button on the `qmake` step to reveal extra options. In the `Additional arguments:` field, paste the following `-spec win32-clang-msvc`.
15. Click the hammer button on the bottom left to build the program and wait for it to finish. You can then close Qt Creator
16. Open the build directory, go to the `release` folder and delete everything from there **except** the `Fandid.exe` file
17. Open a command prompt and execute `"C:\Qt\5.15.2\msvc2019_64\bin\windeployqt.exe" --no-translations --qmldir "path\to\folder\containing\the\source\code" "path\to\build\directory\release\Fandid.exe"`
18. Now because `windeployqt.exe` is a bit unreliable some manual intervention is needed. Go to the build folder and create a new directory called `plugins`. Then move the `webview` folder inside `plugins`.
19. Go to the folder `C:\Qt\Tools\OpenSSL\Win_x64\bin` and copy the following files to the same folder as the exe
- `libcrypto-1_1-x64.dll`
- `libssl-1_1-x64.dll`
20. Install Microsoft Visual C++ Redistributable Package (x64) version 2010 from https://www.microsoft.com/en-us/download/details.aspx?id=13523 because OpenSSL depends on it

You will now have a usable qFandid Windows 10 64-bit version. Start `Fandid.exe` to launch it.

**Android (coming soon)**
