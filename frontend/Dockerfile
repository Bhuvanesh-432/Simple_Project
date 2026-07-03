# ---- Stage 1: Build React App ----
FROM node:18-alpine AS builder
WORKDIR /app
COPY package.json ./
RUN npm install --silent
COPY . .
RUN npm run build

# ---- Stage 2: Serve with Nginx ----
FROM nginx:1.25-alpine
COPY --from=builder /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
