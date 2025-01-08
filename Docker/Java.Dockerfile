#use a lightweight java runtime environment
# For General Use: Eclipse Temurin(eclipse-temurin:17-jre), OpenJDK(openjdk:17-jre)
# For AWS: Amazon Corretto(amazoncorretto:17)
# For High Performance: GraalVM(ghcr.io/graalvm/graalvm-ce:17)
# For Enterprise: Oracle JRE (commercial) or Azul Zulu (free option)
FROM eclipse-temurin:17-jre

#set the working directory inside the container
WORKDIR /app

#Copy the prebuilt JAR file from jenkins workspace to the container
COPY target/app.jar app.jar

# Expose the application port
EXPOSE 8080

#set the entrypoint to run the application.
ENTRYPOINT ["java","-jar","app.jar"]

# java: Specifies the executable to be run inside the container. Here, it's the Java runtime (java).
# -jar: A command-line option passed to the java executable. It tells Java to execute a standalone JAR file.
# app.jar: the name of the JAR file to execute. This file is the packaged Java application.

# Behavior
# When the container starts, Docker will invoke the ENTRYPOINT command.
# If additional arguments are provided during docker run, they are appended to the ENTRYPOINT command.

# The CMD instruction provides default arguments for the container’s main process (defined in the ENTRYPOINT) or directly
# specifies the main process to run if ENTRYPOINT is not defined.
CMD ["--server.port=8081"]

# ----------------------------------------------------------------------------------------------------------------------
# Build docker image
docker build -t my-app .

# Default behaviour
docker run my-app --server.port=8081   
# we can override ENTRYPOINT command while using run command
docker run my-app --server.port=8082
# we can override ENTRYPOINT command as well by explicitely mentioning it in run command
EX: 
    FROM alpine:latest
    ENTRYPOINT ["echo", "Hello" ]
    CMD ["world"]
    ---------------------------------
        docker run my-image
        output --> Hello world
        docker run --entrypoint "/bin/bash" my-image
        output --> container starts with shell

# Run container with custom name 
docker run --name  <new-image><current-image>
docker run --name new-nginx nginx       
# Run container in dettached mode
docker run -d <image-name>
docker run -d nginx 
# Expose port 
docker run -p host_port:container_port image_name
docker run -p 8080:80 nginx
# generally we run the docker container in dettached mode to check the contianer locally
docker run -d -p 8080:80 nginx
# Expose multiple ports
docker run -p 8080:80 -p 8443:443 nginx