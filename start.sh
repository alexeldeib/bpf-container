cp bpf /opt/bpf
nsenter -t 1 -m /opt/bpf || exit 1
sleep infinity