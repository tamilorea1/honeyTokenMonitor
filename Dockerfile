#Start from Node.js 22 image
FROM node:22-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy Package files first
# Only re-runs when dependencies change, not on every code change
COPY package*.json ./

# Install only production dependencies
RUN npm ci

# Copy the rest of the source code into the container
COPY . .

# Compile TypeScript + JavaScript
RUN npm run build

# Tell Docker this app listens on Port 3000
EXPOSE 3000

# Start the compiled app
CMD [ "node", "dist/app.js" ]
