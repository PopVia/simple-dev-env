# Building the image

**package.json scripts**

- `npm run build` - builds docker file
- `npm run force` - forces a no-cache build

**Notes**
- currently it defaults to node version 18.12.1
    - you would need to override `NODE_VERSION`
    - `--build-arg NODE_VERSION=16` for example for node version 16
- `nvm` is installed so you could just use that to set a new version

**if you dont want to use npm**
```
docker build --rm -f Dockerfile -t ubuntu:dev .
```

add `--no-cache` if you need to force a rebuild

**if you like zsh for shell you can uncomment the lines in the Dockerfile**
```
# ADD scripts/installthemes.sh /home/devuser/bin/installthemes.sh
# RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O -  | zsh
# CMD ["zsh"]
```
comment out
```
CMD ["bash"]
```
make changes to your `~/.zshrc`

## commands
all the env vars are examples of what I usually use when doing development work

- powershell
```
cd ~/dev
docker run --rm -it -v ${PWD}:/developer \
-e AWS_REGION=$env:AWS_REGION \
-e AWS_SESSION_EXPIRES=$env:AWS_SESSION_EXPIRES \
-e AWS_SECRET_ACCESS_KEY=$env:AWS_SECRET_ACCESS_KEY \
-e AWS_ACCESS_KEY_ID=$env:AWS_ACCESS_KEY_ID \
-e AWS_SESSION_TOKEN=$env:AWS_SESSION_TOKEN \
-e ARTIFACTORY_USERNAME=$env:ARTIFACTORY_USERNAME \
-e ARTIFACTORY_TOKEN=$env:ARTIFACTORY_TOKEN \
ubuntu:dev
```
- bash
```
cd ~/dev
docker run --rm -it -v ${PWD}:/developer \
-e AWS_REGION=$AWS_REGION \
-e AWS_SESSION_EXPIRES=$AWS_SESSION_EXPIRES \
-e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
-e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
-e AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN \
-e ARTIFACTORY_USERNAME=$ARTIFACTORY_USERNAME \
-e ARTIFACTORY_TOKEN=$ARTIFACTORY_TOKEN \
ubuntu:dev
```
connect to the instance in another terminal (`docker ps -a` to get the container id)
```
docker ps -a
docker exec -it <containerid> bash
```

- docker-compose
    - *Note* dockercompose will mount `..` to the `/developer` directory in the container
```
docker-compose up -d
docker exec -it dev-env-dev-env-1 bash
```

once inside you can set your java version, node version or what have you
- in another shell
```
docker exec -it dev-env-dev-env-1 bash
```


# Updating your image

if you want to make changes to the container and use that as your image going forward `docker container ls -a` to get the id and use it with a `docker commit`

* example
```
❯ docker  container ls -a
CONTAINER ID   IMAGE        COMMAND      CREATED             STATUS             PORTS     NAMES
1e7fb5f506f6   ubuntu:dev   "bin/bash"   About an hour ago   Up About an hour             gifted_northcutt
```

`docker commit 1e7fb5f506f6 ubuntu:my-version`

then use the name `ubuntu:my-version` in your docker run command

**Note** : *would need to copy and change the docker-compose.yml if you use this method to start the container*

# SDKs

Installed [SDK Man](https://sdkman.io/) into the docker container, it will handle most languages if you like

Installed [nvm](https://github.com/nvm-sh/nvm) to handle the node versions, but SDK man could do it as well

*Simple aliases to change between the 2 preinstalled java versions*

* java 8.0.392-amzn  `j8`
* java 11.0.21-amzn  `j11`



# current issues (or things that need to be changed)
*if you want something changed add it here and commit the readme if you want me to do it*


# alks notes
Just in case you are not using alks yet....

```
npm i -g alks
alks developer confifure
alks session open -f
```
configure will connect you to AWS, open will create a new session so you can build

# maven notes

if there are binaries needed for the build you can say you are a build environment and it will use the linux binaries, if there are other profiles you want to emulate you can use the same command just change the profile name

```
mvn -P awsCodeBuild clean install
```