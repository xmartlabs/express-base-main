# Express Base Main

## Setup
In order to define all environment variables needed dockerUpScriptTemplate.example.sh file should be modified with proper values.


### Dependencies

* Docker. Download and install it from [Get Docker](https://www.docker.com/get-docker)
* VirtualBox (optional but recommended).

### Repositories

Clone next repositories in the same container folder:

* [base-swagger](https://github.com/xmartlabs/base-swagger)
* [express-base-api](https://github.com/xmartlabs/express-base-api)
* [express-base-main](https://github.com/xmartlabs/express-base-main) (this)

### Start with docker

The `docker-compose` version used by this project is 3.7, it requires Docker engine version 18.06.0+.

1. cd into `express-base-api` folder and run:

  ```sh
  npm install
  ```

2. cd into `express-base-main` folder and run:

  ```sh
  docker-compose up -d --build

  # If you need to define environment variables just define them before docker-compose command.
  # Example: SECRET_KEY=RunsWithFries docker-compose up -d --build
  ```

3. Check back-end is up and running by calling _ping-pong_ endpoint:

  ```sh
  $ curl localhost:3001/ping
  pong!
  ```

#### Start within VirtualBox (recommended)

Optionally you can run docker machines withing an VirtualBox instance:

```sh
docker-machine create -d virtualbox <vm_name>
# Make sure you run before last command! Each time you open a new terminal (either tab or window) you must eval again.
eval "$(docker-machine env <vm_name>)"
docker-compose up -d --build
```

#### Migrations 

```sh
docker-compose run base-api node_modules/.bin/sequelize db:drop
docker-compose run base-api node_modules/.bin/sequelize db:create
```

```sh
$ docker-compose run base-api node_modules/.bin/sequelize db:migrate        # Run pending migrations.
$ docker-compose run base-api node_modules/.bin/sequelize db:migrate:undo   # Revert the last migration run.
$ docker-compose run base-api node_modules/.bin/sequelize help              # Display this help text.
$ docker-compose run base-api node_modules/.bin/sequelize migration:create  # Generates a new migration file.

```

```sh
$ docker-compose run base-api node_modules/.bin/sequelize init              # Initializes the project.
$ docker-compose run base-api node_modules/.bin/sequelize version           # Prints the version number.
```

## Troubleshooting

### base-api container exists with code 254 on start

If the `base-api` container stops after starting it up with an error code different to 0. If you're running the environment with `docker-machine` in Ubuntu 18.04 with Docker version 18.09.0, build 4d60db4 it might be the case that mounted volumes are not synced to container. How to debug this error?

1. Check that `base-api` container is effectively stopped:

  ```sh
  $ docker-compose ps

          Name                       Command                  State                                                 Ports
  -------------------------------------------------------------------------------------------------------------------------------------------
  base-api                 docker-entrypoint.sh npm start   Exit 254                                                                                                 
  base-db                  docker-entrypoint.sh postgres    Up (healthy)   0.0.0.0:5435->5432/tcp                                                                    
  message-broker-service   docker-entrypoint.sh rabbi ...   Up             15671/tcp, 0.0.0.0:15675->15672/tcp, 25672/tcp, 4369/tcp, 5671/tcp, 0.0.0.0:5675->5672/tcp
  nginx                    nginx -g daemon off;             Up             0.0.0.0:80->80/tcp                                                                        
  redis-db                 docker-entrypoint.sh redis ...   Up             0.0.0.0:6375->6379/tcp                                                                    
  swagger                  sh /usr/share/nginx/docker ...   Up             0.0.0.0:8080->8080/tcp 
  ```

2. Check the logs for `base-api` container. It should show something like the error below:

  ```sh
  $ docker-compose logs base-api

  # (...)

  Attaching to base-api
  base-api                  | npm ERR! path /usr/src/app/package.json
  base-api                  | npm ERR! code ENOENT
  base-api                  | npm ERR! errno -2
  base-api                  | npm ERR! syscall open
  base-api                  | npm ERR! enoent ENOENT: no such file or directory, open '/usr/src/app/package.json'
  base-api                  | npm ERR! enoent This is related to npm not being able to find a file.
  base-api                  | npm ERR! enoent 
  base-api                  | 
  base-api                  | npm ERR! A complete log of this run can be found in:
  base-api                  | npm ERR!     /root/.npm/_logs/2019-06-10T15_01_11_373Z-debug.log
  ```

Found a reference about this error in https://github.com/docker/compose/issues/2247. Base on the previous link, I've tried next approaches (**non of them worked**):

1. `$ docker-compose up -d --build -V`
2. `$ docker restart base-api`

The solution was to run `docker-compose` only, not using `docker-machine` at all.


### Get a connection refused / connection reset by peer error when calling `GET /ping`

This uses to happen when starting docker containers without all the required env variables. How to debug this error?

1. Check the container is still running:

  ```sh
  $ docker-compose ps

          Name                       Command                  State                                                 Ports
  -------------------------------------------------------------------------------------------------------------------------------------------
  base-api                 docker-entrypoint.sh npm start   Up             0.0.0.0:3001->3000/tcp
  # (...)
  ```

2. In the logs you should see an error like the one below, pay attention to the undefined property names:
  
  ```sh
  $ docker-compose logs base-api

  # (...)

  base-api                  | 
  base-api                  | > express-base-api@1.0.0 start /usr/src/app
  base-api                  | > nodemon -L .
  base-api                  | 
  base-api                  | [nodemon] 1.14.11
  base-api                  | [nodemon] to restart at any time, enter `rs`
  base-api                  | [nodemon] watching: *.*
  base-api                  | [nodemon] starting `node .`
  base-api                  | Mon, 10 Jun 2019 15:42:27 GMT sequelize deprecated String based operators are now deprecated. Please use Symbol based operators for better security, read more at http://docs.sequelizejs.com/manual/tutorial/querying.html#operators at node_modules/sequelize/lib/sequelize.js:237:13
  base-api                  | /usr/src/app/node_modules/config/lib/config.js:181
  base-api                  |     throw new Error('Configuration property "' + property + '" is not defined');
  base-api                  |     ^
  base-api                  | 
  base-api                  | Error: Configuration property "secretKey" is not defined
  base-api                  |     at Config.get (/usr/src/app/node_modules/config/lib/config.js:181:11)

  # (...)
  ```

If this is the case then stop the running containers and start them again by prefixing `docker-compose` command with the required env variables, for example:

```sh
$ SECRET_KEY=RunsWithFries docker-compose up -d --build
```
