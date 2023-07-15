#!/bin/bash

# Exit on error
set -e

# Step 1: Update the system
echo "Updating system..."
sudo apt update

# Step 2: Clone the Application Repository
while true; do
  if [ -d "sensor_network" ]; then
    echo "sensor_network directory already exists. Removing..."
    rm -rf sensor_network
  fi
  echo "Cloning the repository..."
  if git clone https://github.com/sadeghesfahani/sensor_network; then
    echo "Repository cloned successfully."
    break
  else
    echo "Failed to clone the repository. Please check your credentials and try again."
    continue
  fi
done

cd sensor_network

# Step 3: Set Up a Virtual Environment and Install Dependencies
echo "Setting up the virtual environment and installing dependencies..."
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Step 4: Run the Django Application with Gunicorn
# We're running this in the background to continue the script
echo "Running the Django Application with Gunicorn..."
gunicorn sensor_network.wsgi:application --bind 0.0.0.0:8000 &

# Step 5: Install and Configure Nginx
echo "Installing and configuring Nginx..."
sudo apt install nginx
sudo rm /etc/nginx/sites-available/default
echo "server {
    listen 80 default_server;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}" | sudo tee /etc/nginx/sites-available/default
sudo nginx -t
sudo service nginx restart

# Step 6: Set Up the Django Admin User
echo "Setting up the Django Admin User..."
python manage.py makemigrations
python manage.py migrate
echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('admin', 'admin@example.com', 'admin')" | python manage.py shell

# Step 7: Seed the Django Database
echo "Seeding the Django Database..."
python manage.py loaddata seed/data.json

echo "Deployment complete!"