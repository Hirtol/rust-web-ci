# Due to a QEMU issue we have to prefetch our dependencies, so can't just "cargo install trunk/wasm-bindgen"
FROM --platform=$BUILDPLATFORM rust:latest as fetcher

WORKDIR /

# Trunk
RUN git clone https://github.com/thedodd/trunk
WORKDIR trunk/
RUN git checkout tags/v0.10.0 && \
    mkdir -p .cargo && \
    cargo vendor > /trunk/.cargo/config

WORKDIR /

# Wasm-bindgen
RUN git clone https://github.com/rustwasm/wasm-bindgen
WORKDIR wasm-bindgen/
RUN git checkout tags/0.2.72 && \
    mkdir -p .cargo && \
    cargo vendor > /wasm-bindgen/.cargo/config

WORKDIR /

# Sqlx
RUN git clone https://github.com/Hirtol/sqlx
WORKDIR sqlx/
RUN mkdir -p .cargo && \
    cargo vendor > /sqlx/.cargo/config

FROM rust:latest as builder

WORKDIR /

COPY --from=fetcher /trunk/ /trunk/
COPY --from=fetcher /wasm-bindgen/ /wasm-bindgen/
COPY --from=fetcher /sqlx/ /sqlx/

RUN cargo install --path /trunk/ --offline

RUN cargo install --path /wasm-bindgen/crates/cli --offline

WORKDIR /sqlx/
RUN cargo build -p sqlx-cli --release --offline && mv /sqlx/target/release/sqlx /usr/local/cargo/bin

FROM rust:latest

RUN apt-get update
RUN apt -y install npm

RUN rustup target add wasm32-unknown-unknown

COPY --from=builder /usr/local/cargo/bin/sqlx /usr/local/cargo/bin
COPY --from=builder /usr/local/cargo/bin/trunk /usr/local/cargo/bin
COPY --from=builder /usr/local/cargo/bin/wasm-bindgen /usr/local/cargo/bin
COPY --from=builder /usr/local/cargo/bin/wasm-bindgen-test-runner /usr/local/cargo/bin
COPY --from=builder /usr/local/cargo/bin/wasm2es6js /usr/local/cargo/bin


