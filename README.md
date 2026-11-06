# libjpeg-turbo Fuzzing & Security Research Environment

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

---

## Example Usage

### Test Sample Seed
```bash
/workspace/libjpeg-turbo-2.0.90/build-asan/cjpeg -outfile /tmp/test.jpg /workspace/seeds/sample.gif
```

### Black-box Fuzzing with zzuf
```bash
zzuf -s 1:100000 -r 0.001:0.05 -c -q \
  /workspace/libjpeg-turbo-2.0.90/build-asan/cjpeg -outfile /dev/null /workspace/seeds/sample.gif
```

### Black-box Fuzzing with Radamsa
```bash
while true; do
  radamsa /workspace/seeds/sample.gif > /tmp/mutated.gif
  /workspace/libjpeg-turbo-2.0.90/build-asan/cjpeg -outfile /dev/null /tmp/mutated.gif 2>&1 | grep -E "AddressSanitizer|Floating point exception" && {
    echo "[!] Crash found!"
    cp /tmp/mutated.gif /workspace/crashes/crash_$(date +%s).gif
    break
  }
done
```
