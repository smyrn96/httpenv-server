FROM golang:alpine AS build
COPY httpenv.go /go
RUN go build httpenv.go

FROM build AS test
COPY _test.go /go
RUN go test ./...

FROM build
RUN addgroup -g 1000 httpenv \
    && adduser -u 1000 -G httpenv -D httpenv
COPY --from=0 --chown=httpenv:httpenv /go/httpenv /httpenv
EXPOSE 8888
# we're not changing user in this example, but you could:
# USER httpenv
CMD ["/httpenv"]