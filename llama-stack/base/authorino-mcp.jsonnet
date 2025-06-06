function (
    hostname="unused",
    mcp_hostname="unused",
    vllm="unused",
)
[
{
    "apiVersion": "authorino.kuadrant.io/v1beta3",
    "kind": "AuthConfig",
    "metadata": {
        "name": "envoy-mcp",
        "namespace": "llama-stack"
    },
    "spec": {
        "authentication": {
            "friends": {
                "apiKey": {
                    "allNamespaces": false,
                    "selector": {
                        "matchLabels": {
                            "group": "friends"
                        }
                    }
                },
                "credentials": {
                    "authorizationHeader": {
                        "prefix": "APIKEY"
                    }
                },
                "metrics": false,
                "priority": 0
            },
            "sso": {
                "credentials": {},
                "jwt": {
                    "issuerUrl": "https://sso.redhat.com/auth/realms/redhat-external"
                },
                "metrics": true,
                "priority": 10
            }
        },
        "authorization": {
            "apikey": {
                "metrics": false,
                "patternMatching": {
                    "patterns": [
                        {
                            "operator": "eq",
                            "selector": "auth.identity.metadata.labels.group",
                            "value": "friends"
                        }
                    ]
                },
                "priority": 0,
                "when": [
                    {
                        "operator": "eq",
                        "selector": "auth.identity.metadata.labels.group",
                        "value": "friends"
                    }
                ]
            },
            "jwt": {
                "metrics": false,
                "patternMatching": {
                    "patterns": [
                        {
                            "operator": "eq",
                            "selector": "auth.identity.is_internal",
                            "value": "true"
                        }
                    ]
                },
                "priority": 10,
                "when": [
                    {
                        "operator": "eq",
                        "selector": "auth.identity.iss",
                        "value": "https://sso.redhat.com/auth/realms/redhat-external"
                    }
                ]
            }
        },
        "hosts": [ mcp_hostname ],
        "response": {
            "unauthorized": {
                "message": {
                    "selector": "We were not able to match {auth.identity.email}"
                }
            }
        }
    }
}
]
