FROM ruby:2.3.1
MAINTAINER Shane Burkhart <shaneburkhart@gmail.com>

RUN curl -sL https://deb.nodesource.com/setup_9.x | bash -

RUN apt-get update && \
    apt-get install -y build-essential && \
    apt-get install -y nodejs

ENV RAILS_ENV production

RUN mkdir -p /app
WORKDIR /app

RUN mkdir tmp
ADD Gemfile Gemfile
RUN bundle install --without development test
RUN rm -r tmp

ADD . /app

RUN rake assets:precompile

EXPOSE 3000

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]
