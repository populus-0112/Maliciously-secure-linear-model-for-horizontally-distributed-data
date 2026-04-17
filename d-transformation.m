% Algorithm 2 in the manuscript
% Step 1 — find d_i
%% ============================================================
%  find_di.m
%  Find the minimal d_i ≥ 0 s.t.
%    gamma + 1/gamma ≤ 2*[1 - 4*eps(p)^2]^(-1/p)
%  where gamma = sqrt( min_{j,k} (||x_j||^2 + d^2)
%                               /(||x_k||^2 + d^2) )
%  and eps(p) is treated as a negligible constant (default 1e-6).
%% ============================================================

function d_i = find_di(X, p, eps_val)
% X       : n-by-m matrix, each row is one record x_j
% p       : norm-like parameter (e.g. p = 2)
% eps_val : value of the negligible function eps(p), default 1e-6

if nargin < 3, eps_val = 1e-6; end

%% RHS bound (constant once p and eps are fixed)
rhs = 2 * (1 - 4*eps_val^2)^(-1/p);

%% Squared norms of all records
sq_norms = sum(X.^2, 2);           % n-by-1 vector
min_sq   = min(sq_norms);
max_sq   = max(sq_norms);

%% gamma(d) = sqrt( (min_sq + d^2) / (max_sq + d^2) )
%  gamma + 1/gamma is monotone in d; as d -> inf it -> 2.
%  We need gamma + 1/gamma ≤ rhs.
%  If rhs < 2, the constraint is satisfiable only for large enough d.

gamma_fn     = @(d) sqrt((min_sq + d.^2) ./ (max_sq + d.^2));
objective_fn = @(d) gamma_fn(d) + 1./gamma_fn(d);

%% Check if d=0 already satisfies the constraint
if objective_fn(0) <= rhs
    d_i = 0;
    fprintf('d_i = 0 already satisfies the constraint.\n');
    return
end

%% Binary search / fzero to find smallest d ≥ 0
%  First bracket: find upper bound where constraint holds
d_upper = 1;
while objective_fn(d_upper) > rhs
    d_upper = d_upper * 10;
end

%  fzero on  f(d) = objective_fn(d) - rhs  in [0, d_upper]
f     = @(d) objective_fn(d) - rhs;
d_i   = fzero(f, [0, d_upper]);
d_i   = max(d_i, 0);   % ensure non-negative

fprintf('Found d_i = %.6f\n', d_i);
fprintf('  gamma              = %.6f\n', gamma_fn(d_i));
fprintf('  gamma + 1/gamma    = %.6f  (bound: %.6f)\n', ...
        objective_fn(d_i), rhs);
end


% Step 2 — find α_i
%% ============================================================
%  find_alphai.m
%  Find the minimal alpha_i ≥ 0 s.t.
%    gamma + 1/gamma ≤ 2*[1 - 4*eps(p)^2]^(-1/p)
%  where gamma = sqrt( min_{j,k} ||y_j||^2 / ||y_k||^2 )
%  and Y_iA = [Y_i, Y_s1i, Y_s2i, Y_s3i, alpha_i * ones(n,1)]
%% ============================================================

function alpha_i = find_alphai(Y_i, Y_s1i, Y_s2i, Y_s3i, p, eps_val)
% Y_i, Y_s*i : n-by-* matrices forming the augmented block
% p           : parameter (e.g. p = 2)
% eps_val     : negligible eps(p), default 1e-6

if nargin < 6, eps_val = 1e-6; end

rhs = 2 * (1 - 4*eps_val^2)^(-1/p);

%% Base squared row-norms (columns before the alpha*1 column)
Y_base    = [Y_i, Y_s1i, Y_s2i, Y_s3i];    % n-by-m_base
base_sq   = sum(Y_base.^2, 2);              % n-by-1

%% Row norms of Y_iA:  ||y_j||^2 = base_sq(j) + alpha^2
%  gamma(alpha) = sqrt( min_sq(alpha) / max_sq(alpha) )
%               = sqrt( (min_base + alpha^2) / (max_base + alpha^2) )

min_base  = min(base_sq);
max_base  = max(base_sq);

gamma_fn     = @(a) sqrt((min_base + a.^2) ./ (max_base + a.^2));
objective_fn = @(a) gamma_fn(a) + 1./gamma_fn(a);

%% Check alpha = 0
if objective_fn(0) <= rhs
    alpha_i = 0;
    fprintf('alpha_i = 0 already satisfies the constraint.\n');
    return
end

%% Find upper bracket
a_upper = 1;
while objective_fn(a_upper) > rhs
    a_upper = a_upper * 10;
end

f       = @(a) objective_fn(a) - rhs;
alpha_i = fzero(f, [0, a_upper]);
alpha_i = max(alpha_i, 0);

fprintf('Found alpha_i = %.6f\n', alpha_i);
fprintf('  gamma              = %.6f\n', gamma_fn(alpha_i));
fprintf('  gamma + 1/gamma    = %.6f  (bound: %.6f)\n', ...
        objective_fn(alpha_i), rhs);
end


% Step 3 — demo / usage
%% ============================================================
%  demo_find_constants.m
%  End-to-end usage example
%% ============================================================

rng(42);
n = 100;   % number of records
m = 20;    % feature dimension
p = 2;
eps_val = 1e-6;

%% Simulate agency data
X   = randn(n, m) * 5;          % raw records (rows)
Y_i = X * randn(m, m);          % e.g. transformed data
Y_s = {randn(n,m), randn(n,m), randn(n,m)};

%% --- Find d_i ---
d_i = find_di(X, p, eps_val);

%% --- Find alpha_i (uses the already-available Y blocks) ---
alpha_i = find_alphai(Y_i, Y_s{1}, Y_s{2}, Y_s{3}, p, eps_val);

%% --- Visualise the objective vs the parameter ---
figure('Name','Gamma objective vs d and alpha');

subplot(1,2,1);
sq_norms = sum(X.^2, 2);
min_sq   = min(sq_norms);  max_sq = max(sq_norms);
d_vals   = linspace(0, d_i*3+1, 500);
g_d      = sqrt((min_sq + d_vals.^2)./(max_sq + d_vals.^2));
obj_d    = g_d + 1./g_d;
rhs      = 2*(1-4*eps_val^2)^(-1/p);
plot(d_vals, obj_d, 'b-', 'LineWidth', 1.5); hold on;
yline(rhs, 'r--', 'LineWidth', 1.2);
xline(d_i, 'k:', 'LineWidth', 1.2);
xlabel('d_i');  ylabel('\gamma + 1/\gamma');
title('Objective vs d_i');
legend('Objective','Bound','Optimal d_i','Location','best');
grid on;

subplot(1,2,2);
base_sq  = sum([Y_i, Y_s{1}, Y_s{2}, Y_s{3}].^2, 2);
min_b    = min(base_sq);  max_b = max(base_sq);
a_vals   = linspace(0, alpha_i*3+1, 500);
g_a      = sqrt((min_b + a_vals.^2)./(max_b + a_vals.^2));
obj_a    = g_a + 1./g_a;
plot(a_vals, obj_a, 'm-', 'LineWidth', 1.5); hold on;
yline(rhs, 'r--', 'LineWidth', 1.2);
xline(alpha_i, 'k:', 'LineWidth', 1.2);
xlabel('\alpha_i');  ylabel('\gamma + 1/\gamma');
title('Objective vs \alpha_i');
legend('Objective','Bound','Optimal \alpha_i','Location','best');
grid on;
