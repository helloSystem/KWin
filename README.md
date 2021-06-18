# KWin.app

## Motivation

[KWin](https://userbase.kde.org/KWin/en) is the window manager used in KDE Plasma. It increasingly sees adoption on Qt-based desktop systems that are otherwise not using KDE Plasma, including CutefishOS, CyberOS, Deepin, Nitrux, and [helloSystem](hellosystem.github.io) beginning with 0.5.0. However, KWin and its packaging are currently not optimized for use outside of KDE Plasma yet, drawing in "half of KDE Plasma" as dependencies.

Installing the `plasma5-kwin` package on helloSystem draws in hundreds of megabytes. 

```
FreeBSD% sudo pkg install plasma5-kwin
Updating FreeBSD repository catalogue...
FreeBSD repository is up to date.
All repositories are up to date.
The following 110 package(s) will be affected (of 0 checked):

New packages to be INSTALLED:
        aspell: 0.60.8_1,1
        boost-libs: 1.72.0_4
        brotli: 1.0.9,1
        docbook: 1.5
        docbook-sgml: 4.5_1
        docbook-xml: 5.0_3
        docbook-xsl: 1.79.1_1,1
        dotconf: 1.3_1
        espeak: 1.48.04_7
        fftw3: 3.3.9
        flac: 1.3.3
        gnupg: 2.2.27
        gpgme: 1.15.1
        gpgme-cpp: 1.15.1
        gpgme-qt5: 1.15.1
        gstreamer1-libav: 1.16.2
        gstreamer1-plugins-a52dec: 1.16.2
        gstreamer1-plugins-core: 1.16
        gstreamer1-plugins-dts: 1.16.2
        gstreamer1-plugins-dvdread: 1.16.2_1
        gstreamer1-plugins-mpg123: 1.16.2
        gstreamer1-plugins-pango: 1.16.2
        gstreamer1-plugins-png: 1.16.2
        gstreamer1-plugins-resindvd: 1.16.2_1
        gstreamer1-plugins-theora: 1.16.2
        gstreamer1-plugins-ugly: 1.16.2
        hyphen: 2.8.8
        iso8879: 1986_3
        kf5-attica: 5.80.0
        kf5-breeze-icons: 5.80.0
        kf5-frameworkintegration: 5.80.0
        kf5-kactivities: 5.80.0
        kf5-karchive: 5.80.0
        kf5-kauth: 5.80.0
        kf5-kbookmarks: 5.80.0
        kf5-kcmutils: 5.80.0
        kf5-kcodecs: 5.80.0
        kf5-kcompletion: 5.80.0
        kf5-kconfigwidgets: 5.80.0
        kf5-kcrash: 5.80.0
        kf5-kdeclarative: 5.80.0
        kf5-kded: 5.80.0
        kf5-kdelibs4support: 5.80.0
        kf5-kdesignerplugin: 5.80.0
        kf5-kdewebkit: 5.80.0
        kf5-kdoctools: 5.80.0
        kf5-kemoticons: 5.80.0
        kf5-kglobalaccel: 5.80.0
        kf5-kguiaddons: 5.80.0
        kf5-kiconthemes: 5.80.0
        kf5-kidletime: 5.80.0
        kf5-kinit: 5.80.0
        kf5-kio: 5.80.1
        kf5-kirigami2: 5.80.0
        kf5-kitemmodels: 5.80.0
        kf5-kitemviews: 5.80.0
        kf5-kjobwidgets: 5.80.0
        kf5-knewstuff: 5.80.0
        kf5-knotifications: 5.80.0
        kf5-kpackage: 5.80.0
        kf5-kparts: 5.80.0
        kf5-kplotting: 5.80.0
        kf5-kservice: 5.80.0
        kf5-ktextwidgets: 5.80.0
        kf5-kunitconversion: 5.80.0
        kf5-kwallet: 5.80.0
        kf5-kwayland: 5.80.0
        kf5-kwidgetsaddons: 5.80.0
        kf5-kxmlgui: 5.80.0
        kf5-plasma-framework: 5.80.0
        kf5-solid: 5.80.0
        kf5-sonnet: 5.80.0
        liba52: 0.7.4_3
        libassuan: 2.5.4
        libcanberra: 0.30_5
        libcanberra-gtk3: 0.30_5
        libdca: 0.0.7
        libksba: 1.5.0
        libsndfile: 1.0.31
        mpg123: 1.26.5
        npth: 1.6
        phonon-qt5: 4.11.1
        pinentry: 1.1.1
        pinentry-curses: 1.1.1
        pinentry-qt5: 1.1.1
        plasma-wayland-protocols: 1.2.1
        plasma5-breeze: 5.20.5
        plasma5-kdecoration: 5.20.5
        plasma5-kscreenlocker: 5.20.5
        plasma5-kwayland-server: 5.20.5
        plasma5-kwin: 5.20.5_1
        portaudio: 19.6.0_5,1
        qt5-assistant: 5.15.2
        qt5-designer: 5.15.2_1
        qt5-help: 5.15.2_1
        qt5-qdbus: 5.15.2
        qt5-sensors: 5.15.2_1
        qt5-speech: 5.15.2
        qt5-uiplugin: 5.15.2
        qt5-uitools: 5.15.2_1
        qt5-virtualkeyboard: 5.15.2_1
        qt5-wayland: 5.15.2_1
        qt5-webkit: 5.212.0.a4_4
        sdocbook-xml: 1.1_2,2
        speech-dispatcher: 0.8.8_1
        woff2: 1.0.2_4
        xcb-util-cursor: 0.1.3
        xmlcatmgr: 2.2_2
        xmlcharent: 0.3_2
        xwayland-devel: 1.20.0.907

Number of packages to be installed: 110

The process will require 552 MiB more space.
108 MiB to be downloaded.
```

Hence this approach at packaging KWin and [BreezeEnhanced](https://github.com/helloSystem/BreezeEnhanced/) in a way that minimizes its dependencies. The resulting `KWin.app` [application bundle](https://hellosystem.github.io/docs/developer/application-bundles) is smaller by roughly a factor of 20 compared to FreeBSD packaging.

This repository is intended as a starting point to work with upstream KWin developers on "KWinLite", a build configuration of KWin that draws in as few dependencies as possible while still maintaining the core functionality of a window manager to be used on Qt-based desktop systems other than KDE Plasma.

## Running

* Run [helloSystem 0.4.0 Live ISO](https://github.com/helloSystem/ISO/releases/tag/r0.4.0) (it does not contain the `plasma5-kwin` and `breezeenhanced` packages nor many of their dependencies)
* `sudo pkg install -y xcb-util-cursor`
* Download [KWin.app.zip](../../releases/download/latest/KWin.app.zip) from GitHub Releases
* Double-click to open the zip file
* Double-click KWin to launch it

## Building

* Run FreeBSD 12.2 with the `plasma5-kwin` and `breezeenhanced` packages installed
* Create and change to a temporary directory
* Run `makebundle.sh`

## Notes

* Part of the size reduction comes from using stub libraries that just do nothing but implement the symbols to satisfy the dependencies without having to change the source code. `kwin_x11` can run fine when using stubs for libKF5Attica, libKF5Crash, libKScreenLocker, libKF5Notifications, libKF5Codecs, libKF5Auth, libKF5AuthCore, libKF5WidgetsAddons, libKF5WaylandClient, libKWaylandServer, libwayland_server
* Hence, making those weak (optional) dependencies or removing them altogether as dependencies should be possible by patching the KWin source code. _Any help appreciated._
* When trying to also replace the libKF5KIOCore, libKF5KIOWidgets, libKF5XmlGui libraries with stubs, then we get `dbus[2585]: arguments to dbus_message_iter_append_basic() were incorrect, assertion "*bool_p == 0 || *bool_p == 1" failed in file dbus-message.c line 2783.` Possibly this can be solved by patching the KWin source code. _Any help appreciated._
* When trying to also replace the libKF5ConfigGui and libKF5ConfigWidgets libraries with stubs, then `kwin_x11` refuses to run even when invoked with `--lock`. Possibly this can be solved by patching the KWin source code. _Any help appreciated._
* It is not clear how central the following are to the operation of KWin and whether making them optional would be feasible: libKF5Plasma, libKF5GuiAddons, libKF5Package, libKF5ConfigGui, libKF5Service, libKF5CoreAddons, libKF5I18n. Trying to replace those with stubs leads to crashes. Possibly this can be solved by patching the KWin source code. _Any help appreciated._

## Known issues

* Snapping windows to screen edges does not work. It is unclear why.
* The highlight symbol that should appear when one is moving the mouse at the upper-left edge of the screen is missing. It still needs to be bundled.

## TODO

* Work with upstream to remove the need for stub libraries by making the respective libraries weak (optional) dependencies or removing them altogether as dependencies
* Add a `.cirrus-ci.yml` to this repository that builds KWin from source on FreeBSD 12, containing the source code changes

## Acknowledgements

* https://github.com/jackyf/so-stub/
