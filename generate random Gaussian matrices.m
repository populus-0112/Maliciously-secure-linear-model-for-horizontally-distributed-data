function [B0, A0] = generate_base_matrices_gaussian(p)
% GENERATE_BASE_MATRICES_GAUSSIAN
%   Generate B0 (p x p) and A0 (5 x 5) where:
%     - Each element ~ N(0,1)  
%     - All eigenvalues are unique
%
%   Strategy:
%     1. Generate M = randn(dim, dim)          <- Gaussian elements
%     2. Compute eigenvalues
%     3. If NOT unique (extremely rare): apply
%        minimal diagonal perturbation to fix,
%        then re-symmetrize to preserve N(0,1)
%        element distribution as closely as possible
%
%   The probability that a random Gaussian matrix has repeated
%   eigenvalues is exactly ZERO (measure-zero event), so in
%   practice Step 3 is almost never needed.

    fprintf('==============================================\n');
    fprintf('Server: Generating B0 and A0 (Gaussian elements)\n');
    fprintf('==============================================\n');

    %% Generate B0 (p x p)
    tic;
    B0 = generate_gaussian_unique_eig(p, 'B0');
    t1 = toc;
    fprintf('B0 generated in %.6f seconds\n', t1);

    %% Generate A0 (5 x 5)
    tic;
    A0 = generate_gaussian_unique_eig(5, 'A0');
    t2 = toc;
    fprintf('A0 generated in %.6f seconds\n', t2);

    %% Save
    save('server_base_matrices.mat', 'B0', 'A0');
    fprintf('\nSaved to server_base_matrices.mat\n');

    %% Report element distribution and eigenvalue properties
    report_full(B0, 'B0');
    report_full(A0, 'A0');
end


%% =========================================================
function M = generate_gaussian_unique_eig(dim, name)
% GENERATE_GAUSSIAN_UNIQUE_EIG
%   Core function: generate dim x dim Gaussian matrix with
%   unique eigenvalues, preserving N(0,1) element distribution.

    tol      = 1e-6;
    max_iter = 100;     % in practice almost always 1 iteration
    iter     = 0;
    found    = false;

    fprintf('\n--- Generating %s (%dx%d) ---\n', name, dim, dim);

    while ~found && iter < max_iter
        iter = iter + 1;

        %% Step 1: Generate pure Gaussian matrix
        M = randn(dim, dim);

        %% Step 2: Compute eigenvalues
        eigvals = eig(M);

        %% Step 3: Check uniqueness
        if has_unique_eigenvalues(eigvals, tol)
            found = true;
            fprintf('  %s: unique eigenvalues confirmed (attempt %d)\n', name, iter);
        else
            %% Extremely rare: apply tiny diagonal perturbation
            fprintf('  %s: repeated eigenvalues detected, applying perturbation (attempt %d)\n', ...
                    name, iter);
            M = M + diag(1e-8 * randn(dim, 1));   % tiny perturbation
            eigvals = eig(M);
            if has_unique_eigenvalues(eigvals, tol)
                found = true;
                fprintf('  %s: fixed after perturbation\n', name);
            end
        end
    end

    if ~found
        error('Could not generate %s with unique eigenvalues after %d attempts', ...
               name, max_iter);
    end
end


%% =========================================================
function result = has_unique_eigenvalues(eigvals, tol)
% HAS_UNIQUE_EIGENVALUES - vectorized pairwise check

    n = length(eigvals);
    diff_matrix = abs(eigvals - eigvals.');
    diff_matrix(1:n+1:end) = Inf;
    result = all(diff_matrix(:) > tol);
end


%% =========================================================
function report_full(M, name)
% REPORT_FULL
%   Report both element distribution AND eigenvalue properties.

    fprintf('\n==============================\n');
    fprintf('%s Full Report\n', name);
    fprintf('==============================\n');

    %% Element distribution
    elements = M(:);
    fprintf('\n[Element Distribution]\n');
    fprintf('  Mean              : %+.6f  (expected ~0)\n',   mean(elements));
    fprintf('  Std               : %.6f   (expected ~1)\n',   std(elements));
    fprintf('  Skewness          : %+.6f  (expected ~0)\n',   skewness(elements));
    fprintf('  Excess Kurtosis   : %+.6f  (expected ~0)\n',   kurtosis(elements)-3);

    %% Jarque-Bera normality test
    [jb_h, jb_p] = jbtest(elements);
    fprintf('  Jarque-Bera test  : h=%d, p=%.4f ', jb_h, jb_p);
    if jb_h == 0
        fprintf('(PASS: cannot reject normality)\n');
    else
        fprintf('(FAIL: normality rejected)\n');
    end

    %% Kolmogorov-Smirnov test against N(0,1)
    [ks_h, ks_p] = kstest(elements);
    fprintf('  KS test vs N(0,1) : h=%d, p=%.4f ', ks_h, ks_p);
    if ks_h == 0
        fprintf('(PASS: consistent with N(0,1))\n');
    else
        fprintf('(FAIL: not N(0,1) - may need scaling)\n');
    end

    %% Eigenvalue properties
    eigvals = eig(M);
    n = length(eigvals);
    diff_matrix = abs(eigvals - eigvals.');
    diff_matrix(1:n+1:end) = Inf;
    min_eig_dist = min(diff_matrix(:));

    fprintf('\n[Eigenvalue Properties]\n');
    fprintf('  Rank              : %d / %d\n',  rank(M), dim(M));
    fprintf('  Condition number  : %.4e\n',      cond(M));
    fprintf('  Min eig distance  : %.4e\n',      min_eig_dist);
    fprintf('  All unique        : %d\n',        min_eig_dist > 1e-6);
    fprintf('  Eigenvalues:\n');
    for k = 1:n
        fprintf('    lambda_%d = %+.6f %+.6fi\n', k, real(eigvals(k)), imag(eigvals(k)));
    end
end


%% =========================================================
function d = dim(M)
    d = size(M, 1);
end
