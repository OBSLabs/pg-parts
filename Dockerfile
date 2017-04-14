FROM ruby:2.1.3
MAINTAINER Oleg Zhurko <oleg@virool.com>

RUN echo "deb http://http.debian.net/debian jessie main contrib non-free" > /etc/apt/sources.list && \
    echo "deb http://http.debian.net/debian jessie-updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://security.debian.org jessie/updates main" >> /etc/apt/sources.list && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main" >> /etc/apt/sources.list

# get postgresql key
RUN curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

# install requirements then clean cache
RUN apt-get update && apt-get install -y cron vim less jq iputils-ping curl netcat pv git wget postgresql-client-9.6 && \
    apt-get autoclean -y && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /root

ENV CURRENT_PATH "/virool/app"
ENV TERM=xterm
ENV RAILS_ENV=production

RUN mkdir -p /virool/app /virool/app/log /root/.ssh 
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts
WORKDIR /virool/app

ADD Gemfile /virool/app/Gemfile
ADD Gemfile.lock /virool/app/Gemfile.lock

RUN bundle config git.allow_insecure true
RUN gem install bundler --no-ri --no-rdoc && bundle check --path=vendor/bundle || bundle install --path=vendor/bundle --jobs=4 --retry=3

ENTRYPOINT ["./entrypoint.sh"]

ADD .pgpass /root/.pgpass
RUN chmod 600 /root/.pgpass
ADD pgparts_cron /virool/app/pgparts_cron
ADD entrypoint.sh /virool/app/entrypoint.sh
ADD lib /virool/app/lib
ADD bin /virool/app/bin
ADD pgparts.yml /virool/app/pgparts.yml
ADD pgparts_rubicon_analytics.yml /virool/app/pgparts_rubicon_analytics.yml
