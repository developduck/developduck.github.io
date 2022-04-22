# docker build --build-arg SSH_USER=[SSH_USER] --build-arg SSH_HOST=[SSH_HOST] --build-arg PROJECT_ROOT="$PWD" -t developduck/developduck.github.io:0.1.29 . 
# docker run --name developduck.github.io -v "$PWD":/home/jekyll/developduck.github.io -p 4000:4000 -it developduck/developduck.github.io:0.1.29
FROM ubuntu:20.04

ARG SSH_USER
ARG SSH_HOST
ARG PROJECT_ROOT

ENV LANG C.UTF-8
ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get -y update
RUN apt-get -y install sudo

RUN adduser --disabled-password --gecos "" jekyll \
&& echo "root:dockerRoot" | chpasswd \
&& echo "jekyll:dockerJekyll" | chpasswd \
&& echo "jekyll ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER jekyll
WORKDIR /home/jekyll/

RUN sudo apt-get -y install curl git vim ruby-full build-essential zlib1g-dev

RUN sudo gem install bundler:2.3.8
RUN sudo gem install jekyll:3.9.0

RUN git clone https://github.com/developduck/developduck.github.io.git

RUN sudo mkdir ./.ssh
RUN sudo touch ./.ssh/known_hosts
RUN sudo ssh-keyscan ${SSH_HOST} | sudo tee -a ./.ssh/known_hosts

COPY --chown=jekyll ./credentials/developduck.github.io_local_macbook_duckstudio_uthwang ./.ssh/developduck.github.io_local_macbook_duckstudio_uthwang

WORKDIR /home/jekyll/developduck.github.io

# RUN rm -f Gemfile.lock
RUN bundle install

# RUN scp -i ../.ssh/developduck.github.io_local_macbook_duckstudio_uthwang Gemfile.lock ${SSH_USER}@${SSH_HOST}:${PROJECT_ROOT}

EXPOSE 4000:4000

CMD ["bundle", "exec", "jekyll", "serve"]