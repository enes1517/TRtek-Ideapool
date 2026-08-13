# Build Stage
FROM ghcr.io/cirruslabs/flutter:3.24.0 AS build
WORKDIR /app

# Copy project files
COPY . .

# Get dependencies and build for web
RUN flutter pub get
RUN flutter build web --release

# Serve Stage
FROM nginx:alpine

# Install openssl to generate self-signed certificate
RUN apk add --no-cache openssl

# Generate self-signed certificate
RUN mkdir -p /etc/ssl/private /etc/ssl/certs && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx-selfsigned.key \
    -out /etc/ssl/certs/nginx-selfsigned.crt \
    -subj "/C=TR/ST=Istanbul/L=Istanbul/O=IdeaPool/OU=IT/CN=localhost"

# Copy the custom Nginx configuration
COPY default.conf /etc/nginx/conf.d/default.conf

# Copy the build output to nginx's html directory
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose HTTP and HTTPS ports
EXPOSE 80 443

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
