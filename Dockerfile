# Stage 1: Build the Go application
FROM golang:alpine AS build

WORKDIR /app
RUN go mod download all

COPY *.go ./

# Copy the Go source file to the container
COPY httpenv.go .

# Build the Go application
RUN go build -o httpenv httpenv.go

# Stage 2: Test (This is the target stage for testing)
FROM build AS test

# If you have test files, make sure to copy them
# (assuming your test files are in the same directory)
COPY _test.go .

# Run Go tests
RUN go test -v ./...

FROM alpine
RUN addgroup -g 1000 httpenv \
    && adduser -u 1000 -G httpenv -D httpenv
COPY --from=0 --chown=httpenv:httpenv /go/httpenv /httpenv
EXPOSE 8888
# we're not changing user in this example, but you could:
# USER httpenv
CMD ["/httpenv"]