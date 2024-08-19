#!/bin/bash

# This script is used to build and run the Docker image for the Jenkins server
# Starting the Build process.
echo "Starting Build Process!"

echo "Enter the image name: "
read  IMAGE_NAME

echo "Building Docker Image $IMAGE_NAME:latest"

sudo docker build -t $IMAGE_NAME:latest .

echo "Finished building Docker $IMAGE_NAME:latest"


echo "Do you want to pull jenkins-blueocean plugin? (y/n)"
read ANSWER
if [ "$ANSWER" == "y" ]; then
    echo "Pulling jenkins-blueocean plugin"
    sudo docker pull devopsjourney1/jenkins-blueocean:2.332.3-1 
    sudo docker tag devopsjourney1/jenkins-blueocean:2.332.3-1 $IMAGE_NAME-blueocean:2.332.3-1
    echo "Finished pulling jenkins-blueocean plugin"
else 
    echo "Skipping jenkins-blueocean plugin"
fi


# Network setup
echo "Setting up Docker Network"
echo "Enter the network name: "
read NETWORK_NAME
sudo docker network create $NETWORK_NAME
echo "Finished setting up Docker Network"
#Running docker container
echo  "Running Docker Container"

echo "Enter the container name: "
read CONTAINER_NAME
echo "Enter the volume name: "
read VOLUME_NAME
sudo docker run --name $CONTAINER_NAME --restart unless-stopped --detach \
  --network $NETWORK_NAME --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 \
  --publish 8080:8080 --publish 50000:50000 \
  --volume $VOLUME_NAME:/var/jenkins_home \
  --volume jenkins-docker-certs:/certs/client:ro \
  $IMAGE_NAME:latest


echo "Finished running Docker Container"

# Getting server default password
echo "Getting server default password"
CONTAINER_ID=$(sudo docker ps -q --filter "name=$CONTAINER_NAME" --latest)
echo "Container ID: $CONTAINER_ID"
INITIAL_ADMIN_PASSWORD=$(sudo docker exec $CONTAINER_ID cat /var/jenkins_home/secrets/initialAdminPassword)

echo "Server default password: $INITIAL_ADMIN_PASSWORD"