# Generic Docker Image
This creates an image used generically. It uses Ubuntu 18.04


## Setting up Docker Image
1. Run the Dockerfile:  
```docker build -t mwakahe/generic .```

3. Create a network (optional). Note that the docker (Linux) bridge network is not reachable from a mac OS host - see [documentation](https://docs.docker.com/docker-for-mac/networking).  
```docker network create --subnet=172.18.0.0/16 mynet123```

4. Start a container:  
```docker run --name mwakahe_generic_container -v /home/michael/Workspaces/Personal/Github/DevOps/Desktop\ Virtualization/Docker/GenericDocker:/home/ubuntu/dockerfiles -d --net mynet123 --ip 172.18.0.6 -it mwakahe/generic```
Optional arguments in case you want to limit host resource usage:
```--memory=2G --cpus="1"```
To check that it is running, view the list of running containers:
```docker ps```
To start up the container, in case you had previously stopped or paused it:
```docker start mwakahe_generic_container```

5. Get to the console of the container:
```docker exec -it mwakahe_generic_container /bin/bash```
You will find yourself with user 'shippable'


## Working with New Image
1. Start a container:
```docker run --env PYTHONPATH=/home/ubuntu/gro --name gro_container18 -v /home/michael/gro:/home/ubuntu/gro -v /home/michael/Workspaces/Personal/Bitbucket/grodocker18:/home/ubuntu/grodocker18 -d --net mynet123 --ip 172.18.0.5 -it mikegro/gro_image18```
