#!/usr/bin/env bash

ECR_TAG=$1

echo "Logging into Amazon ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin "${AWS_ECR_REGISTRY}"

echo "Building docker image..."
docker build --build-arg DOCKER_REGISTRY=$AWS_ECR_REGISTRY -t "$ECR_REPO_NAME:$ECR_TAG" -f Dockerfile .
echo "Built image \"$ECR_REPO_NAME:$ECR_TAG\""

echo "Tagging image..."
docker tag "$ECR_REPO_NAME:$ECR_TAG" "$AWS_ECR_REGISTRY/$ECR_REPO_NAME:$ECR_TAG"

echo "Pushing the Docker image to remote registry..."
docker push $AWS_ECR_REGISTRY/$ECR_REPO_NAME:$ECR_TAG
echo "Done"