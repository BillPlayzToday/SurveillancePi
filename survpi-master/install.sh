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

echo "Installing additional packages, if not installed. (1/2)"
apt install git -y
apt install python3-dev -y
apt install python3-pip -y
apt install build-essential -y
apt install libssl-dev -y
apt install libffi-dev -y
apt install python3-setuptools -y
apt install python3-venv -y
apt install ufw -y

echo "Installing required packages."
apt install python3-venv -y

echo "Cloning master directory."
git clone --depth 1 --filter=blob:none --sparse https://github.com/BillPlayzToday/SurveillancePi
cd SurveillancePi
git sparse-checkout set survpi-master
cd survpi-master

echo "Installing..."
ufw allow 22
ufw allow 80
ufw allow 8888
mv -f ./survpi.service /etc/systemd/system/
mv -f ./uninstall.sh /home/pi/SurveillancePi/
mv -f ./reinstall.sh /home/pi/SurveillancePi
mv -f ./web.nginx /etc/nginx/sites-available/survpi-web
ln -f /etc/nginx/sites-available/survpi-web /etc/nginx/sites-enabled/
systemctl restart nginx
chmod 777 /home/pi/SurveillancePi/uninstall.sh
chmod 777 /home/pi/SurveillancePi/reinstall.sh
chmod 777 /home/pi/SurveillancePi/survpi-master/
python3 -m venv .env

echo "Installing additional packages, if not installed. (2/2)"
/home/pi/SurveillancePi/survpi-master/.env/bin/pip install wheel uwsgi flask

echo "Starting service..."
systemctl enable survpi
systemctl start survpi

echo "Done. (UFW configured, but not enabled)"