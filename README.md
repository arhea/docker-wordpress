# Wordpress on Docker

This repository shows how to run Wordpress on Docker while keeping the PHP code, plugins, and themes within source control. This has advantages to running Wordpress out of a shared file system. This enables Wordpress, Custom Code, and the PHP configuration to be tested a single unit prior deploying to production. This does have limitations which is documented below.

*Note: This repository is meant to be an example and should not be used in production without testing your application against this configuration.*

## Limitations
- Wordpress Core, Plugins, and Themes must be updated via the Docker build process and not in the Wordpress Admin. Doing so will result in containers having different versions of plugins.
- This assumes all dynamic content is stored int he `wp-content/uploads` folder

## Getting Started

This repo shows how you can build the container using arbitrary versions of Wordpress. This functionality is defined using `make`. The `IMAGE_NAME`, `IMAGE_TAG`, `WORDPRESS_VERSION`, and `WORDPRESS_SHA1` can be overridden with custom values.

```bash
# this will use the default version of Wordpress defined in the Makefile
make build

# define a custom version of Wordpress, these can be found https://wordpress.org/download/releases/
make WORDPRESS_VERSION=5.2.5 WORDPRESS_SHA1=1afb2e9a10be336773a62a120bb4cfb44214dfcc build
```

## Deployment

This container is designed to be deployed to multiple orchestration systems such as Amazon ECS or Kubernetes. The container has one requirement for storage to mounted at `/var/www/html/wp-content/uploads`. This is so that when users upload images they will be persisted and can be shared across containers. I recommend using a NFS based volume such as Amazon EFS.

### Kubernetes on Amazon EKS

This file shows you how to deploy this container to Amazon EKS. You will need the following controllers installed on your cluster:

- [ALB Ingress Controller](https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html) - This will enable the `Ingress` resource to provision a Application Load Balancer
- [EFS Container Storage Interface Driver](https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html) - This will enable EKS to mount EFS File Systems to the container

Before getting started, deploy a cluster to AWS, provision a RDS database, and create an EFS File System with mount points in each AZ.

Next, go to the `examples/kubernetes.yml` file and update the `PersistentVolume` configuration with the ID of the EFS File System you created.

Next create a secret for all of the Wordpress Salts (These can be [genereated here](https://api.wordpress.org/secret-key/1.1/salt/)). These will enable all instances of our pods to encrypt and decrypt the session.

```bash
kubectl create secret generic wordpress-salts \
    --from-literal=auth_key="" \
    --from-literal=secure_auth_key="" \
    --from-literal=logged_in_key="" \
    --from-literal=nonce_key="" \
    --from-literal=auth_salt="" \
    --from-literal=secure_auth_salt="" \
    --from-literal=logged_in_salt="" \
    --from-literal=nonce_salt="
```

Then we need to create another secret for our Wordpress Database configuration.

```bash
kubectl create secret generic wordpress-db \
  --from-literal=host="" \
  --from-literal=name="" \
  --from-literal=username="" \
  --from-literal=password=""
```

Then finally,

```bash
kubectl apply -f examples/kubernetes.yml
```

If you wish to configure a TLS Certificate you can add an annotation to this example. The additional annotations are documented on the [ALB Ingress docs](https://kubernetes-sigs.github.io/aws-alb-ingress-controller/guide/ingress/annotation/).

### Docker Compose

This file is an exmaple that you can run locally and shows how to deploy Wordpress using Docker Compose. This requires that you have Docker Desktop installed. The container build is defined in the Docker Compose for usability purposes.

*Note: The first time you boot the database it will take time to initialize. Wordpress will keep restarting until the database is available.*

```bash

# start wordpress, the site will be available at http://localhost:8080
docker-compose -f ./examples/docker-compose.yml -p wordpress up

# tear the application down
docker-compose -f ./examples/docker-compose.yml -p wordpress down

```
