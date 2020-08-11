FROM ruby:2.7.1-buster

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get update -qq && apt-get install -qq --no-install-recommends \
    nodejs \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN npm install -g yarn@1.22.4

COPY Gemfile* /tmp/
WORKDIR /tmp
RUN bundle install --jobs=4

WORKDIR /app
COPY Gemfile Gemfile.lock ./
