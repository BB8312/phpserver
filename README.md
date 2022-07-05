# phpserver
This repo contains workflow to generate docker image for TestLink with MariaDB inside.
Also optional software Linfo and phpMyAdmin included.

## Versioning
Core versions of MariaDB, PHP and Alpine Linux are defined in Dockerfile.
Versions of other software are set in "ep.sh" script and can be changed by your choise,
with mention of appropriate docker image tag in "doc_stab.yaml" workflow to publish in Docker Hub.

## Installation
Kubernetes manifests for installation are located in "manifests" directory and validated by Kubeval.
Files named "in_..." intended for clean installation, "up_..." for version upgrade, and "re_..."
for restore appropriate version of software, along with common backup_fs and restore_fs operations.
Installation, upgrade and restore yaml files differs only by Docker image version used and some
lifecycle - postStart commands (DB initialization or schema update, config files write, etc).
Clear_fs used only before clean installation, and storage.yaml applied once to provide NFS access.
Jenkins pipeline files are located in "jenkinsfiles" directory. They are used to apply kubernetes
manifests in Jenkins GUI, to show time taken by installation and to notify there about readiness of
TestLink Web UI, which means successfull apply.

## Latest versions
Approved versions of TestLink: 1.9.18, 1.9.19.
If you want to install TestLink version 1.9.20 dev, it is recommended to do it in clean environment,
without old data and db configuration, because of major changes in database structure.
Image with version 1.9.18 contains old versions of Linfo and phpMyAdmin for some rare reasons.
