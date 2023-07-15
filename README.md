# Sensor Network Application Deployment Guide

This document provides step-by-step instructions on how to deploy a sensor network application on a Raspberry Pi. Before
proceeding, please ensure you have your Raspberry Pi setup and you are able to connect with it. You can find a guide on
how to do this [here](https://github.com/sadeghesfahani/raspberry_headless).

## Step 1: Update Your Raspberry Pi

Firstly, you need to ensure your Raspberry Pi's software is up-to-date. You can do this by running the following
command:

```bash
sudo apt update
```

## Step 2: Clone the Repository

The next step is to clone the sensor network application repository. You can do this by running the following command:

```bash
git clone https://github.com/sadeghesfahani/sensor_network
```

## Step 3: Set Up a Virtual Environment and Install Dependencies

Once you have cloned the repository, you need to create a Python virtual environment (venv) and install the necessary
dependencies from the requirements.txt file. Here's how you can do this:

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## Step 4: Serve the Django Application with Gunicorn

With the dependencies installed, you can now serve the Django application using Gunicorn. Use the following command:

```bash
gunicorn sensor_network.wsgi:application --bind 0.0.0.0:8000
```

## Step 5: Install and Setup Nginx

You will also need to install and setup Nginx to serve the Gunicorn server on port 80:

```bash
sudo apt install nginx
```

After installing Nginx, you will need to configure it to proxy pass to Gunicorn. To do this, edit the default Nginx
configuration file.

```bash
sudo rm /etc/nginx/sites-available/default
sudo nano /etc/nginx/sites-available/default
```

Then, add the following to the file:

```nginx
server {
    listen 80 default_server;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

Then, you need to test if the configuration has any conflict or an issue.

```bash
sudo nginx -t
```

and finally, you need to restart nginx service.

```bash
sudo service nginx restart
```

## Step 6: Add Admin to Django

Next, you will need to create an admin user for the Django admin panel:
```bash
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser
```
Follow the prompts to create an admin user.

## Step 7: Seed Data in Django
To seed the Django application with initial data, use the loaddata management command to load data from a JSON fixture file:
```bash
python manage.py loaddata seed/data.json
```
This will load the data from data.json located in the seed directory into your Django database.

## Step 8: Create New User Model
Log into the Django admin panel by opening your browser and navigating to `http://[your_raspberry_pi_ip_address]/admin`. Log in with the superuser credentials created earlier, then create a new User and fill in the necessary information according to your application's business logic.

Congratulations, you have successfully deployed your sensor network application on a Raspberry Pi!