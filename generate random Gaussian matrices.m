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
    diff_matrix(1:n+1:n*n) = Inf;
    result = all(diff_matrix(:) > tol);
end
