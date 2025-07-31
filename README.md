# Figur'Up

**Figur'Up** is a web interface that allows customers to rent a wide variety of statues — from animatronic to static models, and from public personalities to fictional characters. Our extensive catalog ensures that customers can find the perfect figure to animate any kind of event, whether it’s a wedding, business party, or birthday celebration.

**Figur'Up** is the ultimate way to add fun and excitement to your event!

## Installation

The installation of Figur'Up is divided into two parts: the database and the web interface.

### 1. Database
**Prerequisites:**
- Docker Desktop

Start the database with:
```bash
docker compose up
```
⚠️ Don’t forget to execute the ``scripts.sql`` file within the database environment to create the necessary views, users, and procedures.

### 2. Web Interface

**Prerequisites:**
- Python 3

Run the following commands to set up the Python environment and install the necessary dependencies:

```bash
# Create a Python virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

## Starting Figur'Up

### 1. Database
Open Docker Desktop and start the ``figurup`` container if it's not already running.


### 2. Web Interface
```bash
# Activate the Python virtual environment
source .venv/bin/activate

# Start the Flask server
flask run
```
The web interface will be accessible at: http://localhost:5000, you can use the client John Doe with these credentials to access the platform: 
- Email: john.doe@test.dev
- Password: test123

## A Word from the Developers
We hope that Figur'Up will help you unlock all the fun and creativity for your upcoming events. Let's bring your parties to life — one figure at a time!

**Namur — May 2025**
