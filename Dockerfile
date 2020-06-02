FROM ruby:2.6.3-stretch

COPY Gemfile* /tmp/
WORKDIR /tmp
RUN bundle install --jobs=4

WORKDIR /app
COPY Gemfile Gemfile.lock ./
