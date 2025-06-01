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
# COPY --from=builder /app/Resources /app/Resources ← removed to fix build

EXPOSE 8080

CMD [".build/release/AlertService", "serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
