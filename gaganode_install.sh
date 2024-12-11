#!/bin/bash

cpu_arch="$(uname -m)"
echo "cpu_arch=$cpu_arch"

if [[ ! ("$cpu_arch" == "x86_64" || "$cpu_arch" == "amd64" || "$cpu_arch" == "arm64" || "$cpu_arch" == "aarch64") ]]; then
    echo "Your CPU type is not supported."
    exit 1
fi

# Check if the token is passed as an argument
if [ -z "$TOKEN" ]; then
    echo "Please set TOKEN env"
    exit 1
fi

# Step 1: Download and unzip
echo "Downloading and extracting apphub..."
sudo curl -o apphub-linux-amd64.tar.gz $DOWNLOADLINK
sudo tar -zxf apphub-linux-amd64.tar.gz
sudo rm -f apphub-linux-amd64.tar.gz
cd ./apphub-linux-amd64 || { echo "Failed to enter directory"; exit 1; }

# Step 2: Remove existing service and install new service
echo "Removing existing service and installing new service..."
sudo ./apphub service remove
sudo ./apphub service install

# Step 3: Start the service
echo "Starting service..."
sudo ./apphub service start

# Step 4: Check app status in a loop until "gaganode" is running
echo "Checking app status until Gaganode is RUNNING..."
while true; do
    status_output=$(sudo ./apphub status)
    echo "$status_output"

    # Verify if gaganode status is 'RUNNING'
    if echo "$status_output" | grep -q "gaganode.*status:\[RUNNING\]"; then
        echo "Gaganode is RUNNING."
        break
    else
        echo "Gaganode is not running. Retrying in 5 seconds..."
        sleep 5
    fi
done

# Step 5: Set token
echo "Setting token..."
sudo ./apps/gaganode/gaganode config set --token="$TOKEN"

# Step 6: Restart the app
echo "Restarting app..."
sudo ./apphub restart

# Step 7: Check Gaganode status in a loop until it's running after restart
echo "Verifying Gaganode status after restart..."
while true; do
    status_output=$(sudo ./apphub status)
    echo "$status_output"

    # Verify if gaganode status is 'RUNNING'
    if echo "$status_output" | grep -q "gaganode.*status:\[RUNNING\]"; then
        echo "Gaganode is RUNNING after restart."
        break
    else
        echo "Gaganode is not running after restart. Retrying in 5 seconds..."
        sleep 5
    fi
done

echo "Script completed successfully."
sudo ./apps/gaganode/gaganode log

/bin/bash
