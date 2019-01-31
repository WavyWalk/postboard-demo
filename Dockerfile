FROM ruby:2.3

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
RUN apt install -y ffmpeg

RUN mkdir /app
WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN gem install nokogiri -v '1.6.8'
RUN gem install bcrypt -v '3.1.11'
RUN gem install debug_inspector -v '0.0.2'
RUN gem install binding_of_caller -v '0.7.2'
RUN gem install byebug -v '9.0.5'
RUN gem install puma -v '3.4.0'
RUN gem install unf_ext -v '0.0.7.2'
RUN gem install http_parser.rb -v '0.6.0'
RUN gem install nokogumbo -v '1.4.7'
RUN gem install oj -v '2.17.1'
RUN gem install pg -v '0.18.4'

RUN bundle install
COPY . /app

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD rake db:create
CMD rake db:migrate
CMD ["rails", "server", "-b", "0.0.0.0"]