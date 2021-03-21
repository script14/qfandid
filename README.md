
# qFandid
qFandid is a Qt frontend for the social media Fandid created by Krestek

# Build instructions

**Linux:**
- Have `qt5-base` installed
- Clone the source code in a directory of your choosing
- cd to that directory and execute the following
1. `mkdir build-dir && cd build-dir`
2. `qmake  ../qFandid.pro -spec linux-g++ CONFIG+=qtquickcompiler`
3. `make install`

You will now have qFandid installed in `/opt/qFandid/bin`. Alternatively you can only run `make -f Makefile` to compile the app without copying the executable elsewhere. From there you can place it yourself wherever you want.

**Windows 10 64-bit:**

1. Download the open source version of Qt from https://www.qt.io/download-qt-installer
2. Register a Qt account to log into the installer
3. Start the installer, when you need to select which components to install, open the subdirectory Qt / Qt 5.15.2. From there choose the component
- MinGW 8.1.0 64-bit
4. Now go to `Developer and Designer Tools`
5. Choose the following components
- Ninja 1.10.0
- OpenSSL 1.1.1j Toolkit
6. Continue with the installation and finish it. You should now have Qt and Qt Creator installed on your computer and the main Qt SDK folder should be located in `C:\Qt`
7. Download the source code
8. Open Qt Creator and import the project
9. You should be in the projects page. If not, choose `projects` from the left.
10. Click on  `Desktop Qt 5.15.2 MinGw 64-bit`
11. From the top of the new page, where it says `Edit build configuration`, choose `Release`
12. Select a build directory or leave the default
13. Click the hammer button on the bottom left to build the program. You can now close Qt Creator
14. Open the build directory, go to the `release` folder and delete everything from there **except** the `Fandid.exe` file
15. Open a command prompt and execute `"C:\Qt\5.15.2\mingw81_64\bin\windeployqt.exe" --no-translations --qmldir "path\to\folder\containing\the\source\code" "path\to\build\directory\release\Fandid.exe"`
16. Go to the folder `C:\Qt\5.15.2\mingw81_64\bin` and copy the following files to the same folder as the exe
- `libgcc_s_seh-1.dll`
- `libstdc++-6.dll`
- `libwinpthread-1.dll`
17. Go to the folder `C:\Qt\Tools\OpenSSL\Win_x64\bin` and copy the following files to the same folder as the exe
- `libcrypto-1_1-x64.dll`
- `libssl-1_1-x64.dll`
18. Install Microsoft Visual C++ Redistributable Package (x64) version 2010 from https://www.microsoft.com/en-us/download/details.aspx?id=13523 because openssl depends on it

You will now have a usable qFandid Windows 10 64-bit version. Start `Fandid.exe` to launch it.

**Android (coming soon)**
