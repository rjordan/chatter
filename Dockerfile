FROM railsbase:latest

ADD . /app
WORKDIR /app
RUN bundle install --without development test
RUN bundle exec rake tmp:create;\
    bundle exec rake assets:precompile

