module github.com/alexeldeib/bpf

go 1.13

require (
	github.com/jaypipes/ghw v0.0.0-20190821154021-743802778342
	github.com/prometheus/common v0.7.0
	github.com/sanity-io/litter v1.2.0
	k8s.io/kubernetes v1.18.0-alpha.0
)

replace (
	k8s.io/api => k8s.io/api v0.0.0-20191029225729-7cae5e131b44
	k8s.io/apiextensions-apiserver => k8s.io/apiextensions-apiserver v0.0.0-20191029230857-69ce5815a59d
	k8s.io/apimachinery => k8s.io/apimachinery v0.0.0-20191025225532-af6325b3a843
	k8s.io/apiserver => k8s.io/apiserver v0.0.0-20191029230314-dc60e3518a82
	k8s.io/cli-runtime => k8s.io/cli-runtime v0.0.0-20191029231108-ef5298d994d2
	k8s.io/client-go => k8s.io/client-go v0.0.0-20191029225935-56fddad37e62
	k8s.io/cloud-provider => k8s.io/cloud-provider v0.0.0-20191029231807-f2248d0f8c21
	k8s.io/cluster-bootstrap => k8s.io/cluster-bootstrap v0.0.0-20191029231706-27de8b75a7b2
	k8s.io/code-generator => k8s.io/code-generator v0.0.0-20191026065352-f361089c127c
	k8s.io/component-base => k8s.io/component-base v0.0.0-20191029230043-e377b96c13ad
	k8s.io/cri-api => k8s.io/cri-api v0.0.0-20191025232916-446748cffdda
	k8s.io/csi-translation-lib => k8s.io/csi-translation-lib v0.0.0-20191029231907-d415d37c0eea
	k8s.io/kube-aggregator => k8s.io/kube-aggregator v0.0.0-20191029230445-0cfd59189c75
	k8s.io/kube-controller-manager => k8s.io/kube-controller-manager v0.0.0-20191029231608-54223a0786aa
	k8s.io/kube-proxy => k8s.io/kube-proxy v0.0.0-20191029231308-c852a8dcb44b
	k8s.io/kube-scheduler => k8s.io/kube-scheduler v0.0.0-20191029231508-61459fcada2a
	k8s.io/kubectl => k8s.io/kubectl v0.0.0-20191029232324-f4e3b750d9be
	k8s.io/kubelet => k8s.io/kubelet v0.0.0-20191029231407-74f15efad707
	k8s.io/legacy-cloud-providers => k8s.io/legacy-cloud-providers v0.0.0-20191029232016-056032af55cd
	k8s.io/metrics => k8s.io/metrics v0.0.0-20191029231006-faebcbe5fda6
	k8s.io/sample-apiserver => k8s.io/sample-apiserver v0.0.0-20191029230607-5a96bb760147
)
