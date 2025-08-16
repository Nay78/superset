# Auto-generated using compose2nix v0.3.2-pre.
{
  pkgs,
  lib,
  config,
  ...
}:

{
  # Runtime
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
  };

  # Enable container name DNS for all Podman networks.
  networking.firewall.interfaces =
    let
      matchAll = if !config.networking.nftables.enable then "podman+" else "podman*";
    in
    {
      "${matchAll}".allowedUDPPorts = [ 53 ];
    };

  virtualisation.oci-containers.backend = "podman";

  # Containers
  virtualisation.oci-containers.containers."superset_app" = {
    image = "localhost/compose2nix/superset_app";
    environment = {
      "BUILD_SUPERSET_FRONTEND_IN_DOCKER" = "true";
      "COMPOSE_PROJECT_NAME" = "superset";
      "CYPRESS_CONFIG" = "false";
      "DATABASE_DB" = "superset";
      "DATABASE_DIALECT" = "postgresql";
      "DATABASE_HOST" = "db";
      "DATABASE_PASSWORD" = "superset";
      "DATABASE_PORT" = "5432";
      "DATABASE_USER" = "superset";
      "DEV_MODE" = "true";
      "ENABLE_PLAYWRIGHT" = "false";
      "EXAMPLES_DB" = "examples";
      "EXAMPLES_HOST" = "db";
      "EXAMPLES_PASSWORD" = "examples";
      "EXAMPLES_PORT" = "5432";
      "EXAMPLES_USER" = "examples";
      "FLASK_DEBUG" = "true";
      "MAPBOX_API_KEY" = "";
      "POSTGRES_DB" = "superset";
      "POSTGRES_PASSWORD" = "superset";
      "POSTGRES_USER" = "superset";
      "PUPPETEER_SKIP_CHROMIUM_DOWNLOAD" = "true";
      "PYTHONPATH" = "/app/pythonpath:/app/docker/pythonpath_dev";
      "PYTHONUNBUFFERED" = "1";
      "REDIS_HOST" = "redis";
      "REDIS_PORT" = "6379";
      "SUPERSET_APP_ROOT" = "/";
      "SUPERSET_ENV" = "development";
      "SUPERSET_LOAD_EXAMPLES" = "yes";
      "SUPERSET_LOG_LEVEL" = "info";
      "SUPERSET_PORT" = "8088";
      "SUPERSET_SECRET_KEY" = "TEST_NON_DEV_SECRET";
    };
    volumes = [
      "/home/alejg/nixos/misc/superset/docker:/app/docker:rw"
      "/home/alejg/nixos/misc/superset/superset:/app/superset:rw"
      "/home/alejg/nixos/misc/superset/superset-frontend:/app/superset-frontend:rw"
      "/home/alejg/nixos/misc/superset/tests:/app/tests:rw"
      "superset_superset_home:/app/superset_home:rw"
    ];
    ports = [
      "8088:8088/tcp"
      "8081:8081/tcp"
    ];
    cmd = [
      "/app/docker/docker-bootstrap.sh"
      "app"
    ];
    dependsOn = [
      "superset_init"
    ];
    user = "root";
    log-driver = "journald";
    extraOptions = [
      "--add-host=host.docker.internal:host-gateway"
      "--network-alias=superset"
      "--network=superset_default"
    ];
  };
  systemd.services."podman-superset_app" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-superset_default.service"
      "podman-volume-superset_superset_home.service"
    ];
    requires = [
      "podman-network-superset_default.service"
      "podman-volume-superset_superset_home.service"
    ];
    partOf = [
      "podman-compose-superset-root.target"
    ];
    wantedBy = [
      "podman-compose-superset-root.target"
    ];
  };
  virtualisation.oci-containers.containers."superset_cache" = {
    image = "redis:7";
    volumes = [
      "superset_redis:/data:rw"
    ];
    ports = [
      "127.0.0.1:6379:6379/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=redis"
      "--network=superset_default"
    ];
  };
  systemd.services."podman-superset_cache" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-superset_default.service"
      "podman-volume-superset_redis.service"
    ];
    requires = [
      "podman-network-superset_default.service"
      "podman-volume-superset_redis.service"
    ];
    partOf = [
      "podman-compose-superset-root.target"
    ];
    wantedBy = [
      "podman-compose-superset-root.target"
    ];
  };
  virtualisation.oci-containers.containers."superset_db" = {
    image = "postgres:16";
    environment = {
      "BUILD_SUPERSET_FRONTEND_IN_DOCKER" = "true";
      "COMPOSE_PROJECT_NAME" = "superset";
      "CYPRESS_CONFIG" = "false";
      "DATABASE_DB" = "superset";
      "DATABASE_DIALECT" = "postgresql";
      "DATABASE_HOST" = "db";
      "DATABASE_PASSWORD" = "superset";
      "DATABASE_PORT" = "5432";
      "DATABASE_USER" = "superset";
      "DEV_MODE" = "true";
      "ENABLE_PLAYWRIGHT" = "false";
      "EXAMPLES_DB" = "examples";
      "EXAMPLES_HOST" = "db";
      "EXAMPLES_PASSWORD" = "examples";
      "EXAMPLES_PORT" = "5432";
      "EXAMPLES_USER" = "examples";
      "FLASK_DEBUG" = "true";
      "MAPBOX_API_KEY" = "";
      "POSTGRES_DB" = "superset";
      "POSTGRES_PASSWORD" = "superset";
      "POSTGRES_USER" = "superset";
      "PUPPETEER_SKIP_CHROMIUM_DOWNLOAD" = "true";
      "PYTHONPATH" = "/app/pythonpath:/app/docker/pythonpath_dev";
      "PYTHONUNBUFFERED" = "1";
      "REDIS_HOST" = "redis";
      "REDIS_PORT" = "6379";
      "SUPERSET_APP_ROOT" = "/";
      "SUPERSET_ENV" = "development";
      "SUPERSET_LOAD_EXAMPLES" = "yes";
      "SUPERSET_LOG_LEVEL" = "info";
      "SUPERSET_PORT" = "8088";
      "SUPERSET_SECRET_KEY" = "TEST_NON_DEV_SECRET";
    };
    volumes = [
      "/home/alejg/nixos/misc/superset/docker/docker-entrypoint-initdb.d:/docker-entrypoint-initdb.d:rw"
      "superset_db_home:/var/lib/postgresql/data:rw"
    ];
    ports = [
      "127.0.0.1:5432:5432/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=db"
      "--network=superset_default"
    ];
  };
  systemd.services."podman-superset_db" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-superset_default.service"
      "podman-volume-superset_db_home.service"
    ];
    requires = [
      "podman-network-superset_default.service"
      "podman-volume-superset_db_home.service"
    ];
    partOf = [
      "podman-compose-superset-root.target"
    ];
    wantedBy = [
      "podman-compose-superset-root.target"
    ];
  };
  virtualisation.oci-containers.containers."superset_init" = {
    image = "localhost/compose2nix/superset_init";
    environment = {
      "BUILD_SUPERSET_FRONTEND_IN_DOCKER" = "true";
      "COMPOSE_PROJECT_NAME" = "superset";
      "CYPRESS_CONFIG" = "false";
      "DATABASE_DB" = "superset";
      "DATABASE_DIALECT" = "postgresql";
      "DATABASE_HOST" = "db";
      "DATABASE_PASSWORD" = "superset";
      "DATABASE_PORT" = "5432";
      "DATABASE_USER" = "superset";
      "DEV_MODE" = "true";
      "ENABLE_PLAYWRIGHT" = "false";
      "EXAMPLES_DB" = "examples";
      "EXAMPLES_HOST" = "db";
      "EXAMPLES_PASSWORD" = "examples";
      "EXAMPLES_PORT" = "5432";
      "EXAMPLES_USER" = "examples";
      "FLASK_DEBUG" = "true";
      "MAPBOX_API_KEY" = "";
      "POSTGRES_DB" = "superset";
      "POSTGRES_PASSWORD" = "superset";
      "POSTGRES_USER" = "superset";
      "PUPPETEER_SKIP_CHROMIUM_DOWNLOAD" = "true";
      "PYTHONPATH" = "/app/pythonpath:/app/docker/pythonpath_dev";
      "PYTHONUNBUFFERED" = "1";
      "REDIS_HOST" = "redis";
      "REDIS_PORT" = "6379";
      "SUPERSET_APP_ROOT" = "/";
      "SUPERSET_ENV" = "development";
      "SUPERSET_LOAD_EXAMPLES" = "yes";
      "SUPERSET_LOG_LEVEL" = "info";
      "SUPERSET_PORT" = "8088";
      "SUPERSET_SECRET_KEY" = "TEST_NON_DEV_SECRET";
    };
    volumes = [
      "/home/alejg/nixos/misc/superset/docker:/app/docker:rw"
      "/home/alejg/nixos/misc/superset/superset:/app/superset:rw"
      "/home/alejg/nixos/misc/superset/superset-frontend:/app/superset-frontend:rw"
      "/home/alejg/nixos/misc/superset/tests:/app/tests:rw"
      "superset_superset_home:/app/superset_home:rw"
    ];
    cmd = [ "/app/docker/docker-init.sh" ];
    dependsOn = [
      "superset_cache"
      "superset_db"
    ];
    user = "root";
    log-driver = "journald";
    extraOptions = [
      "--network-alias=superset-init"
      "--network=superset_default"
      "--no-healthcheck"
    ];
  };
  systemd.services."podman-superset_init" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "podman-network-superset_default.service"
      "podman-volume-superset_superset_home.service"
    ];
    requires = [
      "podman-network-superset_default.service"
      "podman-volume-superset_superset_home.service"
    ];
    partOf = [
      "podman-compose-superset-root.target"
    ];
    wantedBy = [
      "podman-compose-superset-root.target"
    ];
  };
  virtualisation.oci-containers.containers."superset_nginx" = {
    image = "nginx:latest";
    environment = {
      "BUILD_SUPERSET_FRONTEND_IN_DOCKER" = "true";
      "COMPOSE_PROJECT_NAME" = "superset";
      "CYPRESS_CONFIG" = "false";
      "DATABASE_DB" = "superset";
      "DATABASE_DIALECT" = "postgresql";
      "DATABASE_HOST" = "db";
      "DATABASE_PASSWORD" = "superset";
      "DATABASE_PORT" = "5432";
      "DATABASE_USER" = "superset";
      "DEV_MODE" = "true";
      "ENABLE_PLAYWRIGHT" = "false";
      "EXAMPLES_DB" = "examples";
      "EXAMPLES_HOST" = "db";
      "EXAMPLES_PASSWORD" = "examples";
      "EXAMPLES_PORT" = "5432";
      "EXAMPLES_USER" = "examples";
      "FLASK_DEBUG" = "true";
      "MAPBOX_API_KEY" = "";
      "POSTGRES_DB" = "superset";
      "POSTGRES_PASSWORD" = "superset";
      "POSTGRES_USER" = "superset";
      "PUPPETEER_SKIP_CHROMIUM_DOWNLOAD" = "true";
      "PYTHONPATH" = "/app/pythonpath:/app/docker/pythonpath_dev";
      "PYTHONUNBUFFERED" = "1";
      "REDIS_HOST" = "redis";
      "REDIS_PORT" = "6379";
      "SUPERSET_APP_ROOT" = "/";
      "SUPERSET_ENV" = "development";
      "SUPERSET_LOAD_EXAMPLES" = "yes";
      "SUPERSET_LOG_LEVEL" = "info";
      "SUPERSET_PORT" = "8088";
      "SUPERSET_SECRET_KEY" = "TEST_NON_DEV_SECRET";
    };
    volumes = [
      "/home/alejg/nixos/misc/superset/docker/nginx/nginx.conf:/etc/nginx/nginx.conf:ro"
      "/home/alejg/nixos/misc/superset/docker/nginx/templates:/etc/nginx/templates:ro"
    ];
    ports = [
      "80:80/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--add-host=host.docker.internal:host-gateway"
      "--network-alias=nginx"
      "--network=superset_default"
    ];
  };
  systemd.services."podman-superset_nginx" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-superset_default.service"
    ];
    requires = [
      "podman-network-superset_default.service"
    ];
    partOf = [
      "podman-compose-superset-root.target"
    ];
    wantedBy = [
      "podman-compose-superset-root.target"
    ];
  };
  virtualisation.oci-containers.containers."superset_node" = {
    image = "localhost/compose2nix/superset_node";
    environment = {
      "BUILD_SUPERSET_FRONTEND_IN_DOCKER" = "true";
      "COMPOSE_PROJECT_NAME" = "superset";
      "CYPRESS_CONFIG" = "false";
      "DATABASE_DB" = "superset";
      "DATABASE_DIALECT" = "postgresql";
      "DATABASE_HOST" = "db";
      "DATABASE_PASSWORD" = "superset";
      "DATABASE_PORT" = "5432";
      "DATABASE_USER" = "superset";
      "DEV_MODE" = "true";
      "ENABLE_PLAYWRIGHT" = "false";
      "EXAMPLES_DB" = "examples";
      "EXAMPLES_HOST" = "db";
      "EXAMPLES_PASSWORD" = "examples";
      "EXAMPLES_PORT" = "5432";
      "EXAMPLES_USER" = "examples";
      "FLASK_DEBUG" = "true";
      "MAPBOX_API_KEY" = "";
      "NPM_RUN_PRUNE" = "false";
      "POSTGRES_DB" = "superset";
      "POSTGRES_PASSWORD" = "superset";
      "POSTGRES_USER" = "superset";
      "PUPPETEER_SKIP_CHROMIUM_DOWNLOAD" = "true";
      "PYTHONPATH" = "/app/pythonpath:/app/docker/pythonpath_dev";
      "PYTHONUNBUFFERED" = "1";
      "REDIS_HOST" = "redis";
      "REDIS_PORT" = "6379";
      "SCARF_ANALYTICS" = "";
      "SUPERSET_APP_ROOT" = "/";
      "SUPERSET_ENV" = "development";
      "SUPERSET_LOAD_EXAMPLES" = "yes";
      "SUPERSET_LOG_LEVEL" = "info";
      "SUPERSET_PORT" = "8088";
      "SUPERSET_SECRET_KEY" = "TEST_NON_DEV_SECRET";
      "superset" = "http://superset:8088";
    };
    volumes = [
      "/home/alejg/nixos/misc/superset/docker:/app/docker:rw"
      "/home/alejg/nixos/misc/superset/superset:/app/superset:rw"
      "/home/alejg/nixos/misc/superset/superset-frontend:/app/superset-frontend:rw"
      "/home/alejg/nixos/misc/superset/tests:/app/tests:rw"
      "superset_superset_home:/app/superset_home:rw"
    ];
    ports = [
      "127.0.0.1:9000:9000/tcp"
    ];
    cmd = [ "/app/docker/docker-frontend.sh" ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=superset-node"
      "--network=superset_default"
    ];
  };
  systemd.services."podman-superset_node" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "podman-network-superset_default.service"
      "podman-volume-superset_superset_home.service"
    ];
    requires = [
      "podman-network-superset_default.service"
      "podman-volume-superset_superset_home.service"
    ];
    partOf = [
      "podman-compose-superset-root.target"
    ];
    wantedBy = [
      "podman-compose-superset-root.target"
    ];
  };
  virtualisation.oci-containers.containers."superset_websocket" = {
    image = "localhost/compose2nix/superset_websocket";
    environment = {
      "PORT" = "8080";
      "REDIS_HOST" = "redis";
      "REDIS_PORT" = "6379";
      "REDIS_SSL" = "false";
    };
    volumes = [
      ":/home/superset-websocket/dist:rw"
      "/home/alejg/nixos/misc/superset/docker/superset-websocket/config.json:/home/superset-websocket/config.json:rw"
      "/home/alejg/nixos/misc/superset/superset-websocket:/home/superset-websocket:rw"
    ];
    ports = [
      "8080:8080/tcp"
    ];
    dependsOn = [
      "superset_cache"
    ];
    log-driver = "journald";
    extraOptions = [
      "--add-host=host.docker.internal:host-gateway"
      "--network-alias=superset-websocket"
      "--network=superset_default"
    ];
  };
  systemd.services."podman-superset_websocket" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "podman-network-superset_default.service"
    ];
    requires = [
      "podman-network-superset_default.service"
    ];
    partOf = [
      "podman-compose-superset-root.target"
    ];
    wantedBy = [
      "podman-compose-superset-root.target"
    ];
  };
  virtualisation.oci-containers.containers."superset_worker" = {
    image = "localhost/compose2nix/superset_worker";
    environment = {
      "BUILD_SUPERSET_FRONTEND_IN_DOCKER" = "true";
      "CELERYD_CONCURRENCY" = "2";
      "COMPOSE_PROJECT_NAME" = "superset";
      "CYPRESS_CONFIG" = "false";
      "DATABASE_DB" = "superset";
      "DATABASE_DIALECT" = "postgresql";
      "DATABASE_HOST" = "db";
      "DATABASE_PASSWORD" = "superset";
      "DATABASE_PORT" = "5432";
      "DATABASE_USER" = "superset";
      "DEV_MODE" = "true";
      "ENABLE_PLAYWRIGHT" = "false";
      "EXAMPLES_DB" = "examples";
      "EXAMPLES_HOST" = "db";
      "EXAMPLES_PASSWORD" = "examples";
      "EXAMPLES_PORT" = "5432";
      "EXAMPLES_USER" = "examples";
      "FLASK_DEBUG" = "true";
      "MAPBOX_API_KEY" = "";
      "POSTGRES_DB" = "superset";
      "POSTGRES_PASSWORD" = "superset";
      "POSTGRES_USER" = "superset";
      "PUPPETEER_SKIP_CHROMIUM_DOWNLOAD" = "true";
      "PYTHONPATH" = "/app/pythonpath:/app/docker/pythonpath_dev";
      "PYTHONUNBUFFERED" = "1";
      "REDIS_HOST" = "redis";
      "REDIS_PORT" = "6379";
      "SUPERSET_APP_ROOT" = "/";
      "SUPERSET_ENV" = "development";
      "SUPERSET_LOAD_EXAMPLES" = "yes";
      "SUPERSET_LOG_LEVEL" = "info";
      "SUPERSET_PORT" = "8088";
      "SUPERSET_SECRET_KEY" = "TEST_NON_DEV_SECRET";
    };
    volumes = [
      "/home/alejg/nixos/misc/superset/docker:/app/docker:rw"
      "/home/alejg/nixos/misc/superset/superset:/app/superset:rw"
      "/home/alejg/nixos/misc/superset/superset-frontend:/app/superset-frontend:rw"
      "/home/alejg/nixos/misc/superset/tests:/app/tests:rw"
      "superset_superset_home:/app/superset_home:rw"
    ];
    cmd = [
      "/app/docker/docker-bootstrap.sh"
      "worker"
    ];
    dependsOn = [
      "superset_init"
    ];
    user = "root";
    log-driver = "journald";
    extraOptions = [
      "--add-host=host.docker.internal:host-gateway"
      "--health-cmd=celery -A superset.tasks.celery_app:app inspect ping -d celery@$HOSTNAME"
      "--network-alias=superset-worker"
      "--network=superset_default"
    ];
  };
  systemd.services."podman-superset_worker" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-superset_default.service"
      "podman-volume-superset_superset_home.service"
    ];
    requires = [
      "podman-network-superset_default.service"
      "podman-volume-superset_superset_home.service"
    ];
    partOf = [
      "podman-compose-superset-root.target"
    ];
    wantedBy = [
      "podman-compose-superset-root.target"
    ];
  };
  virtualisation.oci-containers.containers."superset_worker_beat" = {
    image = "localhost/compose2nix/superset_worker_beat";
    environment = {
      "BUILD_SUPERSET_FRONTEND_IN_DOCKER" = "true";
      "COMPOSE_PROJECT_NAME" = "superset";
      "CYPRESS_CONFIG" = "false";
      "DATABASE_DB" = "superset";
      "DATABASE_DIALECT" = "postgresql";
      "DATABASE_HOST" = "db";
      "DATABASE_PASSWORD" = "superset";
      "DATABASE_PORT" = "5432";
      "DATABASE_USER" = "superset";
      "DEV_MODE" = "true";
      "ENABLE_PLAYWRIGHT" = "false";
      "EXAMPLES_DB" = "examples";
      "EXAMPLES_HOST" = "db";
      "EXAMPLES_PASSWORD" = "examples";
      "EXAMPLES_PORT" = "5432";
      "EXAMPLES_USER" = "examples";
      "FLASK_DEBUG" = "true";
      "MAPBOX_API_KEY" = "";
      "POSTGRES_DB" = "superset";
      "POSTGRES_PASSWORD" = "superset";
      "POSTGRES_USER" = "superset";
      "PUPPETEER_SKIP_CHROMIUM_DOWNLOAD" = "true";
      "PYTHONPATH" = "/app/pythonpath:/app/docker/pythonpath_dev";
      "PYTHONUNBUFFERED" = "1";
      "REDIS_HOST" = "redis";
      "REDIS_PORT" = "6379";
      "SUPERSET_APP_ROOT" = "/";
      "SUPERSET_ENV" = "development";
      "SUPERSET_LOAD_EXAMPLES" = "yes";
      "SUPERSET_LOG_LEVEL" = "info";
      "SUPERSET_PORT" = "8088";
      "SUPERSET_SECRET_KEY" = "TEST_NON_DEV_SECRET";
    };
    volumes = [
      "/home/alejg/nixos/misc/superset/docker:/app/docker:rw"
      "/home/alejg/nixos/misc/superset/superset:/app/superset:rw"
      "/home/alejg/nixos/misc/superset/superset-frontend:/app/superset-frontend:rw"
      "/home/alejg/nixos/misc/superset/tests:/app/tests:rw"
      "superset_superset_home:/app/superset_home:rw"
    ];
    cmd = [
      "/app/docker/docker-bootstrap.sh"
      "beat"
    ];
    dependsOn = [
      "superset_worker"
    ];
    user = "root";
    log-driver = "journald";
    extraOptions = [
      "--network-alias=superset-worker-beat"
      "--network=superset_default"
      "--no-healthcheck"
    ];
  };
  systemd.services."podman-superset_worker_beat" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-superset_default.service"
      "podman-volume-superset_superset_home.service"
    ];
    requires = [
      "podman-network-superset_default.service"
      "podman-volume-superset_superset_home.service"
    ];
    partOf = [
      "podman-compose-superset-root.target"
    ];
    wantedBy = [
      "podman-compose-superset-root.target"
    ];
  };

  # Networks
  systemd.services."podman-network-superset_default" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f superset_default";
    };
    script = ''
      podman network inspect superset_default || podman network create superset_default
    '';
    partOf = [ "podman-compose-superset-root.target" ];
    wantedBy = [ "podman-compose-superset-root.target" ];
  };

  # Volumes
  systemd.services."podman-volume-superset_db_home" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect superset_db_home || podman volume create superset_db_home
    '';
    partOf = [ "podman-compose-superset-root.target" ];
    wantedBy = [ "podman-compose-superset-root.target" ];
  };
  systemd.services."podman-volume-superset_redis" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect superset_redis || podman volume create superset_redis
    '';
    partOf = [ "podman-compose-superset-root.target" ];
    wantedBy = [ "podman-compose-superset-root.target" ];
  };
  systemd.services."podman-volume-superset_superset_home" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect superset_superset_home || podman volume create superset_superset_home
    '';
    partOf = [ "podman-compose-superset-root.target" ];
    wantedBy = [ "podman-compose-superset-root.target" ];
  };

  # Builds
  systemd.services."podman-build-superset_app" = {
    path = [
      pkgs.podman
      pkgs.git
    ];
    serviceConfig = {
      Type = "oneshot";
      TimeoutSec = 300;
    };
    script = ''
      cd /home/alejg/nixos/misc/superset
      podman build -t compose2nix/superset_app --build-arg DEV_MODE=true --build-arg INCLUDE_CHROMIUM=false --build-arg INCLUDE_FIREFOX=false --build-arg BUILD_TRANSLATIONS=false .
    '';
  };
  systemd.services."podman-build-superset_init" = {
    path = [
      pkgs.podman
      pkgs.git
    ];
    serviceConfig = {
      Type = "oneshot";
      TimeoutSec = 300;
    };
    script = ''
      cd /home/alejg/nixos/misc/superset
      podman build -t compose2nix/superset_init --build-arg INCLUDE_FIREFOX=false --build-arg BUILD_TRANSLATIONS=false --build-arg DEV_MODE=true --build-arg INCLUDE_CHROMIUM=false .
    '';
  };
  systemd.services."podman-build-superset_node" = {
    path = [
      pkgs.podman
      pkgs.git
    ];
    serviceConfig = {
      Type = "oneshot";
      TimeoutSec = 300;
    };
    script = ''
      cd /home/alejg/nixos/misc/superset
      podman build -t compose2nix/superset_node --build-arg DEV_MODE=true --build-arg BUILD_TRANSLATIONS=false .
    '';
  };
  systemd.services."podman-build-superset_websocket" = {
    path = [
      pkgs.podman
      pkgs.git
    ];
    serviceConfig = {
      Type = "oneshot";
      TimeoutSec = 300;
    };
    script = ''
      cd /home/alejg/nixos/misc/superset/superset-websocket
      podman build -t compose2nix/superset_websocket .
    '';
  };
  systemd.services."podman-build-superset_worker" = {
    path = [
      pkgs.podman
      pkgs.git
    ];
    serviceConfig = {
      Type = "oneshot";
      TimeoutSec = 300;
    };
    script = ''
      cd /home/alejg/nixos/misc/superset
      podman build -t compose2nix/superset_worker --build-arg BUILD_TRANSLATIONS=false --build-arg DEV_MODE=true --build-arg INCLUDE_CHROMIUM=false --build-arg INCLUDE_FIREFOX=false .
    '';
  };
  systemd.services."podman-build-superset_worker_beat" = {
    path = [
      pkgs.podman
      pkgs.git
    ];
    serviceConfig = {
      Type = "oneshot";
      TimeoutSec = 300;
    };
    script = ''
      cd /home/alejg/nixos/misc/superset
      podman build -t compose2nix/superset_worker_beat --build-arg BUILD_TRANSLATIONS=false --build-arg DEV_MODE=true --build-arg INCLUDE_CHROMIUM=false --build-arg INCLUDE_FIREFOX=false .
    '';
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-superset-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
