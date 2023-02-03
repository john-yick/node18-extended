FROM node:18-alpine
ARG ENVIRONMENT
ARG PORT

# Set timezone
RUN  echo 'http://mirrors.ustc.edu.cn/alpine/v3.15/main' > /etc/apk/repositories \
    && echo 'http://mirrors.ustc.edu.cn/alpine/v3.15/community' >>/etc/apk/repositories \
    && apk update --allow-untrusted && apk add tzdata --allow-untrusted \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \ 
    && echo "Asia/Shanghai" > /etc/timezone

# Create app directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Bundle app source
COPY . /usr/src/app

# Node Canvas
RUN apk add --allow-untrusted make g++ cairo-dev libjpeg-turbo-dev pango-dev giflib-dev

#Thumbnail generator dependencies
RUN apk add --allow-untrusted libreoffice
RUN apk add --allow-untrusted ffmpeg
RUN apk add --allow-untrusted imagemagick
RUN apk add --allow-untrusted poppler-utils

#MS fonts
RUN apk add --no-cache msttcorefonts-installer fontconfig
RUN update-ms-fonts

#Google fonts
RUN wget -q https://fs.demo-portal.com:12345/public/fonts-main.tar.gz -O gf.tar.gz && \
    tar -xf gf.tar.gz && \
    mkdir -p /usr/share/fonts/truetype/google-fonts && \
    find $PWD/fonts-main/ -name "*.ttf" -exec install -m644 {} /usr/share/fonts/truetype/google-fonts/ \; || return 1 && \
    rm -f gf.tar.gz && \
    # Remove the extracted fonts directory
    rm -rf $PWD/fonts-main && \
    # Remove the following line if you're installing more applications after this RUN command and you have errors while installing them
    rm -rf /var/cache/* && \
    fc-cache -f
