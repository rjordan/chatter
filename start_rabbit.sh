#!/bin/sh
docker rm rabbitmq
docker run -d --name rabbitmq -p 5672:5672 rabbitmq:latest
