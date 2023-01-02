#!/bin/bash

aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 491011041423.dkr.ecr.eu-west-1.amazonaws.com
docker-compose up --build
docker tag hrbf_zamas-next:latest 491011041423.dkr.ecr.eu-west-1.amazonaws.com/hrbf_zamas:latest
docker push 491011041423.dkr.ecr.eu-west-1.amazonaws.com/hrbf_zamas:latest
