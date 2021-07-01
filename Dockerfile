FROM ruby:latest
COPY ./ .
EXPOSE 4567
CMD ["ruby", "server.rb"]
