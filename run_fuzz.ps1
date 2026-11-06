# Script to launch Docker fuzzing container
# Mounts the current libjpeg directory into /workspace

$WORKSPACE = $PSScriptRoot
Write-Host "[*] Starting libjpeg-turbo fuzzing environment..."
Write-Host "    Workspace: $WORKSPACE"

docker run --cap-add=SYS_PTRACE -it --rm `
    -v "${WORKSPACE}:/workspace" `
    -w /workspace `
    libjpeg-turbo-fuzz:latest /bin/bash
