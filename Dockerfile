# Stage 1: Build Stage
FROM node:18 AS build

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json first to leverage Docker caching
COPY package.json package-lock.json ./
RUN npm ci

# Copy all source files and build the project
COPY . .
RUN npm run build  # Assumes "build" script in package.json

# Stage 2: Production Stage
FROM node:18-alpine AS production

WORKDIR /app

# Copy necessary files from the build stage
COPY --from=build /app/package.json /app/package-lock.json ./
COPY --from=build /app/dist ./dist

# Install only production dependencies
RUN npm ci --only=production

# Expose application port
EXPOSE 3000

# Command to run the application
CMD ["node", "dist/index.js"]
