### STAGE 1: Build ###
# We label our stage as ‘builder’
FROM node:16-alpine as builder

COPY frontend-angular/package.json frontend-angular/package-lock.json ./

## Storing node modules on a separate layer will prevent unnecessary npm installs at each build
RUN npm ci && mkdir /app && mv ./node_modules ./app

WORKDIR /app

COPY /frontend-angular .

## Build the angular app in production mode and store the artifacts in dist folder
RUN npm run build --prod

### STAGE 2: Setup ###
FROM node:16-alpine

RUN apk add dumb-init

## channge directory
WORKDIR /app

#COPY api code to app folder
COPY /backend /app

RUN npm ci --only=production

## From ‘builder’ copy published angular bundles in app/public
COPY --from=builder /app/dist /app
## expose port for express
EXPOSE 3000

CMD ["dumb-init", "npm", "start"]
