BASE := $(subst -, ,$(notdir ${CURDIR}))
ORG  := $(word 1, ${BASE})
REPO := $(word 2, ${BASE})
IMG  := quay.io/${ORG}/${REPO}

build:
	docker build -t ${IMG}:latest	.

publish: TAG=latest
publish: build
	docker push ${IMG}:latest
	@if [ "${TAG}" != "latest" ]; then docker tag ${IMG}:latest ${IMG}:${TAG} && docker push ${IMG}:${TAG}; fi

test: build
	docker-compose up -d
	docker-compose run --rm accumulo-master bash -c "set -e \
		&& source /sbin/hdfs-lib.sh \
		&& wait_until_hdfs_is_available \
		&& accumulo shell -p GisPwd -e 'createtable test_table'"
	docker-compose kill
