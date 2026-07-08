<<<<<<< Updated upstream
############################
# Build Stage
############################
FROM ghcr.io/cirruslabs/flutter:stable AS builder

WORKDIR /app

COPY pubspec.* ./

RUN flutter pub get

COPY . .

RUN flutter build web --release

############################
# Production Stage
############################
FROM nginx:1.29-alpine

RUN apk add --no-cache curl

COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY --from=builder /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
=======
# Production-grade Dockerfile for Flutter Web Client serving via Nginx
FROM debian:bookworm-slim AS build-env

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Clone Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter -b stable --depth 1

# Add Flutter to path
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run doctor and pre-download development binaries
RUN flutter doctor -v

# Set working directory
WORKDIR /app

# Copy dependency definitions
COPY pubspec.yaml pubspec.lock ./

# Fetch dependencies
RUN flutter pub get

# Copy source code
COPY . .

# Build web distribution with release options
RUN flutter build web --release --base-href=/dashboard/

# Production stage - Serve using lightweight alpine-based Nginx
FROM nginx:alpine-slim

# Copy the build artifacts from the builder stage to Nginx html directory
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Expose port
EXPOSE 80

# Copy the custom nginx configuration to serve routes correctly
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Command to start Nginx
CMD ["nginx", "-g", "daemon off;"]
>>>>>>> Stashed changes
