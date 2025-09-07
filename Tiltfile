# Tiltfile for back-to-danske project

# This Tiltfile sets up local development for the tilt-demo application.

# version_settings() enforces a minimum Tilt version
# https://docs.tilt.dev/api.html#api.version_settings
version_settings(constraint='>=0.22.2')

# --- Configuration ---
# Set the Docker registry to use. For local development, you might use 'kind-registry:5000'
# if you have a local Kind cluster with a registry, or leave it empty for Docker Desktop.
# If you are pushing to a remote registry, specify it here.

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

# --- General Tilt Settings ---


# Define a default namespace if your deployments are not in 'default'
# default_namespace('your-namespace')

# To run Tilt:
# 1. Ensure you have a Kubernetes cluster running (e.g., Minikube, Kind, Docker Desktop Kubernetes).
# 2. Ensure your kubectl context is set to the correct cluster.
# 3. Navigate to the root of this project in your terminal.
# 4. Run 'tilt up'.
# 5. Open your browser to http://localhost:10350 to see the Tilt UI.
