function (
    hostname="unused",
    vllm="unused",
)
[
{
    "kind": "Route",
    "apiVersion": "route.openshift.io/v1",
    "metadata": {
        "name": "envoy-mcp",
        "namespace": "llama-stack"
    },
    "spec": {
        "host": hostname,
        "path": "/",
        "to": {
            "kind": "Service",
            "name": "envoy-mcp",
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