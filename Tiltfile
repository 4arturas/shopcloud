# Tiltfile for back-to-danske project

# This Tiltfile sets up local development for the tilt-demo application.

# version_settings() enforces a minimum Tilt version
# https://docs.tilt.dev/api.html#api.version_settings
version_settings(constraint='>=0.22.2')

REGISTRY = "" # Default for Docker Desktop or if not using a local registry

# Set default namespace for all Kubernetes resources deployed by Tilt
default_namespace = 'shopcloud'

# --- Tilt Demo Service (Node.js Express) ---
docker_build(
    'arturix/tilt-demo', # Image name for the demo app
    context='cloud/tilt-demo',
    dockerfile='cloud/tilt-demo/Dockerfile',
    live_update=[
        sync('cloud/tilt-demo/', '/app/'), # Sync all files in the demo app directory
        run(
            'npm install',
            trigger=['cloud/tilt-demo/package.json'] # Reinstall if package.json changes
        ),
        run(
            'npm start', # Start the Node.js app
        ),
    ],
    # If you have a local registry, uncomment the next line:
    # registry=REGISTRY,
)

k8s_yaml(['argocd/base/tilt-demo/deployment.yaml', 'argocd/base/tilt-demo/service.yaml'])

k8s_resource(
    'tilt-demo',
    port_forwards='3000:3000', # Map local port 3000 to container port 3000
)

# --- Node-RED Service ---
docker_build(
    'arturix/node-red', # Image name for Node-RED
    context='cloud/node-red',
    dockerfile='cloud/node-red/Dockerfile',
    live_update=[
        sync('cloud/node-red/settings.js', '/data/settings.js'), # Sync settings file
        sync('cloud/node-red/flows.json', '/data/flows.json'), # Sync flows file
        # Node-RED often reloads changes automatically, but a restart might be needed for some changes.
        # If changes don't reflect, you might need to add a run('kill 1') or similar here.
    ],
    # If you have a local registry, uncomment the next line:
    # registry=REGISTRY,
)

k8s_yaml([
    'argocd/base/node-red/deployment.yaml',
    'argocd/base/node-red/service.yaml',
    'argocd/base/node-red/ingress.yaml', # Include ingress if you want to test it locally
])

k8s_resource(
    'nodered',
    port_forwards='1880:1880', # Map local port 1880 to container port 1880
)

# --- Config Server Service ---
local_resource(
    'config-server-build',
    cmd='mvn clean install -DskipTests',
    dir='cloud/config-server',
    deps=['cloud/config-server/pom.xml', 'cloud/config-server/src'],
    trigger_mode=TRIGGER_MODE_AUTO,
)

docker_build(
    'arturix/config-server', # Image name for Config Server
    context='cloud/config-server',
    dockerfile='cloud/config-server/Dockerfile',
    live_update=[
        sync('cloud/config-server/target/config-server-0.0.1-SNAPSHOT.jar', '/app/app.jar'),
        # For Java apps, a full restart is often needed for changes to take effect.
        # You might add: run('kill 1') here to force a restart.
    ],
    # If you have a local registry, uncomment the next line:
    # registry=REGISTRY,
)

k8s_yaml([
    'argocd/base/config-server/deployment.yaml',
    'argocd/base/config-server/service.yaml',
    'argocd/base/config-server/configmap.yaml',
])

k8s_resource(
    'config-server',
    port_forwards='8080:8080', # Map local port 8080 to container port 8080
)

# --- UI Service (Frontend) ---
local_resource(
    'ui-service-build',
    cmd='npm install && npm run build',
    dir='cloud/ui-service',
    deps=['cloud/ui-service/package.json', 'cloud/ui-service/src'],
    trigger_mode=TRIGGER_MODE_AUTO,
)

docker_build(
    'arturix/ui-service', # This tag should match the image in argocd/base/ui-service/deployment.yaml
    context='cloud/ui-service',
    dockerfile='cloud/ui-service/Dockerfile',
    # If you have a local registry, uncomment the next line:
    # registry=REGISTRY,
)

k8s_yaml([
    'argocd/base/ui-service/deployment.yaml',
    'argocd/base/ui-service/service.yaml',
    'argocd/base/ui-service/ingress.yaml',
])

k8s_resource(
    'ui-service',
    port_forwards='5173:80', # Map local port 5173 to container port 80 (Nginx default)
)

# --- Inventory Service ---
local_resource(
    'inventory-service-build',
    cmd='mvn clean install -DskipTests',
    dir='cloud/inventory-service',
    deps=['cloud/inventory-service/pom.xml', 'cloud/inventory-service/src'],
    trigger_mode=TRIGGER_MODE_AUTO,
)

docker_build(
    'arturix/inventory-service', # Image name for Inventory Service
    context='cloud/inventory-service',
    dockerfile='cloud/inventory-service/Dockerfile',
    live_update=[
        sync('cloud/inventory-service/target/inventory-service-0.0.1-SNAPSHOT.jar', '/app/app.jar'),
        run('kill 1'), # Force restart to pick up config changes
    ],
    # If you have a local registry, uncomment the next line:
    # registry=REGISTRY,
)

k8s_yaml([
    'argocd/base/inventory-service/deployment.yaml',
    'argocd/base/inventory-service/service.yaml',
    'argocd/base/inventory-service/ingress.yaml',
])

k8s_resource(
    'inventory-service',
    port_forwards='8081:8080', # Map local port 8081 to container port 8080
)

# --- Notification Service ---
local_resource(
    'notification-service-build',
    cmd='mvn clean install -DskipTests',
    dir='cloud/notification-service',
    deps=['cloud/notification-service/pom.xml', 'cloud/notification-service/src'],
    trigger_mode=TRIGGER_MODE_AUTO,
)

docker_build(
    'arturix/notification-service', # Image name for Notification Service
    context='cloud/notification-service',
    dockerfile='cloud/notification-service/Dockerfile',
    live_update=[
        sync('cloud/notification-service/target/notification-service-0.0.1-SNAPSHOT.jar', '/app/app.jar'),
        run('kill 1'), # Force restart to pick up config changes
    ],
    # If you have a local registry, uncomment the next line:
    # registry=REGISTRY,
)

k8s_yaml([
    'argocd/base/notification-service/deployment.yaml',
    'argocd/base/notification-service/service.yaml',
])

k8s_resource(
    'notification-service',
    port_forwards='8082:8080', # Map local port 8082 to container port 8080
)

# --- Order Service ---
local_resource(
    'order-service-build',
    cmd='mvn clean install -DskipTests',
    dir='cloud/order-service',
    deps=['cloud/order-service/pom.xml', 'cloud/order-service/src'],
    trigger_mode=TRIGGER_MODE_AUTO,
)

docker_build(
    'arturix/order-service', # Image name for Order Service
    context='cloud/order-service',
    dockerfile='cloud/order-service/Dockerfile',
    live_update=[
        sync('cloud/order-service/target/order-service-0.0.1-SNAPSHOT.jar', '/app/app.jar'),
        # For Java apps, a full restart is often needed for changes to take effect.
        # You might add: run('kill 1') here to force a restart.
    ],
    # If you have a local registry, uncomment the next line:
    # registry=REGISTRY,
)

k8s_yaml([
    'argocd/base/order-service/deployment.yaml',
    'argocd/base/order-service/service.yaml',
])

k8s_resource(
    'order-service',
    port_forwards='8083:8080', # Map local port 8083 to container port 8080
)

# --- Payment Service ---
local_resource(
    'payment-service-build',
    cmd='mvn clean install -DskipTests',
    dir='cloud/payment-service',
    deps=['cloud/payment-service/pom.xml', 'cloud/payment-service/src'],
    trigger_mode=TRIGGER_MODE_AUTO,
)

docker_build(
    'arturix/payment-service', # Image name for Payment Service
    context='cloud/payment-service',
    dockerfile='cloud/payment-service/Dockerfile',
    live_update=[
        sync('cloud/payment-service/target/payment-service-0.0.1-SNAPSHOT.jar', '/app/app.jar'),
        # For Java apps, a full restart is often needed for changes to take effect.
        # You might add: run('kill 1') here to force a restart.
    ],
    # If you have a local registry, uncomment the next line:
    # registry=REGISTRY,
)

k8s_yaml([
    'argocd/base/payment-service/deployment.yaml',
    'argocd/base/payment-service/service.yaml',
])

k8s_resource(
    'payment-service',
    port_forwards='8084:8080', # Map local port 8084 to container port 8080
)

# --- Product Service ---
local_resource(
    'product-service-build',
    cmd='mvn clean install -DskipTests',
    dir='cloud/product-service',
    deps=['cloud/product-service/pom.xml', 'cloud/product-service/src'],
    trigger_mode=TRIGGER_MODE_AUTO,
)

docker_build(
    'arturix/product-service', # Image name for Product Service
    context='cloud/product-service',
    dockerfile='cloud/product-service/Dockerfile',
    live_update=[
        sync('cloud/product-service/target/product-service-0.0.1-SNAPSHOT.jar', '/app/app.jar'),
        # For Java apps, a full restart is often needed for changes to take effect.
        # You might add: run('kill 1') here to force a restart.
    ],
    # If you have a local registry, uncomment the next line:
    # registry=REGISTRY,
)

k8s_yaml([
    'argocd/base/product-service/deployment.yaml',
    'argocd/base/product-service/service.yaml',
])

k8s_resource(
    'product-service',
    port_forwards='8085:8080', # Map local port 8085 to container port 8080
)

# --- User Service ---
local_resource(
    'user-service-build',
    cmd='mvn clean install -DskipTests',
    dir='cloud/user-service',
    deps=['cloud/user-service/pom.xml', 'cloud/user-service/src'],
    trigger_mode=TRIGGER_MODE_AUTO,
)

docker_build(
    'arturix/user-service', # Image name for User Service
    context='cloud/user-service',
    dockerfile='cloud/user-service/Dockerfile',
    live_update=[
        sync('cloud/user-service/target/user-service-0.0.1-SNAPSHOT.jar', '/app/app.jar'),
        # For Java apps, a full restart is often needed for changes to take effect.
        # You might add: run('kill 1') here to force a restart.
    ],
    # If you have a local registry, uncomment the next line:
    # registry=REGISTRY,
)

k8s_yaml([
    'argocd/base/user-service/deployment.yaml',
    'argocd/base/user-service/service.yaml',
])

k8s_resource(
    'user-service',
    port_forwards='8086:8080', # Map local port 8086 to container port 8080
)

# --- API Gateway Service ---
local_resource(
    'api-gateway-build',
    cmd='mvn clean install -DskipTests',
    dir='cloud/api-gateway',
    deps=['cloud/api-gateway/pom.xml', 'cloud/api-gateway/src'],
    trigger_mode=TRIGGER_MODE_AUTO,
)

docker_build(
    'arturix/api-gateway', # Image name for API Gateway
    context='cloud/api-gateway',
    dockerfile='cloud/api-gateway/Dockerfile',
    live_update=[
        sync('cloud/api-gateway/target/api-gateway-0.0.1-SNAPSHOT.jar', '/app/app.jar'),
        # For Java apps, a full restart is often needed for changes to take effect.
        # You might add: run('kill 1') here to force a restart.
    ],
    # If you have a local registry, uncomment the next line:
    # registry=REGISTRY,
)

k8s_yaml([
    'argocd/base/api-gateway/deployment.yaml',
    'argocd/base/api-gateway/service.yaml',
    'argocd/base/api-gateway/ingress.yaml',
])

k8s_resource(
    'api-gateway',
    port_forwards='8088:8080', # Map local port 8088 to container port 8080
)

# --- Kafka Components ---

k8s_yaml('argocd/base/kafka/kafka.yaml')
k8s_yaml('argocd/base/kafka/kafka-ui-ingress.yaml')

k8s_resource('zookeeper-1', port_forwards='2181:2181')
k8s_resource('kafka-broker-1', port_forwards='9092:9092')
k8s_resource('kafka-broker-2', port_forwards='9093:9093')
k8s_resource('kafka-monitoring-ui', port_forwards='8087:8082')

# --- General Tilt Settings ---


# Define a default namespace if your deployments are not in 'default'
# default_namespace('your-namespace')

# To run Tilt:
# 1. Ensure you have a Kubernetes cluster running (e.g., Minikube, Kind, Docker Desktop Kubernetes).
# 2. Ensure your kubectl context is set to the correct cluster.
# 3. Navigate to the root of this project in your terminal.
# 4. Run 'tilt up'.
# 5. Open your browser to http://localhost:10350 to see the Tilt UI.
