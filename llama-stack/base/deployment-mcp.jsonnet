function (
    hostname="unused",
    mcp_hostname="unused",
    vllm="unused",
)
[
{
    "kind": "Deployment",
    "apiVersion": "apps/v1",
    "metadata": {
        "name": "mcp-server",
        "namespace": "llama-stack",
        "labels": {
            "app": "mcp-server"
        }
    },
    "spec": {
        "replicas": 1,
        "selector": {
            "matchLabels": {
                "app": "mcp-server"
            }
        },
        "template": {
            "metadata": {
                "labels": {
                    "app": "mcp-server"
                }
            },
            "spec": {
                "restartPolicy": "Always",
                "serviceAccountName": "default",
                "containers": [
                    {
                        "resources": {
                            "limits": {
                                "cpu": "500m",
                                "memory": "512Mi"
                            },
                            "requests": {
                                "cpu": "250m",
                                "memory": "256Mi"
                            }
                        },
                        "terminationMessagePath": "/dev/termination-log",
                        "name": "mcp",
                        "command": [
                            "python",
                            "solver.py",
                        ],
                        "ports": [
                            {
                                "name": "user-port",
                                "containerPort": 5000,
                                "protocol": "TCP"
                            }
                        ],
                        "imagePullPolicy": "IfNotPresent",
                        "terminationMessagePolicy": "FallbackToLogsOnError",
                        "image": "quay.io/psav/mcp:02"
                    }
                ],
                "serviceAccount": "default"
            }
        }
    }
}
]