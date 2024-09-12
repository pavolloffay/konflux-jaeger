#!/usr/bin/env bash

set -e

# The pullspec should be image index, check if all architectures are there with: skopeo inspect --raw docker://$IMG | jq
export JAEGER_COLLECTOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-collector@sha256:7861df0fbcc4649e7a4b5b5fcdedf2196b7b790ba0fff1ad12034fc7443fa7d8"
# Separate due to merge conflicts
export JAEGER_AGENT_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-agent@sha256:11c3ed8853fb1a4246fdf21303cca11f34a212fa9659d8f705987a2fe194c170"
# Separate due to merge conflicts
export JAEGER_INGESTER_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-ingester@sha256:24817d34d8d075c9a2143e12b7685c8b85e112fa3ef06ff1118858c67089b75f"
# Separate due to merge conflicts
export JAEGER_QUERY_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-query@sha256:60583a1d0c2ac2f2170b7671e145794dec385525d655594999025695e2c33ea5"
# Separate due to merge conflicts
export JAEGER_ALL_IN_ONE_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-all-in-one@sha256:921932a3248f8066be9d323b2e919c67d1981d29eff05153acf2788512376671"
# Separate due to merge conflicts
export JAEGER_ROLLOVER_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-es-rollover@sha256:7c359e87172e69a39c8d50e5f697b0cdc53a86fadb9aba72ca6e3e90be090657"
# Separate due to merge conflicts
export JAEGER_INDEX_CLEANER_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-es-index-cleaner@sha256:b4c284e71601303fe0b59b0c2f78162f789af4d415e351bf15e00dccac99bc5d"
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


