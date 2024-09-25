# Stage 1: Build the Go application
FROM golang:1.17 AS build

# Set the working directory inside the container
WORKDIR /app

# Copy the go mod and sum files
COPY go.mod go.sum ./

# Download all dependencies
RUN go mod download

# Copy the source from the current directory to the working directory inside the container
COPY . .

# Build the application
RUN go build -o httpenv httpenv.go

# Stage 2: Test (this should match the target name in your workflow)
FROM build AS test
# Run tests
RUN go test -v ./...

# Stage 3: Final image
FROM golang:1.17
RUN addgroup -g 1000 httpenv \
    && adduser -u 1000 -G httpenv -D httpenv
COPY --from=0 --chown=httpenv:httpenv /go/httpenv /httpenv
EXPOSE 8888
# we're not changing user in this example, but you could:
# USER httpenv
CMD ["/httpenv"]