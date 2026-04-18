# Maliciously secure linear model for horizontally distributed data

This repository provides the implementation of a privacy-preserving collaborative linear learning framework that is secure against malicious adversaries. The scheme allows multiple data providers to jointly train a linear (or ridge regression) model on horizontally partitioned data — without sharing raw data and without requiring any external server.

Key properties of the framework:

1. Resilient against collusion among up to $K-1$ out of $K$ data providers (i.e., agencies)
2. No external server required: any participating agency can serve as the computation server
3. Malicious behavior detection via pseudo-outcome verification
4. Lossy compression (SZ) applied to reduce communication cost with negligible accuracy loss

<img width="777" height="373" alt="image" src="https://github.com/user-attachments/assets/46357bc2-f339-4d49-bce5-68be27e60842" />

Before data encryption, the designated server—which may be any participating agency—generates a random Gaussian matrix $B_0$ ($B_0$ is a $p\times p$ matrix where each element follows a Gaussian distribution $N(0,1)$. We require $B_0$ to have $p$ unique eigenvalues.) and a $5\times 5$ random Gaussian matrix $A_0$ with 5 unique eigenvalues. The server generates $B_0$ and $A_0$, and shares with each agency.

Stage 1 — Encryption

1.1 Internal data preparation

    -- d-transformation.m
    
1.2 Internal data encryption

1.3 External sequential encryption


Stage 2 — Linear Model Computation

2.1 Data transmission between agencies (i.e., data providers) and the server

    -- lossy compression (SZ).txt

2.2 Linear model computation


Stage 3 — Decryption


Stage 4 — Malicious Behavior Detection



