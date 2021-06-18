# KWin.app

## Motivation

[KWin](https://userbase.kde.org/KWin/en) is the window manager used in KDE Plasma but increasingly also sees adoption on Qt-based desktop systems that are otherwise not using KDE Plasma, including CutefishOS, CyberOS, Deepin, Nitrux, and [helloSystem](hellosystem.github.io) beginning with 0.5.0. However, KWin and its packaging are currently not optimized for use outside of KDE Plasma yet, drawing in "half of KDE Plasma" as dependencies.

Installing the `plasma5-kwin` package on helloSystem draws in hundreds of megabytes. 

Hence this approach at packaging KWin and [BreezeEnhanced](https://github.com/helloSystem/BreezeEnhanced/) in a way that minimizes its dependencies. The resulting `KWin.app` [application bundle](https://hellosystem.github.io/docs/developer/application-bundles) is smaller by roughly a factor of 10 compared to FreeBSD packaging.

This repository is intended as a starting point to work with upstream KWin developers on "KWinLite", a build configuration of KWin that draws in as few dependencies as possible while still maintaining the core functionality of a window manager to be used on Qt-based desktop systems other than KDE Plasma.

## Running

* Run helloSystem 0.4.0 Live ISO (it does not contain the `plasma5-kwin` and `breezeenhanced` packages nor many of their dependencies)
* `sudo pkg install -y xcb-util-cursor`
* Download `KWin.app.zip` from GitHub Releases
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

## TODO

* Work with upstream to remove the need for stub libraries by making the respective libraries weak (optional) dependencies or removing them altogether as dependencies
* Add a `.cirrus-ci.yml` to this repository that builds KWin from source on FreeBSD 12, containing the source code changes

## Acknowledgements

* https://github.com/jackyf/so-stub/
