function (
    hostname="unused",
    vllm="unused",
)
[
{
    "kind": "Deployment",
    "apiVersion": "apps/v1",
    "metadata": {
        "name": "llama-stack-server",
        "namespace": "llama-stack",
        "labels": {
            "app": "llama-stack-server"
        }
    },
    "spec": {
        "replicas": 1,
        "selector": {
            "matchLabels": {
                "app": "llama-stack-server"
            }
        },
        "template": {
            "metadata": {
                "labels": {
                    "app": "llama-stack-server"
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
                        "name": "llama-stack",
                        "command": [
                            "python",
                            "-m",
                            "llama_stack.distribution.server.server",
                            "--config",
                            "/opt/app/run.yaml"
                        ],
                        "env": [
                            {
                                "name": "VLLM_API_TOKEN",
                                "valueFrom": {
                                    "secretKeyRef": {
                                        "name": "llama-stack-ai",
                                        "key": "token"
                                    }
                                }
                            },
                            {
                                "name": "VLLM_URL",
                                "value": vllm
                            },
                            {
                                "name": "INFERENCE_MODEL",
                                "value": "llama-scout-maas"
                            }
                        ],
                        "ports": [
                            {
                                "name": "user-port",
                                "containerPort": 8321,
                                "protocol": "TCP"
                            }
                        ],
                        "imagePullPolicy": "IfNotPresent",
                        "terminationMessagePolicy": "FallbackToLogsOnError",
                        "image": "quay.io/psav/lstack:01"
                    }
                ],
                "serviceAccount": "default"
            }
        }
    }
}
]