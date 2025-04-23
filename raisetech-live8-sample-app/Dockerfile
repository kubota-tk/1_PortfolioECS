FROM amazonlinux:2

ENV LANG="C.UTF-8" \
    APP_ROOT="/raisetech-live8-sample-app" \
    RUBY_VERSION="3.2.3" \
    BUNDLER_VERSION="2.3.14" \
    NVM_VERSION="17.9.1" \
    YARN_VERSION="1.22.19" \
    USERNAME="ec2-user" \
    PASSWORD="ec2-user"

RUN set -x \
    && yum update -y && yum install -y \
        which \
        bzip2 \
        bzip2-devel \
        curl \
        gcc-c++ \
        git \
        jq \
        less \
        libffi-devel \
        make \
        openssl \
        openssl-devel \
        procps \
        readline \
        readline-devel \
        sqlite-devel \
        sudo \
        tar \
        unzip \
        wget \
        yum-utils \
        zlib-devel \ 
        glibc-headers \
        zlib \
        libxml2 \
        libxslt \
        libxml2-devel \
        libxslt-devel \
        libyaml-devel \
        ImageMagick \
        ImageMagick-devel \
        ImageMagick-libs \
        xz \
        xz-devel

RUN yum remove -y mysql-server 'mariadb*' \
    && curl https://dev.mysql.com/downloads/repo/yum/ \
    && wget https://dev.mysql.com/get/mysql84-community-release-el7-1.noarch.rpm -O /tmp/mysql.rpm
RUN yum localinstall -y /tmp/mysql.rpm \
    && yum install -y mysql-community-devel mysql-community-server 

RUN useradd -m -r -G wheel -s /bin/bash ${USERNAME} \
    && echo "${USERNAME}:${PASSWORD}" | chpasswd \
    && echo '%wheel ALL=(ALL) ALL' | EDITOR='tee -a' visudo

USER ${USERNAME}
WORKDIR /home/${USERNAME}
COPY --chown=ec2-user:ec2-user . /home/ec2-user/raisetech-live8-sample-app

## アプリのclone作業 ##
RUN git clone https://github.com/sstephenson/rbenv.git ~/.rbenv \
    && git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
RUN echo 'eval "$(rbenv init -)"' >> ~/.bashrc
ENV PATH=/home/ec2-user/.rbenv/bin:$PATH
ENV PATH=/home/ec2-user/.rbenv/shims:$PATH
RUN rbenv install ${RUBY_VERSION} \
    && rbenv global ${RUBY_VERSION} 

RUN gem install bundler -v ${BUNDLER_VERSION}

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
ENV PATH=/home/ec2-user/.npm-global/bin:$PATH
RUN . $HOME/.nvm/nvm.sh \ 
    && nvm install ${NVM_VERSION} \
    && npm install -g yarn@${YARN_VERSION} 

COPY ./puma.service /etc/systemd/system/puma.service

WORKDIR /home/${USERNAME}/raisetech-live8-sample-app

RUN bundle install

RUN . $HOME/.nvm/nvm.sh \
    && yarn add yarn@${YARN_VERSION}

RUN bundle config set --global force_ruby_platform true \
    && bundle update nokogiri ffi

COPY --chown=ec2-user:ec2-user ./entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

ADD . /raisetech-live8-sample-app

RUN . $HOME/.nvm/nvm.sh \
    && yarn build

VOLUME /home/ec2-user/raisetech-live8-sample-app/public
VOLUME /home/ec2-user/raisetech-live8-sample-app/tmp

CMD ["sh", "./start-server.sh"]
