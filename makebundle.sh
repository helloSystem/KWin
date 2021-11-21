#!/bin/sh

# This has been tested on FreeBSD 12.2

# Get the direct dependencies of the ELF binary
readelf -d $(which kwin_x11) | grep "NEEDED" | awk '{print $5}' | sed -e 's|\[||g' | sed -e 's|\]||g' | sort | uniq

# Apparently the following libraries can be replaced as-is with stubs
# with no ill side effects for a non-Plasma desktop. They should hence
# be made weak (optional) dependencies
./so-stub.sh /usr/local/lib/libKF5Archive.so
./so-stub.sh /usr/local/lib/libKWaylandServer.so.5
./so-stub.sh /usr/local/lib/libwayland-server.so.0
./so-stub.sh /usr/local/lib/libKF5WaylandClient.so.5
./so-stub.sh /usr/local/lib/libKF5WaylandServer.so.5
./so-stub.sh /usr/local/lib/libKF5Auth.so.5
./so-stub.sh /usr/local/lib/libKF5AuthCore.so.5
./so-stub.sh /usr/local/lib/libKF5Codecs.so.5
./so-stub.sh /usr/local/lib/libKScreenLocker.so.5
./so-stub.sh /usr/local/lib/libKF5Notifications.so.5
./so-stub.sh /usr/local/lib/libKF5Crash.so.5
./so-stub.sh /usr/local/lib/libKF5WidgetsAddons.so.5
./so-stub.sh /usr/local/lib/libKF5Attica.so.5
./so-stub.sh /usr/local/lib/libKF5Activities.so.5 # Leads to crash if --no-kactivities is not used

# FIXME: version Qt_5 required by /usr/local/lib/libKF5GuiAddons.so.5 not defined
# How can we stub this?
# ./so-stub.sh /usr/local/lib/qt5/libQt5WaylandClient.so.5
# ./so-stub.sh /usr/local/lib/libQt5Network.so.5 # Why should a window manager access the network?
# ./so-stub.sh /usr/local/lib/libQt5Sensors.so.5 # Why should a window manager access sensors?

# FIXME: Apparently the following libraries cannot be replaced as-is with stubs,
# here it needs to be understood whether they are so essential
# that KWin cannot operate without them at all
# ./so-stub.sh /usr/local/lib/libKF5KIOCore.so.5 # dbus[2585]: arguments to dbus_message_iter_append_basic() were incorrect, assertion "*bool_p == 0 || *bool_p == 1" failed in file dbus-message.c line 2783.
# ./so-stub.sh /usr/local/lib/libKF5KIOWidgets.so.5 # dbus[2585]: arguments to dbus_message_iter_append_basic() were incorrect, assertion "*bool_p == 0 || *bool_p == 1" failed in file dbus-message.c line 2783.
# ./so-stub.sh /usr/local/lib/libKF5XmlGui.so.5 # dbus[2585]: arguments to dbus_message_iter_append_basic() were incorrect, assertion "*bool_p == 0 || *bool_p == 1" failed in file dbus-message.c line 2783.
# ./so-stub.sh /usr/local/lib/libKF5Plasma.so.5 # Leads to crash; why? Can Plasma be made optional?
# ./so-stub.sh /usr/local/lib/libKF5GuiAddons.so.5 # Leads to crash; why? This seems to be what needs libQt5WaylandClient
# ./so-stub.sh /usr/local/lib/libKF5Package.so.5 # Leads to crash; why? What is this needed for?
# ./so-stub.sh /usr/local/lib/libKF5ConfigGui.so.5 # Leads to crash; why? Config GUI code should be separate binary
# ./so-stub.sh /usr/local/lib/libKF5ConfigWidgets.so.5 # Leads to crash; why? Config GUI code should be separate binary
# ./so-stub.sh /usr/local/lib/libKF5Service.so.5 # Leads to crash; why? Is it needed for finding KWin plugins?
# ./so-stub.sh /usr/local/lib/libKF5CoreAddons.so.5 # Leads to crash; why?
# ./so-stub.sh /usr/local/lib/libKF5I18n.so.5 # Leads to crash; why? We don't want the window manager to have any user-visible strings

echo "Stubbed libraries:"
env LD_LIBRARY_PATH=. ldd $(which kwin_x11) | grep  '\./'

echo "Deploying into bundle"
rm -rf KWin.app || true
mkdir -p KWin.app/Resources/lib
cp $(which kwin_x11) KWin.app/Resources/kwin_x11 # Needs to retain its name in order for correct mesa configs to apply
mv lib* KWin.app/Resources/lib/
patchelf --set-rpath '$ORIGIN:'$(patchelf --print-rpath KWin.app/Resources/KWin) KWin.app/Resources/KWin

# Also bundle the rest of KF5 that is not stubbed
cp -n $(ldd './KWin.app/Resources/KWin' | grep KF5 | awk '{print $3}' | xargs) ./KWin.app/Resources/lib 2>/dev/null
# Also bundle kwin libraries
cp -n $(ldd './KWin.app/Resources/KWin' | grep libkwin | awk '{print $3}' | xargs) ./KWin.app/Resources/lib 2>/dev/null
cp -n $(ldd './KWin.app/Resources/KWin' | grep libkdecorations | awk '{print $3}' | xargs) ./KWin.app/Resources/lib 2>/dev/null

# Bundle /usr/local/lib/qt5/plugins/org.kde.kwin.platforms/KWinX11Platform.so
mkdir -p ./KWin.app/Resources/plugins/org.kde.kwin.platforms
cp /usr/local/lib/qt5/plugins/org.kde.kwin.platforms/KWinX11Platform.so ./KWin.app/Resources/plugins/org.kde.kwin.platforms/
cat > ./KWin.app/KWin <<\EOF
#!/bin/sh

HERE="$(dirname "$(readlink -f "${0}")")"

exec env XDG_DATA_DIRS="${HERE}/Resources/share/:${XDG_DATA_DIRS}" env QT_PLUGIN_PATH="${HERE}/Resources/plugins:/usr/local/lib/qt5/plugins/" LD_LIBRARY_PATH="${HERE}/Resources/lib:$LD_LIBRARY_PATH" "${HERE}/Resources/KWin" --replace --lock --no-kactivities "$@"

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
# /usr/local/share/dbus-1/interfaces/org.kde.KWin.VirtualDesktopManager.xml
# /usr/local/share/dbus-1/interfaces/org.kde.KWin.xml
# /usr/local/share/dbus-1/interfaces/org.kde.kwin.ColorCorrect.xml
# /usr/local/share/dbus-1/interfaces/org.kde.kwin.Compositing.xml
# /usr/local/share/dbus-1/interfaces/org.kde.kwin.Effects.xml

chmod +x ./KWin.app/KWin

# Bundle BreezeEnhanced
# FIXME: Is there a way to tell KWin to use BreezeEnhanced via an environment variable?
mkdir -p ./KWin.app/Resources/plugins/org.kde.kdecoration2/
cp /usr/local/lib/qt5/plugins/org.kde.kdecoration2/breezeenhanced.so ./KWin.app/Resources/plugins/org.kde.kdecoration2/
cp /usr/local/lib/libbreezeenhancedcommon5.so* ./KWin.app/Resources/lib

# Bundle /usr/local/lib/qt5/plugins/platforms/KWinQpaPlugin.so
rm ./KWin.app/Resources/plugins/platforms/KWinQpaPlugin.so || true
mkdir -p ./KWin.app/Resources/plugins/platforms/
cp /usr/local/lib/qt5/plugins/platforms/KWinQpaPlugin.so ./KWin.app/Resources/plugins/platforms/

# Bundle /usr/local/lib/qt5/plugins/platforms/org.kde.kwin.scenes
cp -r /usr/local/lib/qt5/plugins/org.kde.kwin.scenes ./KWin.app/Resources/plugins/

# Bundle libstdc++.so.6
#cp -r /usr/local/lib/gcc10/libstdc++.so.6 ./KWin.app/Resources/lib

# Get these loaded from within the .app bundle using $XDG_DATA_DIRS
mkdir -p ./KWin.app/Resources/share/
cp -r /usr/local/share/kwin ./KWin.app/Resources/share/

# Glow effect when mouse moves to upper-left corner
mkdir -p ./KWin.app/Resources/share/plasma/desktoptheme/default/widgets/
cp /usr/local/share/plasma/desktoptheme/default/widgets/glowbar.svgz ./KWin.app/Resources/share/plasma/desktoptheme/default/widgets/
# Window snap effect preview
cp /usr/local/share/plasma/desktoptheme/default/widgets/translucentbackground.svgz ./KWin.app/Resources/share/plasma/desktoptheme/default/widgets/

# Icon
wget -c "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Breezeicons-apps-48-kwin.svg/256px-Breezeicons-apps-48-kwin.svg.png" -O KWin.app/Resources/KWin.png

# launch ./KWin.app --replace &
