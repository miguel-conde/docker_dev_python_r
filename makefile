# Makefile para construir la imagen Docker de desarrollo

IMAGE_NAME := dev_python_r
TAG := latest
DOCKERFILE := Dockerfile
CONTEXT := .

# Nombre e imagen del entorno
CONTAINER_NAME := dev_container
PROJECT_DIR := /home/usuario/mi_proyecto
WORKSPACE := /workspace

# Construye la imagen Docker
.PHONY: build
build:
	docker build -t $(IMAGE_NAME):$(TAG) -f $(DOCKERFILE) $(CONTEXT)

# Lanza el contenedor con volumen montado
.PHONY: run
run:
	docker run -dit \
		--name $(CONTAINER_NAME) \
		-v $(PROJECT_DIR):$(WORKSPACE) \
		-w $(WORKSPACE) \
		$(IMAGE_NAME):$(TAG) \
		bash

# Conecta VSCode al contenedor (requiere extensión Remote - Containers)
.PHONY: attach
attach:
	code --remote-container $(CONTAINER_NAME)

# Elimina el contenedor (por si quieres reiniciar)
.PHONY: clean
clean:
	-docker rm -f $(CONTAINER_NAME)

# Reconstruye imagen y reinicia contenedor
.PHONY: rebuild
rebuild: clean build run
