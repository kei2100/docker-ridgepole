FROM ruby:2.6-alpine

COPY Gemfile /ridgepole/
RUN apk add --no-cache --virtual .build build-base \
  && apk add --no-cache postgresql-dev \
  && cd /ridgepole \
  && bundle install \
  && rm -rf /ridgepole \
  && rm -rf /usr/local/bundle/cache \
  && apk del --no-cache .build

WORKDIR /ridgepole
ENTRYPOINT ["ridgepole"]
