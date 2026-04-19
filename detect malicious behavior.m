%   Check three integrity conditions on decrypted beta estimates:
%   Condition 1: beta_2 = ones(p,1)
%   Condition 2: beta_3 = zeros(p,1)
%   Condition 3: beta_4 = beta_1 + beta_2 + beta_3
%   If any fails => malicious behavior detected

load('decrypted_results.mat', 'beta_decrypted');

beta_1 = beta_decrypted(:, 1);
beta_2 = beta_decrypted(:, 2);
beta_3 = beta_decrypted(:, 3);
beta_4 = beta_decrypted(:, 4);
p      = size(beta_decrypted, 1);

pass_check1 = isequal(beta_2, ones(p, 1));
pass_check2 = isequal(beta_3, zeros(p, 1));
pass_check3 = isequal(beta_4, beta_1 + beta_2 + beta_3);
is_valid    = pass_check1 && pass_check2 && pass_check3;

status = {'FAILED', 'PASSED'};
fprintf('Check1: %s | Check2: %s | Check3: %s | Overall: %s\n', ...
         status{pass_check1+1}, status{pass_check2+1}, ...
         status{pass_check3+1}, status{is_valid+1});

if ~is_valid
    fprintf('*** MALICIOUS BEHAVIOR DETECTED ***\n');
end
