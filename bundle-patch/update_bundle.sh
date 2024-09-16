#!/usr/bin/env bash

set -e

# The pullspec should be image index, check if all architectures are there with: skopeo inspect --raw docker://$IMG | jq
export JAEGER_COLLECTOR_IMAGE_PULLSPEC="registry.redhat.io/rhosdt/jaeger-collector-rhel8@sha256:37c0761bc89055e53428271bcbe70cbee4eebdc9511332faa0e48d11a39cc636"
# Separate due to merge conflicts
export JAEGER_AGENT_IMAGE_PULLSPEC="registry.redhat.io/rhosdt/jaeger-agent-rhel8@sha256:41dd97703d7e8967f7d51ce338e83527a7354249affe1e94a1abfd340fdfdab7"
# Separate due to merge conflicts
export JAEGER_INGESTER_IMAGE_PULLSPEC="registry.redhat.io/rhosdt/jaeger-ingester-rhel8@sha256:5538d1a579d03d6e6b2051ec30d161bc130f1d930a9fe6769aabaa978a86138d"
# Separate due to merge conflicts
export JAEGER_QUERY_IMAGE_PULLSPEC="registry.redhat.io/rhosdt/jaeger-query-rhel8@sha256:b9fa4f1c62efb389f671de3fdae50813f4092c8b6b7d8cdb1d6b9b865e970421"
# Separate due to merge conflicts
export JAEGER_ALL_IN_ONE_IMAGE_PULLSPEC="registry.redhat.io/rhosdt/jaeger-all-in-one-rhel8@sha256:6fd39ab19d56393cae9b8fe173d29bb55bb9ae8142761f07460c3ab1aa7357f5"
# Separate due to merge conflicts
export JAEGER_ROLLOVER_IMAGE_PULLSPEC="registry.redhat.io/rhosdt/jaeger-es-rollover-rhel8@sha256:c29479eae7654f027713912ad2d92c6fa7a52e20b41ba789c842a0ad487581fc"
# Separate due to merge conflicts
export JAEGER_INDEX_CLEANER_IMAGE_PULLSPEC="registry.redhat.io/jaeger-es-index-cleaner-rhel8@sha256:4253d649ee8cf39d5ba337f5e15a215959e288d26f9f02d117de0a695682e76b"
# Separate due to merge conflicts
export JAEGER_OPERATOR_IMAGE_PULLSPEC="registry.redhat.io/rhosdt/jaeger-rhel8-operator@sha256:af95bff1d101355d56abfd1ca3b1b77dc1946e1cbdb20076d5177f2beec9351e"
# Separate due to merge conflicts
# TODO, we used to set the proxy image per OCP version
export OSE_KUBE_RBAC_PROXY_PULLSPEC="registry.redhat.io/openshift4/ose-kube-rbac-proxy@sha256:8204d45506297578c8e41bcc61135da0c7ca244ccbd1b39070684dfeb4c2f26c"


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
sed -i "s#ose-kube-rbac-proxy-container-pullspec#$OSE_KUBE_RBAC_PROXY_PULLSPEC#g" patch_csv.yaml

export AMD64_BUILT=$(skopeo inspect --raw docker://${JAEGER_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="amd64")')
export ARM64_BUILT=$(skopeo inspect --raw docker://${JAEGER_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="arm64")')
export PPC64LE_BUILT=$(skopeo inspect --raw docker://${JAEGER_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="ppc64le")')
export S390X_BUILT=$(skopeo inspect --raw docker://${JAEGER_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="s390x")')

export EPOC_TIMESTAMP=$(date +%s)


# time for some direct modifications to the csv
python3 patch_csv.py
python3 patch_annotations.py


