#!/bin/bash
# Root access check
if [ "$(whoami)" != "root" ]; then
	echo "You need to be root! Aborting"
	exit 1
fi
# Xdotool installed check
command -v xdotool >/dev/null 2>&1 || { echo >&2 "I require xdotool but it's not installed! Aborting."; exit 1; }

# Compilation
cd src
g++ -O3 -std=c++11 naga.cpp -o naga

if [ ! -f ./naga ]; then
	echo "Error at compile! Aborting"
	exit 1
fi

# Configuration
mv naga /usr/local/bin/
chmod 755 /usr/local/bin/naga

cd ..
HOME=$( getent passwd "$SUDO_USER" | cut -d: -f6 )

cp nagastart.sh /usr/local/bin/
chmod 755 /usr/local/bin/nagastart.sh



mkdir -p "$HOME"/.naga
cp -n mapping_{01,02,03}.txt "$HOME"/.naga/
chown -R ${SUDO_USER}:$(id -gn $SUDO_USER) "$HOME"/.naga/


# Deprecated autostart alternatives
# echo 'KERNEL=="event[0-9]*",SUBSYSTEM=="input",MODE="644"' > /etc/udev/rules.d/80-naga.rules

# autostart folder
#cp naga.desktop "$HOME"/.config/autostart/

# .profile
#if ! grep -Fxq "bash /usr/local/bin/nagastart.sh &" "$HOME"/.profile; then
#	echo "bash /usr/local/bin/nagastart.sh &" >> "$HOME"/.profile
#fi

sed -i "s/usr/$SUDO_USER/" naga@.service
sed -i "s/home/$HOME/" naga@.service
cp naga@.service /lib/systemd/system/

cp 80-naga.rules /etc/udev/rules.d/
udevadm control --reload
