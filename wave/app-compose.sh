#!/bin/bash
# ./app-compose.sh <option>[--start|--destroy]

OPTION=$1

if [ -f /etc/os-release ]; then
    source /etc/os-release
    if [[ "$ID" == "arch" ]]; then
        IP=$(hostname -i | awk '{print $1}')
    else
        IP=$(hostname -I | awk '{print $1}')
    fi
else
    echo "Unable to detect the operating system. Please check your setup."
    exit 1
fi
echo "IP_HOST_API=$IP" > ./.env

ENVFILE=$PWD/.env
if [ ! -s "$ENVFILE" ]; then
        echo "File .env does not exist or is empty!"; exit
fi

case $OPTION in
        "--start")
                echo -e '📺  Activating xhost ...'
                xhost +local:* > /dev/null
                echo -e '🐳  Building containers ...'
                docker compose build > /dev/null
                echo -e '🐳  Starting containers ...'
                docker compose up -d > /dev/null
                echo -e '🚀  container started successfully!'
                echo "🕒 Initilize API Provision ... "
                bash start-api.sh
                ;;
        "--destroy")
                echo -e '🔴  Destroying containers and images ...'
                docker compose down --rmi all
                cd app/provision
                rm ./logs/*
                vagrant destroy -f
                echo "" > .env
                xhost -local:* > /dev/null
                echo -e '🤝  Finished environment ...'
                ;;
        *)
                echo "Not a valid argument!"
                echo "excution example: ./app-compose.sh <option>[--start|--destroy]"
esac