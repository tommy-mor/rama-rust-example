# rama-rust-example/cluster/Makefile
.PHONY: all download-rama download-zk setup-zk start-zk configure-rama start-conductor start-supervisor start clean help

# === Variables ===
RAMA_VERSION := 1.0.0
# Zookeeper Docker container name
ZK_CONTAINER_NAME := rama-zookeeper
ZK_IMAGE := zookeeper:3.8 # Specify the image to use

RAMA_ZIP_URL := "https://redplanetlabs.s3.us-west-2.amazonaws.com/rama/rama-${RAMA_VERSION}.zip"
RAMA_DIST_DIR := rama-dist
RAMA_ZIP := rama-$(RAMA_VERSION).zip
RAMA_SCRIPT := $(RAMA_DIST_DIR)/rama

RAMA_LOCAL_DATA := local-rama-data
RAMA_YAML := $(RAMA_DIST_DIR)/rama.yaml

all: start

# --- Download Dependencies ---
download-rama: $(RAMA_SCRIPT)

$(RAMA_SCRIPT): $(RAMA_ZIP)
	@echo "Unpacking Rama..."
	@unzip -q $(RAMA_ZIP) -d $(RAMA_DIST_DIR)_tmp
	@mv $(RAMA_DIST_DIR)_tmp/rama-$(RAMA_VERSION)/* $(RAMA_DIST_DIR)/
	@rmdir $(RAMA_DIST_DIR)_tmp/rama-$(RAMA_VERSION)
	@rmdir $(RAMA_DIST_DIR)_tmp
	@touch $(RAMA_SCRIPT) # Mark as created

$(RAMA_ZIP):
	@echo "Downloading Rama $(RAMA_VERSION)..."
	@curl -L -o $(RAMA_ZIP) $(RAMA_ZIP_URL)

# --- Zookeeper Setup & Control (Using Docker) ---
start-zk:
	@echo "Ensuring Zookeeper container ($(ZK_CONTAINER_NAME)) is running..."
	@-docker start $(ZK_CONTAINER_NAME) > /dev/null 2>&1 || \
	    (docker run --name $(ZK_CONTAINER_NAME) --restart always -p 2181:2181 -d $(ZK_IMAGE) && \
	     echo "Waiting for Zookeeper container to initialize..." && \
	     sleep 5) # Simple wait for ZK to likely be ready
	@echo "Checking Zookeeper connection..."
	@while ! nc -z localhost 2181; do \
		echo "Waiting for Zookeeper connection..."; \
		sleep 1; \
	done
	@echo "Zookeeper is ready on port 2181."

stop-zk:
	@echo "Stopping and removing Zookeeper container ($(ZK_CONTAINER_NAME))..."
	@-docker stop $(ZK_CONTAINER_NAME) > /dev/null 2>&1 || echo "Zookeeper container '$(ZK_CONTAINER_NAME)' not running."
	@-docker rm $(ZK_CONTAINER_NAME) > /dev/null 2>&1 || echo "Zookeeper container '$(ZK_CONTAINER_NAME)' not found."

# --- Rama Setup & Control ---
configure-rama: $(RAMA_YAML)

$(RAMA_YAML): download-rama
	@echo "Configuring Rama..."
	@mkdir -p $(RAMA_LOCAL_DATA)
	@echo "zookeeper.servers:" > $(RAMA_YAML)
	@echo "  - \"127.0.0.1\"" >> $(RAMA_YAML)
	@echo "local.dir: \"$(shell pwd)/$(RAMA_LOCAL_DATA)\"" >> $(RAMA_YAML)
	@echo "conductor.host: \"127.0.0.1\"" >> $(RAMA_YAML)

start-conductor: configure-rama start-zk
	@echo "Starting Rama Conductor..."
	@cd $(RAMA_DIST_DIR) && nohup ./rama conductor > conductor.log 2>&1 & echo $$! > ../conductor.pid
	@echo "Conductor logs in $(RAMA_DIST_DIR)/logs/conductor-*.log and stdout/stderr in $(RAMA_DIST_DIR)/conductor.log"
	@echo "Conductor PID: $$(cat conductor.pid)"

start-supervisor: configure-rama start-zk
	@echo "Starting Rama Supervisor..."
	@cd $(RAMA_DIST_DIR) && nohup ./rama supervisor > supervisor.log 2>&1 & echo $$! > ../supervisor.pid
	@echo "Supervisor logs in $(RAMA_DIST_DIR)/logs/supervisor-*.log and stdout/stderr in $(RAMA_DIST_DIR)/supervisor.log"
	@echo "Supervisor PID: $$(cat supervisor.pid)"

stop-conductor:
	@echo "Stopping Rama Conductor..."
	@-if [ -f conductor.pid ]; then \
		kill $$(cat conductor.pid) && rm conductor.pid; \
	else \
		echo "Conductor PID file not found."; \
	fi

stop-supervisor:
	@echo "Stopping Rama Supervisor..."
	@-if [ -f supervisor.pid ]; then \
		kill $$(cat supervisor.pid) && rm supervisor.pid; \
	else \
		echo "Supervisor PID file not found."; \
	fi

stop: stop-conductor stop-supervisor stop-zk

# --- Combined Targets ---
setup: download-rama configure-rama

start: start-zk start-conductor start-supervisor
	@echo "Rama cluster components started."
	@echo "View Cluster UI: http://localhost:8888 (might take a minute to initialize)"

# --- Cleanup ---
clean: stop
	@echo "Cleaning up..."
	@rm -f $(RAMA_ZIP)
	@rm -rf $(RAMA_DIST_DIR)
	@rm -rf $(RAMA_LOCAL_DATA)
	@rm -f conductor.pid supervisor.pid

# --- Help ---
help:
	@echo "Usage: make [target]"
	@echo "Targets:"
	@echo "  all (default):    Download Rama, configure Rama, start Zookeeper (Docker) and Rama (Conductor + Supervisor)."
	@echo "  download-rama:    Download Rama distribution."
	@echo "  start-zk:         Start Zookeeper container ($(ZK_CONTAINER_NAME))."
	@echo "  stop-zk:          Stop and remove Zookeeper container ($(ZK_CONTAINER_NAME))."
	@echo "  configure-rama:   Configure Rama yaml."
	@echo "  start-conductor:  Start Rama Conductor daemon."
	@echo "  stop-conductor:   Stop Rama Conductor daemon."
	@echo "  start-supervisor: Start Rama Supervisor daemon."
	@echo "  stop-supervisor:  Stop Rama Supervisor daemon."
	@echo "  setup:            Run Rama download and configuration steps."
	@echo "  start:            Start Zookeeper, Conductor, and Supervisor."
	@echo "  stop:             Stop Conductor, Supervisor, and Zookeeper."
	@echo "  clean:            Stop processes, remove Rama downloaded/generated files, and stop/remove Zookeeper container."
	@echo "  help:             Show this help message."