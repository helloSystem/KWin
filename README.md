# KWin.app

## Motivation

Installing the `plasma5-kwin` package on FreeBSD draws in hundreds of megabytes. Hence this approach at packaging KWin and BreezeEnhanced in a way that minimizes its dependencies.

The resulting `KWin.app` is smaller by roughly a factor of 10 compared to FreeBSD packaging.

## Usage

* Run FreeBSD 12.2 with the `plasma5-kwin` and `breezeenhanced` packages installed
* Create and change to a temporary directory
* Run `makebundle.sh`

Alternatively, download a pre-made `KWin.app.zip` from GitHub Releases.

* Run helloSystem 0.4.0 Live ISO (it does not contain the `plasma5-kwin` and `breezeenhanced` packages nor many of their dependencies)
* `sudo pkg install -y xcb-util-cursor`
* Should now be able to run the `KWin.app` produced earlier

## Notes

* Part of the size reduction comes from using stub libraries that just do nothing but implement the symbols to satisfy the dependencies without having to change the source code. `kwin_x11` can run fine when using stubs for libKF5Attica, libKF5Crash, libKScreenLocker, libKF5Notifications, libKF5Codecs, libKF5Auth, libKF5AuthCore, libKF5WidgetsAddons, libKF5WaylandClient, libKWaylandServer, libwayland_server
* Hence, making those weak (optional) dependencies or removing them altogether as dependencies should be possible by patching the KWin source code. Any help appreciated.
* When trying to also replace the libKF5KIOCore, libKF5KIOWidgets, libKF5XmlGui libraries with stubs, then we get `dbus[2585]: arguments to dbus_message_iter_append_basic() were incorrect, assertion "*bool_p == 0 || *bool_p == 1" failed in file dbus-message.c line 2783.` Possibly this can be solved by patching the KWin source code. Any help appreciated.
* When trying to also replace the libKF5ConfigGui and libKF5ConfigWidgets libraries with stubs, then `kwin_x11` refuses to run even when invoked with `--lock`. Possibly this can be solved by patching the KWin source code. Any help appreciated.
* It is not clear how central the following are to the operation of KWin and whether making them optional would be feasible: libKF5Plasma, libKF5GuiAddons, libKF5Package, libKF5ConfigGui, libKF5Service, libKF5CoreAddons, libKF5I18n. Trying to replace those with stubs leads to crashes. Possibly this can be solved by patching the KWin source code. Any help appreciated.
