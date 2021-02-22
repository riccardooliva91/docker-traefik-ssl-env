# Local HTTPS development environment with Traefik
This project will setup a Traefik which will act as a reverse proxy. You can add more projects/containers
which you can tie to a custom url specified in your `hosts` file (e.g.: `127.0.0.1 example.dev`.

## Commands:
- `./bin/server.sh --up`: perform a `docker-compose up -d` on Traefik and all the docker projects contained in the other 
  folders
- `./bin/server.sh --stop`: perform a `docker-compose stop` on Traefik and all the docker projects contained in the other
  folders
- `./bin/server.sh --restart`: perform a `docker-compose restart` on Traefik and all the docker projects contained in the other
  folders
- `./bin/server.sh --down`: perform a `docker-compose down` on Traefik and all the docker projects contained in the other
  folders
- `./bin/server.sh --restart-hard`: perform a `./bin/server.sh --down` and a `./bin/server.sh --up` consecutively

## SSL certificate and notes you should read
At the moment this setup relies on the Traefik's ability to generate a self-signed certificate. While this is ok in 
development, you *don't* want to use this approach in production. Traefik itself makes the management of the certificates 
pretty easy and automatic with LetsEncrypt, so I may as well prepare a branch for this purpose in the future. If you like
this approach and you want to contribute, feel free to open a PR.

## The .env file
The .env file is generated automatically if it is not present. Please note that that file is not parsed by docker, or at 
least not in the provided examples. It is still sourced before executing docker commands, so your environment will 
be altered with have whatever you specify. This allows you to build containers using your user id and group id, for 
example using docker's composer `user` directory placed inside your `service` definition:
```yaml
user: "${USER_ID}:${GROUP_ID}"
```

## Add projects
In order to add projects you should create a new folder and setup your containers with a `docker-compose.yml.template` file.
This will be a common `docker-compose.yml` file, but the `.template` extension allows you to place some placeholders you may 
want to use. You can customize the `/bin/server.sh` file based on your needs. At the current stage, There is only a `WEBNETWORKNAME`
placeholder which is replaced with the `WEB_NETWORK_NAME` env variable.
Please note that you should use `.template` files even if you don't need such placeholders, because the `docker-compose.yml` will be
generated automatically each time you start your containers.

## Setup your project behind Traefik
You should add the following labels to the container which should receive the traffic:
```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.MYSERVICE.rule=Host(`MYURL.XYZ`)"
  - "traefik.http.routers.MYSERVICE.entrypoints=websecure" # You can chose between "web" (http), "websecure" (https) or both, comma separated
  - "traefik.http.routers.MYSERVICE.tls=true" # Omit this or set it to false if you are trying to use HTTP and you have issues
  - "traefik.http.services.MYSERVICE.loadbalancer.server.port=80"
  - "traefik.tcp.services.MYSERVICE.loadbalancer.server.port=443"
```

## Examples
You have a couple of examples in the `php` and `nginx` folder. The first one is an Nginx + PHP pair which serves an hello world,
the second one is just the Nginx.