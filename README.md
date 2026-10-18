# Отчет:

## Ссылка на Docker Hub: https://hub.docker.com/r/volodyapr/image-lab/tags

## docker history

Вывод: docker history volodyapr/image-lab:dc6a169b

```text
IMAGE          CREATED         CREATED BY                                      SIZE      COMMENT
c4f228f65413   5 minutes ago   CMD ["python" "-m" "app.app"]                   0B        buildkit.dockerfile.v0
<missing>      5 minutes ago   HEALTHCHECK &{["CMD-SHELL" "python -c \"impo…   0B        buildkit.dockerfile.v0
<missing>      5 minutes ago   USER nuser                                      0B        buildkit.dockerfile.v0
<missing>      5 minutes ago   COPY --chown=nuser:nuser app ./app # buildkit   16.4kB    buildkit.dockerfile.v0
<missing>      5 minutes ago   COPY /opt/venv /opt/venv # buildkit             19.1MB    buildkit.dockerfile.v0
<missing>      5 minutes ago   RUN |2 LAB_LOGIN=volodyapr LAB_TOKEN=dc6a169…   49.2kB    buildkit.dockerfile.v0
<missing>      5 minutes ago   ENV PATH=/opt/venv/bin:/usr/local/bin:/usr/l…   0B        buildkit.dockerfile.v0
<missing>      5 minutes ago   LABEL org.lab.login=volodyapr org.lab.token=…   0B        buildkit.dockerfile.v0
<missing>      5 minutes ago   ARG LAB_TOKEN=dc6a169bac9787eb57748111fc3121…   0B        buildkit.dockerfile.v0
<missing>      5 minutes ago   ARG LAB_LOGIN=volodyapr                         0B        buildkit.dockerfile.v0
<missing>      5 minutes ago   WORKDIR /app                                    8.19kB    buildkit.dockerfile.v0
<missing>      12 days ago     CMD ["python3"]                                 0B        buildkit.dockerfile.v0
<missing>      12 days ago     RUN /bin/sh -c set -eux;  for src in idle3 p…   16.4kB    buildkit.dockerfile.v0
<missing>      12 days ago     RUN /bin/sh -c set -eux;   savedAptMark="$(a…   41.4MB    buildkit.dockerfile.v0
<missing>      12 days ago     ENV PYTHON_SHA256=c2c4321961fab0fb999d66e0ce…   0B        buildkit.dockerfile.v0
<missing>      12 days ago     ENV PYTHON_VERSION=3.12.15                      0B        buildkit.dockerfile.v0
<missing>      12 days ago     ENV GPG_KEY=7169605F62C751356D054A26A821E680…   0B        buildkit.dockerfile.v0
<missing>      12 days ago     RUN /bin/sh -c set -eux;  apt-get update;  a…   4.94MB    buildkit.dockerfile.v0
<missing>      12 days ago     ENV LANG=C.UTF-8                                0B        buildkit.dockerfile.v0
<missing>      12 days ago     ENV PATH=/usr/local/bin:/usr/local/sbin:/usr…   0B        buildkit.dockerfile.v0
<missing>      13 days ago     # debian.sh --arch 'amd64' out/ 'trixie' '@1…   87.7MB    debuerreotype 0.17
```

