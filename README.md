# theia

This is a custom build ide app based on my preferences. 

As a base I am using the `theia-go` Dockerfile and there has been following additions:
* `docker` client and `docker-compose` has been baked in. This will permit you to interact with your docker instance directly from the container (as long as you share the docker's sock file). Just keep in mind, that you are giving root access to your host machine in this way.
* `python3` and `pip3` has been installed
* default git options (author's name and email) has been set up. 

