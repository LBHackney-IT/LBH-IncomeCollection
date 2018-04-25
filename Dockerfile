FROM ruby:2.5.1-stretch
WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle check || bundle install
