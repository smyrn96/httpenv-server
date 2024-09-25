FROM golang:alpine AS build
COPY httpenv.go /go
COPY _test.go /go
RUN go build httpenv.go

FROM build AS test
# Download the Go module dependencies
RUN go mod download golang.org/x/mod@v0.2.0

# Copy the rest of the application source code
COPY *.go ./

FROM alpine
RUN addgroup -g 1000 httpenv \
    && adduser -u 1000 -G httpenv -D httpenv
COPY --from=0 --chown=httpenv:httpenv /go/httpenv /httpenv
EXPOSE 8888
# we're not changing user in this example, but you could:
# USER httpenv
CMD ["/httpenv"]