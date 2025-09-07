# Tiltfile for back-to-danske project

# This Tiltfile sets up local development for the tilt-demo application.

# version_settings() enforces a minimum Tilt version
# https://docs.tilt.dev/api.html#api.version_settings
version_settings(constraint='>=0.22.2')

# --- Configuration ---
# Set the Docker registry to use. For local development, you might use 'kind-registry:5000'
# if you have a local Kind cluster with a registry, or leave it empty for Docker Desktop.
# If you are pushing to a remote registry, specify it here.

from tilt import TriggerMode

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
    trigger_mode=TriggerMode.AUTO,
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

# --- General Tilt Settings ---


# Define a default namespace if your deployments are not in 'default'
# default_namespace('your-namespace')

# To run Tilt:
# 1. Ensure you have a Kubernetes cluster running (e.g., Minikube, Kind, Docker Desktop Kubernetes).
# 2. Ensure your kubectl context is set to the correct cluster.
# 3. Navigate to the root of this project in your terminal.
# 4. Run 'tilt up'.
# 5. Open your browser to http://localhost:10350 to see the Tilt UI.
