![](/public/IMG_2454)

# CDA Default MinIO Instance

This repository provides a comprehensive setup for running MinIO with DNS-style bucket naming and a reverse proxy using Nginx. Additionally, it integrates a Tailscale GitHub Action to connect to a hybrid cloud VPN, facilitating the development of application layer AI.

## Features

- MinIO server with DNS-style bucket naming
- Nginx reverse proxy for MinIO server and console
- Automatic bucket creation on startup
- Docker Compose for easy deployment
- GitHub Actions workflows for CI/CD
- Secure connection to hybrid cloud VPN via Tailscale for AI development

## Prerequisites

- Docker
- Docker Compose
- Tailscale
- GitHub

## Setup

### Clone the Repository

```sh
git clone https://github.com/Cdaprod/cda.minio.git
cd cda.minio
```

### Environment Variables

Create a `.env` file in the root directory of the repository with the following content:

```env
MINIO_ROOT_USER=your-minio-root-user
MINIO_ROOT_PASSWORD=your-minio-root-password
MINIO_DOMAIN=example.com
```

Replace `your-minio-root-user` and `your-minio-root-password` with your desired MinIO root user and password, and `example.com` with your domain.

### Build and Run the Containers

1. **Build the MinIO Docker image:**

   ```sh
   docker build -t cdaprod/cda-minio:latest .
   ```

2. **Start the services with Docker Compose:**

   ```sh
   docker-compose up -d
   ```

## Accessing MinIO

- **MinIO Server:** Access the MinIO server via your browser at `http://<bucket-name>.example.com`.
- **MinIO Console:** Access the MinIO console at `http://console.example.com`.

## Configuration Details

### `entrypoint.sh`

The `entrypoint.sh` script initializes the MinIO server, sets up the MinIO client (`mc`), and creates the necessary buckets if they do not already exist.

### Dockerfile

The Dockerfile sets up the MinIO container with the custom `entrypoint.sh` script and exposes the required ports.

### Docker Compose

The `docker-compose.yml` file defines the MinIO and Nginx services, configures environment variables, and sets up the necessary volumes and networks.

### Nginx Configuration

The `nginx.conf` file configures Nginx to proxy requests to the MinIO server and console, allowing DNS-style bucket access.

## Workflows

### Build and Push Docker Image

This workflow builds and pushes the Docker image to both Docker Hub and GitHub Container Registry.

```yaml
name: Build and Push Docker Image

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build-and-push:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2

    - name: Login to Docker Hub
      uses: docker/login-action@v2
      with:
        username: ${{ secrets.DOCKERHUB_USERNAME }}
        password: ${{ secrets.DOCKERHUB_TOKEN }}

    - name: Login to GitHub Container Registry
      uses: docker/login-action@v2
      with:
        registry: ghcr.io
        username: ${{ github.repository_owner }}
        password: ${{ secrets.GH_TOKEN }}

    - name: Build and push Docker image
      uses: docker/build-push-action@v3
      with:
        context: .
        push: true
        tags: |
          cdaprod/cda-minio:latest
          ghcr.io/cdaprod/cda-minio:latest
```

### SSH Securely over Tailscale Test

This workflow tests SSH connectivity over Tailscale, hydrates MinIO and Weaviate, and installs the necessary Python dependencies.

```yaml
name: SSH Securely over Tailscale Test

on:
  push:
    branches:
      - tailscale-tests

jobs:
  hydrate-minio-weaviate:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v2

      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: '3.8'
      
      - name: Install Python dependencies
        run: |
          python -m pip install --upgrade pip
          pip install requests minio weaviate-client pydantic unstructured python-dotenv

      - name: Load environment variables
        run: |
          echo "MINIO_ACCESS_KEY=${{ secrets.MINIO_ACCESS_KEY }}" >> $GITHUB_ENV
          echo "MINIO_SECRET_KEY=${{ secrets.MINIO_SECRET_KEY }}" >> $GITHUB_ENV
          echo "WEAVIATE_ENDPOINT=${{ secrets.WEAVIATE_ENDPOINT }}" >> $GITHUB_ENV

      - name: Setup Tailscale
        uses: tailscale/github-action@v2
        with:
          oauth-client-id: ${{ secrets.TS_OAUTH_CLIENT_ID }}
          oauth-secret: ${{ secrets.TS_OAUTH_SECRET }}
          tags: tag:ci
      
      - name: SSH into Node
        run: |
          ssh -o "StrictHostKeyChecking no" cdaprod "
            uname -a
          "
```

## Adding Custom Configuration

You can add custom configurations or scripts as needed by modifying the `Dockerfile` and `entrypoint.sh` script. For example, you can copy additional configuration files into the container or set up more complex initialization logic.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact

For questions or support, please reach out to the repository maintainer.

---

MinIO and the MinIO logo are trademarks of MinIO, Inc.