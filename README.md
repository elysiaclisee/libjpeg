# libjpeg-turbo Project

Docker environment for fuzzing and reproducing vulnerabilities in `libjpeg-turbo`:
- **v2.0.90 (2.1 beta1)**: Vulnerable version containing CVE-2021-20205, CVE-2021-29390, and CVE-2021-46822.
- **v2.1.0**: Patched release.
- **Instrumentation**: Compiled with Clang + AddressSanitizer (`-fsanitize=address -g -O1 -DWITH_SIMD=0`).
- **Tools Included**: `zzuf`, `radamsa`, `valgrind`, `gdb`, `clang`, `cmake`.

---

## Quick Start

### 1. Build the Docker Image
```bash
docker build -t libjpeg-turbo-fuzz:latest .
```

### 2. Run the Container
Mount your current folder into `/workspace` so crashes and logs sync back to the host:

**Linux / macOS / PowerShell:**
```bash
docker run --cap-add=SYS_PTRACE -it --rm -v "${PWD}:/workspace" -w /workspace libjpeg-turbo-fuzz:latest /bin/bash
```

**Windows PowerShell (helper script):**
```powershell
.\run_fuzz.ps1
```

> **Note**: `--cap-add=SYS_PTRACE` gives AddressSanitizer (ASan) and GDB the required process tracing privileges inside the container.

---

## Binaries Location (Inside Container)

* **Vulnerable (2.0.90)**:
  * `/workspace/libjpeg-turbo-2.0.90/build-asan/cjpeg`
  * `/workspace/libjpeg-turbo-2.0.90/build-asan/djpeg`
* **Patched (2.1.0)**:
  * `/workspace/libjpeg-turbo-2.1.0/build-asan/cjpeg`
  * `/workspace/libjpeg-turbo-2.1.0/build-asan/djpeg`
