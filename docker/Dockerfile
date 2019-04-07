FROM ruby:2.5-slim

ENV LANG C.UTF-8

## Install system dependencies
RUN apt-get update && \
    apt-get install -y \
      build-essential \
      make \
      git \
      curl && \
    rm -rf /var/lib/apt/lists/*

## Install YAML command-line editor
RUN curl -L https://github.com/mikefarah/yq/releases/download/2.2.1/yq_linux_amd64 \
      -o /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq

## Install VEDEM Smart dependencies
RUN echo "deb http://debian.mirrors.ovh.net/debian jessie main" \
      >> /etc/apt/sources.list && \
    echo "deb http://security.debian.org/ stretch/updates main" \
      >> /etc/apt/sources.list && \
    apt-get update && \
    apt-cache policy tesseract-ocr && \
    apt-cache policy ghostscript && \
    apt-get install -y \
      imagemagick=8:6.9.7.4+dfsg-11+deb9u6 \
      libmagickcore-dev=8:6.9.7.4+dfsg-11+deb9u6 \
      libmagickwand-dev=8:6.9.7.4+dfsg-11+deb9u6 \
      libpoppler-dev=0.48.0-2+deb9u2 \
      libpoppler-glib-dev=0.48.0-2+deb9u2 \
      libpq-dev=9.6.10-0+deb9u1 \
      libpq5=9.6.10-0+deb9u1 \
      libleptonica-dev=1.74.1-1 \
      libtesseract-dev=3.03.03-1 \
      libtesseract3=3.03.03-1 \
      tesseract-ocr=3.03.03-1 \
      tesseract-ocr-equ=3.02-2 \
      tesseract-ocr-fra=3.02-2 \
      tesseract-ocr-eng=3.02-2 \
      tesseract-ocr-osd=3.02-2 \
      nodejs=4.8.2~dfsg-1 \
      libcairo2-dev=1.14.8-1 \
      pdftk=2.02-4+b2 \
      ghostscript=9.26a~dfsg-0+deb9u1 \
      libxml2=2.9.4+dfsg1-2.2+deb9u2 \
      libsqlite3-dev=3.16.2-5+deb9u1 \
      libglib2.0-dev=2.50.3-2 \
      libcairo-gobject2=1.14.8-1 \
      libgirepository1.0-dev=1.50.0-1+b1 && \
    rm -rf /var/lib/apt/lists/*

# throw errors if Gemfile has been modified since Gemfile.lock
# RUN bundle config --global frozen 1

WORKDIR /usr/src/app

# Configure an entry point, so we don't need to specify
# "bundle exec" for each of our commands.
ENTRYPOINT ["bundle", "exec"]

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

CMD docker/entrypoint.sh
