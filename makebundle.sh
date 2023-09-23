#!/bin/sh

# Be verbose
set -x

# This has been tested on FreeBSD 13.2

PREFIX=/usr/local
if [ "$(uname)" = "Linux" ]; then
    PREFIX=/usr
fi

# Get the direct dependencies of the ELF binary
readelf -d "$(which kwin_x11)" | grep "NEEDED" | awk '{print $5}' | sed -e 's|\[||g' | sed -e 's|\]||g' | sort | uniq

# Apparently the following libraries can be replaced as-is with stubs
# with no ill side effects for a non-Plasma desktop. They should hence
# be made weak (optional) dependencies
libraries="
libKF5Archive.so
libKWaylandServer.so.5
libwayland-server.so.0
libKF5WaylandClient.so.5
libKF5WaylandServer.so.5
libKF5Auth.so.5
libKF5AuthCore.so.5
libKF5Codecs.so.5
libKScreenLocker.so.5
libKF5Notifications.so.5
libKF5Crash.so.5
libKF5WidgetsAddons.so.5
libKF5Attica.so.5
"

path="${PREFIX}/lib/"
if [ "$(uname)" = "Linux" ]; then
    path="${PREFIX}/lib/x86_64-linux-gnu/"
fi

for library in $libraries; do
    ./so-stub.sh "$path$library"
done

# libKF5Activities.so.5 # Leads to crash if --no-kactivities is not used
# As of FreeBSD 13.2 with quarterly packages in Q3/2023, it leads to crash even with --no-kactivities

# FIXME: version Qt_5 required by "${PREFIX}/lib/libKF5GuiAddons.so.5 not defined
# How can we stub this?
# libQt5WaylandClient.so.5
# libQt5Network.so.5 # Why should a window manager access the network?
# libQt5Sensors.so.5 # Why should a window manager access sensors?

# FIXME: Apparently the following libraries cannot be replaced as-is with stubs,
# here it needs to be understood whether they are so essential
# that KWin cannot operate without them at all
# libKF5KIOCore.so.5 # dbus[2585]: arguments to dbus_message_iter_append_basic() were incorrect, assertion "*bool_p == 0 || *bool_p == 1" failed in file dbus-message.c line 2783.
# libKF5KIOWidgets.so.5 # dbus[2585]: arguments to dbus_message_iter_append_basic() were incorrect, assertion "*bool_p == 0 || *bool_p == 1" failed in file dbus-message.c line 2783.
# libKF5XmlGui.so.5 # dbus[2585]: arguments to dbus_message_iter_append_basic() were incorrect, assertion "*bool_p == 0 || *bool_p == 1" failed in file dbus-message.c line 2783.
# libKF5Plasma.so.5 # Leads to crash; why? Can Plasma be made optional?
# libKF5GuiAddons.so.5 # Leads to crash; why? This seems to be what needs libQt5WaylandClient
# libKF5Package.so.5 # Leads to crash; why? What is this needed for?
# libKF5ConfigGui.so.5 # Leads to crash; why? Config GUI code should be separate binary
# libKF5ConfigWidgets.so.5 # Leads to crash; why? Config GUI code should be separate binary
# libKF5Service.so.5 # Leads to crash; why? Is it needed for finding KWin plugins?
# libKF5CoreAddons.so.5 # Leads to crash; why?
# libKF5I18n.so.5 # Leads to crash; why? We don't want the window manager to have any user-visible strings

echo "Stubbed libraries:"
env LD_LIBRARY_PATH=. ldd "$(which kwin_x11)" | grep  '\./'

echo "Deploying into bundle"
rm -rf KWin.app || true
mkdir -p KWin.app/Resources/lib
cp "$(which kwin_x11)" KWin.app/Resources/kwin_x11 # Needs to retain its name in order for correct mesa configs to apply
mv lib* KWin.app/Resources/lib/
patchelf --set-rpath '$ORIGIN:'"$(patchelf --print-rpath KWin.app/Resources/kwin_x11)" KWin.app/Resources/kwin_x11

# Also bundle the rest of KF5 that is not stubbed
# Bundle KF5 libraries
for libkf5 in $(ldd './KWin.app/Resources/kwin_x11' | awk '/KF5/ {print $3}'); do
    cp -n "$libkf5" ./KWin.app/Resources/lib/
done
# Bundle kwin libraries
for libkwin in $(ldd './KWin.app/Resources/kwin_x11' | awk '/libkwin/ {print $3}'); do
    cp -n "$libkwin" ./KWin.app/Resources/lib/
done
# Bundle libkdecorations libraries
for libkdecorations in $(ldd './KWin.app/Resources/kwin_x11' | awk '/libkdecorations/ {print $3}'); do
    cp -n "$libkdecorations" ./KWin.app/Resources/lib/
done

# Bundle "${PREFIX}/lib/qt5/plugins/org.kde.kwin.platforms/KWinX11Platform.so
mkdir -p ./KWin.app/Resources/plugins/org.kde.kwin.platforms
cp "${path}/qt5/plugins/org.kde.kwin.platforms/KWinX11Platform.so" ./KWin.app/Resources/plugins/org.kde.kwin.platforms/
cat > ./KWin.app/KWin <<\EOF
#!/bin/sh

HERE="$(dirname "$(readlink -f "${0}")")"

# Note: The name 'kwin_x11' is hardcoded, e.g., in "${PREFIX}/share/drirc.d/01-freebsd.conf, so it must not be changed
exec env XDG_DATA_DIRS="${HERE}/Resources/share/:${XDG_DATA_DIRS}" env QT_PLUGIN_PATH="${HERE}/Resources/plugins:$QT_PLUGIN_PATH" LD_LIBRARY_PATH="${HERE}/Resources/lib:$LD_LIBRARY_PATH" "${HERE}/Resources/kwin_x11" --replace --lock --no-kactivities "$@"

pkill -f kglobalaccel5
kglobalaccel5 &

# TODO: Use QCoreApplication::addLibraryPath() to also load plugins
# from a location relative to the KWin executable, removing the need for this file
# QCoreApplication::applicationDirPath() + "/Resources/plugins"

# FATAL ERROR: could not instantiate the platform plugin
# can mean:
# FreeBSD% LD_LIBRARY_PATH=./KWin.app/Resources/lib ldd Desktop/KWin.app/Resources/plugins/org.kde.kwin.platforms/KWinX11Platform.so | grep "not found"
#        libxcb-cursor.so.0 => not found (0)
#
# --> sudo pkg install -y xcb-util-cursor
EOF

# Are these needed to be installed in the system?
# Why can't D-Bus work without having to (as root) install files into the filesystem?
# "${PREFIX}/share/dbus-1/interfaces/org.kde.KWin.VirtualDesktopManager.xml"
# "${PREFIX}/share/dbus-1/interfaces/org.kde.KWin.xml"
# "${PREFIX}/share/dbus-1/interfaces/org.kde.kwin.ColorCorrect.xml"
# "${PREFIX}/share/dbus-1/interfaces/org.kde.kwin.Compositing.xml"
# "${PREFIX}/share/dbus-1/interfaces/org.kde.kwin.Effects.xml"

chmod +x ./KWin.app/KWin

# Bundle BreezeEnhanced
# FIXME: Is there a way to tell KWin to use BreezeEnhanced via an environment variable?
mkdir -p ./KWin.app/Resources/plugins/org.kde.kdecoration2/
cp "${path}/qt5/plugins/org.kde.kdecoration2/breezeenhanced.so ./KWin.app/Resources/plugins/org.kde.kdecoration2/
cp "${PREFIX}/lib/libbreezeenhancedcommon5.so* ./KWin.app/Resources/lib

# Bundle libkwinxrenderutils
cp "${path}/libkwinxrenderutils.so* ./KWin.app/Resources/lib

# Bundle "${path}/qt5/plugins/platforms/KWinQpaPlugin.so
rm ./KWin.app/Resources/plugins/platforms/KWinQpaPlugin.so || true
mkdir -p ./KWin.app/Resources/plugins/platforms/
cp "${path}/qt5/plugins/platforms/KWinQpaPlugin.so ./KWin.app/Resources/plugins/platforms/

# Bundle "${PREFIX}"/lib/qt5/plugins/platforms/org.kde.kwin.scenes
cp -r "${path}/qt5/plugins/org.kde.kwin.scenes ./KWin.app/Resources/plugins/

# Bundle libstdc++.so.6
#cp -r "${path}/gcc10/libstdc++.so.6 ./KWin.app/Resources/lib

# Get these loaded from within the .app bundle using $XDG_DATA_DIRS
mkdir -p ./KWin.app/Resources/share/
cp -r "${PREFIX}"/share/kwin ./KWin.app/Resources/share/

# Glow effect when mouse moves to upper-left corner
mkdir -p ./KWin.app/Resources/share/plasma/desktoptheme/widgets/
cp "${PREFIX}"/share/plasma/desktoptheme/widgets/glowbar.svgz ./KWin.app/Resources/share/plasma/desktoptheme/widgets/
# Window snap effect preview
cp "${PREFIX}"/share/plasma/desktoptheme/widgets/translucentbackground.svgz ./KWin.app/Resources/share/plasma/desktoptheme/widgets/

# Icon
wget -c "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Breezeicons-apps-48-kwin.svg/256px-Breezeicons-apps-48-kwin.svg.png" -O KWin.app/Resources/KWin.png

# launch ./KWin.app --replace &
