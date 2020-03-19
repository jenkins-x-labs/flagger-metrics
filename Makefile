CHART_REPO := gs://jenkinsxio-labs/charts
NAME := flagger-metrics
OS := $(shell uname)

CHARTMUSEUM_CREDS_USR := $(shell cat /builder/home/basic-auth-user.json)
CHARTMUSEUM_CREDS_PSW := $(shell cat /builder/home/basic-auth-pass.json)

setup:
	helm repo add jenkinsxio http://chartmuseum.jenkins-x.io

build: clean setup
	helm lint flagger-metrics

install: clean build
	helm upgrade ${NAME} flagger-metrics --install

upgrade: clean build
	helm upgrade ${NAME} flagger-metrics --install

delete:
	helm delete --purge ${NAME} flagger-metrics

clean:
	rm -rf flagger-metrics/charts
	rm -rf flagger-metrics/${NAME}*.tgz
	rm -rf flagger-metrics/requirements.lock

release: clean build
ifeq ($(OS),Darwin)
	sed -i "" -e "s/version:.*/version: $(VERSION)/" flagger-metrics/Chart.yaml
else ifeq ($(OS),Linux)
	sed -i -e "s/version:.*/version: $(VERSION)/" flagger-metrics/Chart.yaml
else
	exit -1
endif
	helm package flagger-metrics
	helm repo add jx-labs $(CHART_REPO)
	helm gcs push ${NAME}*.tgz jx-labs --public
	rm -rf ${NAME}*.tgz%

