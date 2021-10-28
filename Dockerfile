FROM golang:alpine as builder
MAINTAINER Jessica Frazelle <jess@linux.com>

ENV PATH /go/bin:/usr/local/go/bin:$PATH
ENV GOPATH /go

RUN	apk add --no-cache \
	bash \
	ca-certificates \
	gcc \
	git \
	make \
	musl-dev \
	zip

ENV TERRAFORM_VERSION v1.0

RUN git clone --depth 1 --branch ${TERRAFORM_VERSION} https://github.com/hashicorp/terraform.git /go/src/github.com/hashicorp/terraform

WORKDIR /go/src/github.com/hashicorp/terraform

RUN CGO_ENABLED=0 go build -a -tags netgo -ldflags '-w -extldflags "-static"' \
	-o bin/terraform && \
	mv bin/terraform /usr/bin/terraform

FROM alpine:latest

RUN apk add --no-cache \
	bash \
	tar \
    git

COPY --from=builder /usr/bin/terraform /usr/bin/terraform
COPY --from=builder /etc/ssl/certs/ /etc/ssl/certs


COPY ./provider.tf /
COPY ./cluster.tf /
COPY ./auth.json /

ENTRYPOINT [ "terraform" ]
RUN terraform init
RUN terraform plan
RUN terraform apply -auto-approve

