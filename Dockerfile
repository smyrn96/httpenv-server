FROM golang:alpine as build

# Set the working directory inside the Docker container
WORKDIR /go/src/app

# Copy go.mod and go.sum before downloading dependencies
RUN go get -a 
COPY go.mod ./
RUN go mod download

# Copy the source code (including httpenv.go and other Go files)
COPY *.go ./

# Build the application
RUN go build -o /go/bin/httpenv httpenv.go

# Stage 2: Test (this should match the target name in your workflow)
FROM build as test
# Run tests
RUN go test -v ./...

# Stage 3: Final image
FROM golang:alpine
RUN addgroup -g 1000 httpenv \
    && adduser -u 1000 -G httpenv -D httpenv
COPY --from=0 --chown=httpenv:httpenv /go/httpenv /httpenv
EXPOSE 8888
# we're not changing user in this example, but you could:
# USER httpenv
CMD ["/httpenv"]