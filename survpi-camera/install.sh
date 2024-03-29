if [ "$EUID" != "0" ]
then
    echo "Please run the install script as root or sudo."
    exit
fi

if [ "$PWD" != "/home/pi" ]
then
    echo "Please run the install script inside the /home/pi folder."
    exit
fi

echo "Updating packages..."
apt update
apt upgrade -y

echo "Installing additional packages, if not installed."
apt install git -y
apt install ufw -y

echo "Installing required packages."
apt install python3-venv -y

echo "Cloning camera directory."
git clone --depth 1 --filter=blob:none --sparse https://github.com/BillPlayzToday/SurveillancePi
cd SurveillancePi
git sparse-checkout set survpi-camera
git sparse-checkout add modules
cd survpi-camera

echo "Installing..."
ufw allow 22
mv -f ./survpi.service /etc/systemd/system/
mv -f ./uninstall.sh /home/pi/SurveillancePi/
mv -f ./reinstall.sh /home/pi/SurveillancePi
chmod 777 /home/pi/SurveillancePi/uninstall.sh
chmod 777 /home/pi/SurveillancePi/reinstall.sh
chmod 777 /home/pi/SurveillancePi/survpi-camera/
python3 -m venv .env

echo "Moving modules..."
cd ../..
mv -f ./SurveillancePi/modules/*.py ./SurveillancePi/survpi-camera/
rm -f -r ./SurveillancePi/modules/

echo "Starting service..."
systemctl enable survpi
systemctl start survpi

echo "Done. (UFW configured, but not enabled)"