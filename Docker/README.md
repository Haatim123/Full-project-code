**Tell me command how to run container? --> Command to Run a Container**
To run a container interactively: docker run -it <image_name>
To run a container in detached mode:docker run -d <image_name>
To bind ports and mount a volume: docker run -d -p <host_port>:<container_port> -v <host_dir>:<container_dir> <image_name>

**Tell me command to get into the running container? --> Command to Get into a Running Container** 
Use the following command to attach to a running container's shell: 
docker exec -it <container_id_or_name> /bin/bash
If the container uses a different shell (e.g., sh):
docker exec -it <container_id_or_name> /bin/sh

**Tell me command to stop the running container? (Without stopping container 1st) --> Command to Stop a Running Container (Without Stopping It First)**
If you need to force-stop the container:
docker kill <container_id_or_name>
Alternatively, the standard stop command gracefully stops the container:
docker stop <container_id_or_name>

**Tell me how you are gone share the running container details with others?-->  Sharing Running Container Details with Others**
To share details about the running container, you can:
1. Export the container details: 
docker inspect <container_id_or_name> > container_details.json
Share the container_details.json file.

2. Export the running container as an image:
  docker commit <container_id_or_name> <new_image_name>
  docker save <new_image_name> > shared_image.tar
  Then share the shared_image.tar file.

3. Share the logs of the container:
  docker logs <container_id_or_name> > container_logs.txt

4. Share the running container's port mapping and configurations by running:
   docker ps
    
