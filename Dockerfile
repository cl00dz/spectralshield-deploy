# ---- Build Stage ----
FROM node:20 AS builder
WORKDIR /app

# Copy package files first for caching
COPY app/package*.json ./

RUN npm install

# Copy the rest of your app source
COPY app/ .

# Build your Vite/React app
RUN npm run build


# ---- Run Stage ----
FROM nginx:alpine
WORKDIR /usr/share/nginx/html

# Copy built assets from builder
COPY --from=builder /app/dist ./

# Replace default config to support SPA routing
RUN rm -rf /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
