#!/usr/bin/env bash
set -euo pipefail

echo "=========================================="
echo "Compiling libjpeg-turbo with AddressSanitizer (ASan)"
echo "=========================================="

compile_version() {
    local src_dir="$1"
    local build_dir="${src_dir}/build-asan"

    echo "[*] Configuring and building ${src_dir} -> ${build_dir}..."
    rm -rf "${build_dir}"
    mkdir -p "${build_dir}"
    cd "${build_dir}"

    # Use Clang with ASan flags
    # -DWITH_SIMD=0 is recommended when using AddressSanitizer with libjpeg-turbo
    # to avoid false positives or SIMD assembly bypassing C memory checks.
    cmake -G "Unix Makefiles" \
        -DCMAKE_C_COMPILER=clang \
        -DCMAKE_C_FLAGS="-fsanitize=address -g -O1 -fno-omit-frame-pointer" \
        -DCMAKE_EXE_LINKER_FLAGS="-fsanitize=address" \
        -DENABLE_SHARED=OFF \
        -DENABLE_STATIC=ON \
        -DWITH_SIMD=0 \
        "${src_dir}"

    make -j"$(nproc)"

    # Create aliases / symlinks if targets are named cjpeg-static / djpeg-static
    if [ -f "cjpeg-static" ] && [ ! -f "cjpeg" ]; then
        ln -sf cjpeg-static cjpeg
    fi
    if [ -f "djpeg-static" ] && [ ! -f "djpeg" ]; then
        ln -sf djpeg-static djpeg
    fi

    echo "[+] Done building cjpeg and djpeg for ${src_dir}"
    ls -l "${build_dir}/cjpeg"* "${build_dir}/djpeg"*
}

compile_version "/workspace/libjpeg-turbo-2.0.90"
compile_version "/workspace/libjpeg-turbo-2.1.0"

echo "=========================================="
echo "AddressSanitizer build completed successfully!"
echo "=========================================="
