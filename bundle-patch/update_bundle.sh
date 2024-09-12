#!/usr/bin/env bash

set -e

# The pullspec should be image index, check if all architectures are there with: skopeo inspect --raw docker://$IMG | jq
export JAEGER_COLLECTOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/otel/otel-collector@sha256:a85014261c0d1a926b56751de3a07772341a132dd98c65ed723f8d6316d59ef8"
# Separate due to merge conflicts
export JAEGER_AGENT_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-agent@sha256:1f5a121fb6dea9cd5dfc5f407a75f938377617c66d3474f88db3f1aaf6cb437b"
# Separate due to merge conflicts
export JAEGER_INGESTER_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/otel/otel-collector@sha256:a85014261c0d1a926b56751de3a07772341a132dd98c65ed723f8d6316d59ef8"
# Separate due to merge conflicts
export JAEGER_QUERY_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/otel/otel-collector@sha256:a85014261c0d1a926b56751de3a07772341a132dd98c65ed723f8d6316d59ef8"
# Separate due to merge conflicts
export JAEGER_ALL_IN_ONE_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/otel/otel-collector@sha256:a85014261c0d1a926b56751de3a07772341a132dd98c65ed723f8d6316d59ef8"
# Separate due to merge conflicts
export JAEGER_ROLLOVER_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/otel/otel-collector@sha256:a85014261c0d1a926b56751de3a07772341a132dd98c65ed723f8d6316d59ef8"
# Separate due to merge conflicts
export JAEGER_INDEX_CLEANER_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-es-index-cleaner@sha256:23b0dd406c83be098ad90d23d1bdee9b088e5c0b4b8a34ac9eb9c311d23baf7a"
# Separate due to merge conflicts
export JAEGER_OPERATOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-operator@sha256:f2adb76129bc38c42f2308e073e5a2349ebd440f45be7a1453ab33410ed4ec7c"


export CSV_FILE=/manifests/jaeger-operator.clusterserviceversion.yaml

sed -i -e "s|quay.io/jaegertracing/jaeger-operator\:.*|\"${JAEGER_OPERATOR_IMAGE_PULLSPEC}\"|g" \
	"${CSV_FILE}"

sed -i "s#jaeger-collector-container-pullspec#$JAEGER_COLLECTOR_IMAGE_PULLSPEC#g" patch_csv.yaml
sed -i "s#jaeger-agent-container-pullspec#$JAEGER_AGENT_IMAGE_PULLSPEC#g" patch_csv.yaml
sed -i "s#jaeger-query-container-pullspec#$JAEGER_QUERY_IMAGE_PULLSPEC#g" patch_csv.yaml
sed -i "s#jaeger-ingester-container-pullspec#$JAEGER_INGESTER_IMAGE_PULLSPEC#g" patch_csv.yaml
sed -i "s#jaeger-allinone-container-pullspec#$JAEGER_ALL_IN_ONE_IMAGE_PULLSPEC#g" patch_csv.yaml
sed -i "s#jaeger-rollover-container-pullspec#$JAEGER_ROLLOVER_IMAGE_PULLSPEC#g" patch_csv.yaml
sed -i "s#jaeger-index-cleaner-container-pullspec#$JAEGER_INDEX_CLEANER_IMAGE_PULLSPEC#g" patch_csv.yaml

export AMD64_BUILT=$(skopeo inspect --raw docker://${JAEGER_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="amd64")')
export ARM64_BUILT=$(skopeo inspect --raw docker://${JAEGER_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="arm64")')
export PPC64LE_BUILT=$(skopeo inspect --raw docker://${JAEGER_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="ppc64le")')
export S390X_BUILT=$(skopeo inspect --raw docker://${JAEGER_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="s390x")')

export EPOC_TIMESTAMP=$(date +%s)


# time for some direct modifications to the csv
python3 patch_csv.py
python3 patch_annotations.py


