# Due to a QEMU issue we have to prefetch our dependencies, so can't just "cargo install trunk/wasm-bindgen"
FROM --platform=$BUILDPLATFORM rust:latest as fetcher

WORKDIR /

# Wasm-bindgen
RUN git clone https://github.com/rustwasm/wasm-bindgen
WORKDIR wasm-bindgen/
RUN git checkout tags/0.2.72 && \
    mkdir -p .cargo
RUN cargo vendor > /wasm-bindgen/.cargo/config

WORKDIR crates/cli
RUN cargo vendor > /wasm-bindgen/.cargo/config

FROM rust:latest as builder2

WORKDIR /

COPY --from=fetcher /wasm-bindgen/ /wasm-bindgen/

WORKDIR /wasm-bindgen/
RUN chown -R root:root /wasm-bindgen/
RUN cargo install --path /wasm-bindgen/crates/cli --offline


