# Use the official Swift image for building
FROM swift:5.9 as builder

WORKDIR /app
COPY . .

# Build the Vapor project in release mode
RUN swift build -c release

# Create a lightweight runtime image
FROM swift:5.9-slim

WORKDIR /app
COPY --from=builder /app/.build/release /app/.build/release
COPY --from=builder /app/Public /app/Public
COPY --from=builder /app/Resources /app/Resources

EXPOSE 8080

# Run the app
CMD [".build/release/Run", "serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
# Use the official Swift image
FROM swift:5.9 as builder

WORKDIR /app
COPY . .

# Build Vapor in release mode
RUN swift build -c release

# Create a slim runtime image
FROM swift:5.9-slim

WORKDIR /app
COPY --from=builder /app/.build/release /app/.build/release
COPY --from=builder /app/Public /app/Public
COPY --from=builder /app/Resources /app/Resources

EXPOSE 8080

# Run the app
CMD [".build/release/Run", "serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
