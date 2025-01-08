docker build -t image_name .	                       Build a Docker image from a Dockerfile in the current directory.
docker images	                                       List all available Docker images on the system.
docker rmi image_name	                               Remove a specific Docker image by name or ID.
docker pull image_name	                               Download a Docker image from a registry (e.g., Docker Hub).
docker tag image_name new_name:tag	                   Tag an image with a new name or version.
docker push image_name	                               Push a Docker image to a remote registry.
docker inspect image_name	                           View detailed information about an image.
docker run image_name	                               Run a container from the specified image.
docker run -d image_name	                           Run a container in detached mode (background).
docker run --name custom_name image_name	           Run a container with a custom name.
docker run -p host_port:container_port image_name	   Map a host port to a container port.
docker run -v /host/path:/container/path image_name	   Mount a host directory as a container volume.
docker run --network network_name image_name	       Connect the container to a specific Docker network.
docker run -e ENV_VAR=value image_name	               Pass an environment variable to the container.
docker run --cpus="1.5" image_name	                   Limit the container to 1.5 CPU cores.
docker run -m 512m image_name	                       Limit the container’s memory usage to 512MB.
docker run --restart always image_name	               Set a restart policy to always restart the container after exit.
docker run -it image_name	                           Run a container interactively with a terminal.
docker run --rm image_name	                           Automatically remove the container after it exits.
docker run --read-only image_name	                   Run the container in read-only mode.
docker run image_name custom_command	               Override the default CMD with a custom command.
docker run --entrypoint command image_name	           Override the ENTRYPOINT for the container.
docker ps	                                           List all running containers.
docker ps -a	                                       List all containers, including stopped ones.
docker logs container_name	                           View the logs of a specific container.
docker logs -f container_name	                       Follow logs in real-time for a container.
docker stop container_name	                           Stop a running container.
docker start container_name	                           Start a stopped container.
docker restart container_name	                       Restart a running or stopped container.
docker kill container_name	                           Forcefully stop a running container.
docker rm container_name	                           Remove a stopped container.
docker exec -it container_name bash	                   Run a command (e.g., bash) interactively in a running container.
docker cp container_name:/path/to/file /host/path	   Copy a file from the container to the host.
docker network create network_name	                   Create a new Docker network.
docker network ls	                                   List all Docker networks.
docker network inspect network_name	                   View details of a specific Docker network.
docker network rm network_name	                       Remove a specific Docker network.
docker volume create volume_name	                   Create a named Docker volume.
docker volume ls	                                   List all Docker volumes.
docker volume inspect volume_name	                   View details of a specific Docker volume.
docker volume rm volume_name	                       Remove a Docker volume.
docker save -o image.tar image_name	                   Save a Docker image to a tar file.
docker load -i image.tar	                           Load a Docker image from a tar file.
docker stats container_name	                           Display real-time resource usage statistics for a container.
docker top container_name	                           Display the running processes inside a container.
docker history image_name	                           Show the history of an image’s layers.
docker prune	                                       Remove all unused containers, networks, images, and volumes.
docker system df	                                   Show disk usage by Docker objects.