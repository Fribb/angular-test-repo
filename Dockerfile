######################
### STAGE 1: Build ###
######################
## use node lts-alpine image as builder
FROM node:lts-alpine AS builder

## Copy the frontend project configuration to the current directory
COPY frontend-angular/package.json frontend-angular/package-lock.json ./

## Storing node modules on a separate layer will prevent unnecessary npm installs at each build
RUN npm ci && mkdir /app && mv ./node_modules ./app

WORKDIR /app

## Copy the frontend to the /app folder
COPY /frontend-angular .

## Build the angular app in production mode and store the artifacts in dist folder
RUN npm run build --prod

######################
### STAGE 2: Setup ###
######################
## use linuxserver alpine base image
FROM lsiobase/alpine:amd64-3.15

## set Environment variables
ENV PUID=1000
ENV PGID=1000

## install npm
RUN apk add --update npm

WORKDIR /app

## copy backend to app
COPY ./backend /app

## install backend
RUN npm ci --only=production

## From ‘builder’ copy published angular bundles in app/public
COPY --from=builder /app/dist /app

RUN chown -R ${PUID}:${PGID} /app

## expose port 3000
EXPOSE 3000

## run node server
CMD ["npm", "start"]
