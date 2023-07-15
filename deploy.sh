#!/bin/bash

# Define log file
LOGFILE="/home/sadeghesfahani/setup.log"

# Step 1: Update the system
echo "Updating system..." >>$LOGFILE
sudo apt update 2>>$LOGFILE

# Step 2: Clone the Application Repository
counter=0
while [ $counter -lt 3 ]; do
  if [ -d "/home/sadeghesfahani/sensor_network" ]; then
    echo "sensor_network directory already exists. Removing..." >>$LOGFILE
    rm -rf /home/sadeghesfahani/sensor_network
  fi
  echo "Cloning the repository..."
  if git clone https://github.com/sadeghesfahani/sensor_network /home/sadeghesfahani/sensor_network >> "$LOGFILE" 2>&1; then
    echo "Repository cloned successfully." >>$LOGFILE
    break
  else
    echo "Failed to clone the repository. Retrying..." >>$LOGFILE
    ((counter++))
  fi
done

if [ $counter -ge 3 ]; then
  echo "Failed to clone the repository after 3 attempts. Please check the logs." >>$LOGFILE
  exit 1
fi

cd /home/sadeghesfahani/sensor_network

# Step 3: Set Up a Virtual Environment and Install Dependencies
echo "Setting up the virtual environment and installing dependencies..." >> $LOGFILE
python -m venv venv
source venv/bin/activate

# Step 4: Install the Required Python Packages
counter=0
while [ $counter -lt 3 ]; do
  if pip install -r requirements.txt 2>>$LOGFILE; then
    echo "Packages installed successfully."
    break
  else
    echo "Failed to install packages. Retrying..." >> $LOGFILE
    ((counter++))
  fi
done

if [ $counter -ge 3 ]; then
  echo "Failed to install packages after 3 attempts. Please check the logs." >> $LOGFILE
  exit 1
fi

# Step 4: Run the Django Application with Gunicorn
# We're running this in the background to continue the script
echo "Running the Django Application with Gunicorn..." >> $LOGFILE

echo "Creating system service" >> $LOGFILE
cat > /etc/systemd/system/gunicorn.service <<EOF
# /etc/systemd/system/gunicorn.service

[Unit]
Description=gunicorn daemon
After=network.target

[Service]
User=sadeghesfahani
Group=www-data
WorkingDirectory=/home/sadeghesfahani/sensor_network
ExecStart=/home/sadeghesfahani/sensor_network/venv/bin/gunicorn \
          --access-logfile - \
          --workers 3 \
          --bind unix:/home/sadeghesfahani/sensor_network/sensor_network.sock \
          sensor_network.wsgi:application

[Install]
WantedBy=multi-user.target
EOF

echo "Starting gunicorn service" >> $LOGFILE
sudo systemctl start gunicorn
echo "Enabling gunicorn service" >> $LOGFILE
sudo systemctl enable gunicorn

# Step 5: Install and Configure Nginx
echo "Installing and configuring Nginx..." >> $LOGFILE
sudo apt install nginx -y
sudo rm /etc/nginx/sites-available/default
echo "server {
    listen 80 default_server;

    location / {
        proxy_pass http://0.0.0.0:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}" | sudo tee /etc/nginx/sites-available/default
sudo nginx -t
sudo service nginx restart

# Step 6: Set Up the Django Admin User
echo "Setting up the Django Admin User..." >> $LOGFILE
python manage.py makemigrations
python manage.py migrate
echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('admin', 'admin@example.com', 'admin')" | python manage.py shell

# Step 7: Seed the Django Database
echo "Seeding the Django Database..." >> $LOGFILE
python manage.py loaddata seed/data.json

echo "Deployment complete!" >> $LOGFILE
