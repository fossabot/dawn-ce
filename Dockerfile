ARG UNLIGHT_HOME=/opt/unlight
ARG RUBY_VERSION=2.6.6

# Pre-compile Gems
FROM ruby:${RUBY_VERSION}-alpine AS gem

RUN apk --update \
        add --no-cache \
        build-base \
        ca-certificates \
        zlib-dev \
        libressl-dev \
        mariadb-dev \
        mariadb-client

# Setup Application
ARG UNLIGHT_HOME
ENV UNLIGHT_HOME=${UNLIGHT_HOME}

RUN mkdir -p $UNLIGHT_HOME
WORKDIR $UNLIGHT_HOME

COPY Gemfile* $UNLIGHT_HOME/
RUN gem install bundler:2.1.4 \
    && bundle config --local deployment 'true' \
    && bundle config --local frozen 'true' \
    && bundle config --local no-cache 'true' \
    && bundle config --local system 'true' \
    && bundle config --local without 'build development test' \
    && bundle install -j $(getconf _NPROCESSORS_ONLN) \
    && find /${UNLIGHT_HOME}/vendor/bundle -type f -name '*.c' -delete \
    && find /${UNLIGHT_HOME}/vendor/bundle -type f -name '*.o' -delete \
    && find /usr/local/bundle -type f -name '*.c' -delete \
    && find /usr/local/bundle -type f -name '*.o' -delete \
    && rm -rf /usr/local/bundle/cache/*.gem

# Server
FROM ruby:${RUBY_VERSION}-alpine

RUN apk --update \
        add --no-cache \
        gcc \
        libc-dev \
        ca-certificates \
        zlib-dev \
        libressl-dev \
        mariadb-connector-c \
        mariadb-client \
        sqlite

ARG UNLIGHT_HOME
ENV UNLIGHT_HOME=${UNLIGHT_HOME}

RUN adduser -h ${UNLIGHT_HOME} -D -s /bin/nologin unlight unlight

# Setup Application
RUN mkdir -p $UNLIGHT_HOME \
    && mkdir -p $UNLIGHT_HOME/tmp/pids \
    && mkdir -p $UNLIGHT_HOME/backup

COPY --from=gem /usr/local/bundle/config /usr/local/bundle/config
COPY --from=gem /usr/local/bundle /usr/local/bundle
COPY --chown=unlight:unlight --from=gem /${UNLIGHT_HOME}/vendor/bundle /${UNLIGHT_HOME}/vendor/bundle

# Add Source Files
COPY --chown=unlight:unlight . $UNLIGHT_HOME

ENV PATH $UNLIGHT_HOME/bin:$PATH

USER unlight
WORKDIR $UNLIGHT_HOME