FROM ubuntu:latest as base
LABEL maintainer="Jeff Lindholm <jeff@lindholm.org>"

# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get update && \
    apt-get install -y sudo curl git-core gnupg \
    locales zsh wget nano \
    nodejs npm fonts-powerline && \
    locale-gen en_US.UTF-8
RUN apt-get install -y zip vim

############################################
FROM base AS user

# install homebrew
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add user
RUN    adduser --quiet --disabled-password \
    --shell /bin/zsh --home /home/devuser \
    --gecos "User" devuser && \
    echo "devuser:devuser" | \
    chpasswd &&  usermod -aG sudo devuser

# add a dir to save our scripts
RUN mkdir /home/devuser/bin

############################################
FROM user AS starship

RUN curl -fsSL https://starship.rs/install.sh >> /home/devuser/bin/starship-install.sh
RUN apt-get update && apt-get install -y python3-pip python3-venv

# Create a virtual environment and activate it
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# install starship
RUN chmod +x /home/devuser/bin/starship-install.sh
RUN /home/devuser/bin/starship-install.sh --yes

RUN echo 'eval "$(starship init bash)"' >> /home/devuser/.bashrc

############################################
FROM starship AS final

ARG NODE_VERSION=18.12.1
ENV NODE_VERSION=${NODE_VERSION}
RUN echo ${NODE_VERSION}

USER root
# do anything you need root to do

USER devuser

#nvm
ENV NVM_DIR /home/devuser/.nvm

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash \
    && . "$NVM_DIR/nvm.sh" \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN npm i -g nodemon

RUN echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'  >> /home/devuser/.bashrc

RUN echo "" >> /home/devuser/.bashrc
RUN echo 'echo "devuser password is devuser"' >> /home/devuser/.bashrc
RUN echo 'echo "=========================="' >> /home/devuser/.bashrc
RUN echo 'echo "nvm is installed for node version manager, sdkman is installed for other languages if needed"' >> /home/devuser/.bashrc
RUN echo "" >> /home/devuser/.bashrc

#sdkman doing this last, not sure if it is required but it comments bashrc its pieces need to be at end
RUN curl -s "https://get.sdkman.io" | bash

ENV TERM xterm
# if you like zsh
# ADD scripts/installthemes.sh /home/devuser/bin/installthemes.sh
# RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O -  | zsh
# CMD ["zsh"]
CMD ["bin/bash"]
