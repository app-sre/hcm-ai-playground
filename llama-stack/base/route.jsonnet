function (
    hostname="unused",
    mcp_hostname="unused",
    vllm="unused",
)
[
{
    "kind": "Route",
    "apiVersion": "route.openshift.io/v1",
    "metadata": {
        "name": "envoy-llama-stack",
        "namespace": "llama-stack"
    },
    "spec": {
        "host": hostname,
        "path": "/",
        "to": {
            "kind": "Service",
            "name": "envoy-llama-stack",
            "weight": 100
        },
        "port": {
            "targetPort": "web"
        },
        "tls": {
            "termination": "edge",
            "insecureEdgeTerminationPolicy": "Redirect"
        },
        "wildcardPolicy": "None"
    }
}
]