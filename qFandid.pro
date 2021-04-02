QT += quick quickcontrols2 svg widgets gui webview

CONFIG += c++11 qmltypes

# For adding Android libraries when compiling for Android, otherwise the compilation will fail
android {
QT += androidextras
}

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        backend.cpp \
        main.cpp \
        blurhashC/decode.c

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Custom C++ backend
QML_IMPORT_NAME = qFandid.Backend
QML_IMPORT_MAJOR_VERSION = 1

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

# Set executable name
TARGET = Fandid

# Set Windows icon
win32 {
RC_ICONS = Assets/Images/winicon.ico
}

HEADERS += \
    backend.h \
    blurhashC/common.h \
    blurhashC/decode.h \
    blurhashC/stb_writer.h

# armeabi-v7a arm64-v8a x86 x86_64
ANDROID_ABIS += arm64-v8a armeabi-v7a

OTHER_FILES += \
    Android-source/AndroidManifest.xml \
    Android-source/build.gradle \
    Android-source/gradle.properties \
    Android-source/gradle/wrapper/gradle-wrapper.jar \
    Android-source/gradle/wrapper/gradle-wrapper.properties \
    Android-source/gradlew \
    Android-source/gradlew.bat \
    Android-source/res/values/libs.xml \
    Android-source/res/xml/fileprovider.xml

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/Android-source
android: include(/home/user/Android/Sdk/android_openssl/openssl.pri)

DISTFILES += \
    Android-source/src/org/sien/qfandid/Backend.java \
    Android-source/src/org/sien/qfandid/MainActivity.java \
    Android-source/src/org/sien/qfandid/NotificationClickReceiver.java
android: include(/home/user/Android/Sdk/android_openssl/openssl.pri)
