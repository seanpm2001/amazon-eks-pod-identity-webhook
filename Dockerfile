FROM --platform=$BUILDPLATFORM golang:1.21 AS builder

WORKDIR $GOPATH/src/github.com/aws/amazon-eks-pod-identity-webhook
COPY . ./
ARG TARGETOS TARGETARCH
RUN GOPROXY=direct CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o /webhook -v -a -ldflags="-buildid='' -w -s" .

FROM --platform=$TARGETPLATFORM public.ecr.aws/eks-distro/kubernetes/go-runner:v0.15.1-eks-1-28-latest
COPY --from=builder /webhook /webhook
ENTRYPOINT ["/go-runner"]
CMD ["/webhook"]
