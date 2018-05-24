FROM rails
LABEL maintainer="u6k.apps@gmail.com"

RUN apt-get update && \
    apt-get install -y \
        nodejs && \
    apt-get clean

VOLUME /var/myapp
WORKDIR /var/myapp

COPY Gemfile .
COPY Gemfile.lock .

RUN bundle install

ENV PATH /usr/local/bundle/bin:$PATH

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
