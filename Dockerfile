# ---------- BUILD STAGE ----------
FROM node:20-alpine AS builder

WORKDIR /app

# Copy dependency files
COPY package*.json ./

# Install deps
RUN npm install

# Copy rest of project
COPY . .

# Build the frontend (Vite)
RUN npm run build

# ---------- RUNTIME STAGE ----------
FROM nginx:alpine

# Remove default nginx site
RUN rm -rf /usr/share/nginx/html/*

# Copy build output
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose web port
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
