# Maliciously secure linear model for horizontally distributed data

This repository provides the implementation of a privacy-preserving collaborative linear learning framework that is secure against malicious adversaries. The scheme allows multiple data providers to jointly train a linear (or ridge regression) model on horizontally partitioned data — without sharing raw data and without requiring any external server.

Key properties of the framework:

1. Resilient to collusion attacks involving up to K−1 out of K data providers
2. No external server required: any participating agency can serve as the computation server
3. Malicious behavior detection via pseudo-outcome verification
4. Lossy compression (SZ) applied to reduce communication cost with negligible accuracy loss

Stage 1 — Encryption

1.1 Internal data preparation
    -- d-transformation (Algorithm 2)
    
1.2 Internal data encryption

1.3 External sequential encryption


Stage 2 — Linear Model Computation

2.1 Data transmission between agencies (i.e., data providers) and the server
    -- lossy compression (SZ).txt

2.2 Linear model computation


Stage 3 — Decryption


Stage 4 — Malicious Behavior Detection



