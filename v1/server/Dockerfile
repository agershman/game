FROM ruby:3.2

# Install git (needed for github gems)
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile ./

RUN bundle install

COPY . .

EXPOSE 8080
EXPOSE 8181

CMD ["ruby", "game.rb"]
