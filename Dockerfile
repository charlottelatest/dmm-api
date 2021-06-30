FROM node:latest
COPY ./ .
EXPOSE 4567
CMD ["ruby", "server.rb"]