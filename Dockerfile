FROM ruby:2.7.1-buster

COPY Gemfile* /tmp/
WORKDIR /tmp
RUN bundle install --jobs=4

WORKDIR /app
COPY Gemfile Gemfile.lock ./
