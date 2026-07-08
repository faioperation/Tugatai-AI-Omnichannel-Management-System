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