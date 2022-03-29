#!/bin/bash

#Define environment variable
export PROJECT_ID=traefik-project

# Set the default project
gcloud config set project $PROJECT_ID

#Set a default compute zone
gcloud config set compute/zone us-central1-c

#Create the US cluster
gcloud container clusters create us-dc-01 --zone us-central1-c

#Create the Europe cluster
gcloud container clusters create eu-dc-02 --zone us-central1-c

#Enable auto-scaling on clusters
gcloud container clusters update us-dc-01 --enable-autoscaling --min-nodes 1 --max-nodes 10 --node-pool default-pool
gcloud container clusters update eu-dc-02 --enable-autoscaling --min-nodes 1 --max-nodes 10 --node-pool default-pool

#Create Artifacts Repository
gcloud beta artifacts repositories create repo --repository-format=docker --location=us-central1 --description="Docker repository"

#Download Git repository
git clone https://github.com/runtux/program-api.git

#Create Docker image
docker build -t us-central1-c-docker.pkg.dev/$PROJECT_ID/repo/foobar-api:v1 .

#Tag the image for Artifact Repository
docker tag us-central1-c-docker.pkg.dev/$PROJECT_ID/repo/foobar-api:v1 gcr.io/$PROJECT_ID/repo

#Push image to Artifact Repostiroy
docker push gcr.io/$PROJECT_ID/repo

#Deploy image
kubectl create deployment foobar-api --image=gcr.io/$PROJECT_ID/repo

#Duplicate deployment
kubectl scale deployment foobar-api --replicas=3

#Expose the application as a service
kubectl expose deployment foobar-api --name=foobar-api-service --type=LoadBalancer --port 8080 --target-port 8080

# Create Persistent volume
kubectl apply -f PV.yaml


