# Docker Support

This is initial support of docker, which is not like typical docker image because
all environment setup is wrapped in lkp install instead of Dockerfile.

The main limitation is the installed dependencies of test are not persistent. User may
consider to create image for interested test for easy reuse.

## Getting started

```bash
git clone https://github.com/intel/lkp-tests.git

cd lkp-tests
make install

image=debian/buster
hostname=lkp-docker.${image//\//.}

lkp docker build --image $image --hostname $hostname

docker run --rm --entrypoint '' lkp-tests/${image} lkp help
```

## Run one atomic job

Kindly note that
* All installed dependencies are inside container and not persistent.
* The jobs and benchmarks are persistent, thus this can be run directly in a new container. It does not work for all tests, so that lkp install need rerun.

```bash
# Add --privileged option to allow privileged access like dmesg, sysctl. Use
# this with caution.
lkp docker test -i $image -j hackbench.yaml -g pipe-8-process-1600 --hostname $hostname

lkp docker rt --container $hostname --options "hackbench"
```

## More Examples of lkp docker Usage

```bash
# The flag --any can be set to let lkp randomly choose a job from the suite
lkp docker test -i $image -j hackbench.yaml --any --hostname $hostname

# Attach to a running container
lkp docker attach --container $hostname
```

## Test by lkp docker

```bash
image=debian/bookworm
hostname=lkp-docker.${image//\//.}

lkp docker init -i $image --hostname $hostname

lkp docker build -t $hostname
lkp docker test -t $hostname -j hackbench.yaml -g pipe-8-process-1600
```
