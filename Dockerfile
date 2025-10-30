# Build stage
FROM node:18 AS builder
WORKDIR /app

COPY app/package*.json ./
RUN npm install

COPY app .
RUN npm run build

# Production nginx stage
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

