FROM golang:alpine as build
COPY httpenv.go /go
COPY go.mod go.sum ./
RUN go mod download
COPY *.go ./
RUN go build httpenv.go

# Stage 2: Test (this should match the target name in your workflow)
FROM build as test
RUN go test -v ./...

FROM build
RUN addgroup -g 1000 httpenv \
    && adduser -u 1000 -G httpenv -D httpenv
COPY --from=0 --chown=httpenv:httpenv /go/httpenv /httpenv
EXPOSE 8888
# we're not changing user in this example, but you could:
# USER httpenv
CMD ["/httpenv"]