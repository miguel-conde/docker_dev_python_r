#!/bin/bash

# --- Entrypoint personalizado para contenedor de desarrollo ---

# Arreglar permisos del directorio montado si es necesario
if [ -d /workspaces ]; then
    echo "[entrypoint] Ajustando permisos en /workspaces..."
    chown -R devuser:devuser /workspaces 2>/dev/null || echo "[entrypoint] No se pudo cambiar permisos (puede que no seas root)"
fi

# Ejecutar el comando que haya venido en CMD
exec "$@"
