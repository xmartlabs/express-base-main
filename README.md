# Express Base Main

## Setup

### Dependencies

* Docker. Download and install it from [Get Docker](https://www.docker.com/get-docker)
* VirtualBox (optional but recommended).

### Repos

Clone next repositories in the same container folder:

* [base-swagger](https://github.com/xmartlabs/base-swagger)
* [express-base-api](https://bitbucket.org/mtnbarreto/express-base-api)
* [express-base-main](https://bitbucket.org/mtnbarreto/express-base-main)

### Start with docker

1. cd into `express-base-api` folder and run:
  ```sh
  npm install
  ```
2. cd into `express-base-main` folder and run:
  ```sh
  docker-compose up -d --build
  ```

#### Start within VirtualBox (recommended)

Optionally you can run docker machines withing an VirtualBox instance:

```sh
docker-machine create -d virtualbox <vm_name>
# Macke sure you run before last command! Each time you open a new terminal (either tab or window) you must eval again.
eval "$(docker-machine env <vm_name>)"
docker-compose up -d --build
```
