# KWin.app

## Motivation

Installing the `plasma5-kwin` package on FreeBSD draws in hundreds of megabytes. Hence this approach at packaging [KWin](https://userbase.kde.org/KWin/en) and [BreezeEnhanced](https://github.com/helloSystem/BreezeEnhanced/) in a way that minimizes its dependencies.

The resulting `KWin.app` [application bundle](https://hellosystem.github.io/docs/developer/application-bundles) is smaller by roughly a factor of 10 compared to FreeBSD packaging.

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

## Acknowledgements

* https://github.com/jackyf/so-stub/
