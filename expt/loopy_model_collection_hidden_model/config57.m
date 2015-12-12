params.split = 0.800000;
params.BCFW_max_iterations = 75000;
params.structure_type = 'loopy';
params.compute_true_logZ = true;
params.reweight_denominator = 'mean_degree';
[params.data, params.variable_names] = get_real_data(100);
s_lambdas = logspace(-2.698970,-0.301030,12);
params.s_lambda_count = 1;
params.s_lambda_min = s_lambdas(9);
params.s_lambda_max = s_lambdas(9);
densities = linspace(0.060000,0.060000,1);
params.density_count = 1;
params.density_min = densities(1);
params.density_max = densities(1);
p_lambdas = logspace(1.000000,4.000000,10);
params.p_lambda_count = 1;
params.p_lambda_min = p_lambdas(5);
params.p_lambda_max = p_lambdas(5);
