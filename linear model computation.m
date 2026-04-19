function [beta_hat] = server_regression()
% SERVER_REGRESSION
%   Server receives encrypted X* and Y* from all agencies and
%   derives the linear regression estimate.
%
%   X*  = M * X * B_total    (n x p)
%   Y*  = M * Y_A * A_total  (n x 5)
%
%   OLS on encrypted data:
%   beta* = (X*'X*)^{-1} X*'Y*
%
%   Input:  (loaded from files)
%       server_pooled_data.mat   - X_star_all, Y_star_all
%       global_params.mat        - K, p
%
%   Output:
%       beta_hat      - regression estimate in encrypted space (p x 5)

    fprintf('==============================================\n');
    fprintf('Server: Computing Linear Regression Estimate\n');
    fprintf('==============================================\n');

    %% Load parameters
    load('global_params.mat', 'K', 'p');

    %% -------------------------------------------------------
    %% Step 1: Load all encrypted data from agencies
    %% -------------------------------------------------------
    fprintf('\n[Step 1] Loading encrypted data from all agencies...\n');

    X_star_all = cell(K, 1);
    Y_star_all = cell(K, 1);

    for i = 1:K
        fname = sprintf('server_input_agency_%d.mat', i);
        load(fname, 'X_star', 'Y_star');
        X_star_all{i} = X_star;
        Y_star_all{i} = Y_star;
        fprintf('  Agency %d: X* [%d x %d], Y* [%d x %d] loaded\n', ...
                 i, size(X_star,1), size(X_star,2), ...
                    size(Y_star,1), size(Y_star,2));
    end

    %% -------------------------------------------------------
    %% Step 2: Pool encrypted data across all agencies
    %% -------------------------------------------------------
    fprintf('\n[Step 2] Pooling encrypted data...\n');

    X_star_pooled = vertcat(X_star_all{:});   % (K*n) x p
    Y_star_pooled = vertcat(Y_star_all{:});   % (K*n) x 5

    fprintf('  Pooled X* size: [%d x %d]\n', size(X_star_pooled));
    fprintf('  Pooled Y* size: [%d x %d]\n', size(Y_star_pooled));

    %% -------------------------------------------------------
    %% Step 3: OLS on encrypted data
    %%   beta_star = (X*' X*)^{-1} X*' Y*
    %% -------------------------------------------------------
    fprintf('\n[Step 3] Computing OLS on encrypted data...\n');

    XtX_star = X_star_pooled' * X_star_pooled;   % p x p
    XtY_star = X_star_pooled' * Y_star_pooled;   % p x 5
    beta_hat = XtX_star \ XtY_star;          % p x 5 (more stable than inv)
    fprintf('  beta_hat (encrypted space) size: [%d x %d]\n', ...
             size(beta_hat,1), size(beta_hat,2));

end
