# -------------------
# Build Frontend
# -------------------
FROM node:18 AS builder
WORKDIR /app

# Copy the app
COPY app/ ./

# Install & build
RUN npm install && npm run build

# -------------------
# NGINX Stage
# -------------------
FROM nginx:alpine

# Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy built app to nginx web root
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port
EXPOSE 80

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]
