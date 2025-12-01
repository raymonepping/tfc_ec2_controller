FROM node:22-alpine

WORKDIR /app

# We need git and bash for commit_gh
RUN apk add --no-cache git bash

# Install UI dependencies
COPY package*.json ./
RUN npm install

# Copy the UI server + static assets
COPY . .

# Install the local commit_gh shim into PATH
COPY commit_gh.sh /usr/local/bin/commit_gh
RUN chmod +x /usr/local/bin/commit_gh

EXPOSE 4000
CMD ["node", "server.js"]