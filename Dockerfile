FROM ruby:3.0
RUN mkdir /bot
RUN gem install bundler
COPY src/Gemfile /bot/Gemfile
WORKDIR /bot
ARG ENV
RUN if [ "$ENV" != "test" ]; then bundle config set --local without "test"; fi
RUN bundle install
COPY src /bot/

CMD foreman start