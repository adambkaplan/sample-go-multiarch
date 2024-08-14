# Sample Mult-Arch Go Application

A very simple HTTP server that reports back the GOOS and GOARCH of the application, as well as
other data related to the deployment environment.

## Prerequisites

Before beginning, clone this repository using `git`. Your system should also have `make` installed
if it does not come with your OS distribution.

### Building

- Install the [go SDK](https://go.dev/) v1.21 or higher.
- Install [ko](https://ko.build) or a container engine like [Docker](https://www.docker.com) or
  [Podman](https://podman.io).
- Push permissions to a container registry.

### Deploying

- Obtain access to a [Kubernetes](http://kubernetes.io) cluster. Locally, you can run
  [kind](https://kind.sigs.k8s.io/) or
  [OpenShift Local](https://developers.redhat.com/products/openshift-local/overview) on most 
  computers.
- Install [helm](https://helm.sh/).

## Try It Out!

- Run the server locally - execute the following in your terminal:
  ```sh
  make run
  ```
- Build and push the container image - _either_:
  - Use `ko` by running
    ```sh
    make ko-build IMAGE_TAG_BASE=<Insert your image repo>
    ```
  - **OR** use your favorite container engine and run:
    ```sh
    make docker-build CONTAINER_TOOL=<docker | podman> IMAGE_TAG_BASE-<Insert your image repo>
    ```
- Deploy the image on Kubernetes by running:
  ```sh
  make install IMAGE_TAG_BASE=<Insert your image repo>
  ```

## Make It Your Own!

- **Build**: Review the variables in the "Build" section of the [Makefile](./Makefile).
- **Deploy**: Review the defaults in [values.yaml](./helm/sample-go-multiarch/values.yaml). Provide
  your own overrides by pointing the `HELM_VALUES` make variable to your Helm values file.

## License

Licensed under the MIT License, Copyright 2024 Adam B Kaplan.
Full license here: [LICENSE](./LICENSE)
