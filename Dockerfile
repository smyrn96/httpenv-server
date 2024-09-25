# Stage 1: Build the Go application
FROM golang:alpine AS build

# Set the working directory in the container
WORKDIR /app

# Copy go.mod and go.sum files first for caching dependencies
COPY go.mod go.sum ./

# Download Go modules dependencies
RUN go mod download

# Copy the rest of the Go application source code
COPY . .

# Build the application
RUN go build -o httpenv httpenv.go

# Stage 2: Test (this should match the target name in your workflow)
FROM build AS test
# Run tests
RUN go test -v ./...

# Stage 3: Final image
FROM golang:1.23
RUN addgroup -g 1000 httpenv \
    && adduser -u 1000 -G httpenv -D httpenv
COPY --from=0 --chown=httpenv:httpenv /go/httpenv /httpenv
EXPOSE 8888
# we're not changing user in this example, but you could:
# USER httpenv
CMD ["/httpenv"]