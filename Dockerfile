FROM rust:latest as builder

# Keep these two synchronised.
RUN cargo install trunk --version 0.10.0
RUN cargo install wasm-bindgen-cli --version 0.2.72

RUN cargo install --git https://github.com/Hirtol/sqlx sqlx-cli

FROM rust:latest

RUN apt-get update
RUN apt -y install npm

RUN rustup target add wasm32-unknown-unknown

COPY --from=builder /usr/local/cargo/bin/sqlx /usr/local/cargo/bin
COPY --from=builder /usr/local/cargo/bin/trunk /usr/local/cargo/bin
COPY --from=builder /usr/local/cargo/bin/wasm-bindgen /usr/local/cargo/bin
COPY --from=builder /usr/local/cargo/bin/wasm-bindgen-test-runner /usr/local/cargo/bin
COPY --from=builder /usr/local/cargo/bin/wasm2es6js /usr/local/cargo/bin


