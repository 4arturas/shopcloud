# Tiltfile for back-to-danske project

# This Tiltfile sets up local development for the tilt-demo application.

# version_settings() enforces a minimum Tilt version
# https://docs.tilt.dev/api.html#api.version_settings
version_settings(constraint='>=0.22.2')

REGISTRY = "" # Default for Docker Desktop or if not using a local registry

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
    target='build-stage', # Use the build-stage for development to get Node.js environment
    live_update=[
        fall_back_on('cloud/ui-service/vite.config.ts'), # Full rebuild if Vite config changes
        sync('cloud/ui-service/', '/app/'), # Sync entire source directory
        run(
            'npm install',
            trigger=['cloud/ui-service/package.json', 'cloud/ui-service/package-lock.json']
        ),
        run(
            'npm run dev', # Start the Vite dev server
        ),
    ],
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
    port_forwards='5173:5173', # Map local port 5173 to container port 5173 (Vite dev server default)
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
        # For Java apps, a full restart is often needed for changes to take effect.
        # You might add: run('kill 1') here to force a restart.
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
    port_forwards='8080:8080', # Map local port 8080 to container port 8080
)

# --- General Tilt Settings ---


# Define a default namespace if your deployments are not in 'default'
# default_namespace('your-namespace')

# To run Tilt:
# 1. Ensure you have a Kubernetes cluster running (e.g., Minikube, Kind, Docker Desktop Kubernetes).
# 2. Ensure your kubectl context is set to the correct cluster.
# 3. Navigate to the root of this project in your terminal.
# 4. Run 'tilt up'.
# 5. Open your browser to http://localhost:10350 to see the Tilt UI.
