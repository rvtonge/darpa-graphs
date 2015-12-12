function create_config_files(varargin)
    % Remove old config files
    system('rm -f config*.m');
    system('rm -f yeti_config.m');
    
    % guarantees folders exist
    system('mkdir -p job_logs');
    system('mkdir -p results');
    system('mkdir -p yeti_logs');

    parser = inputParser;
    
    parser.addParamValue('training_test_split', .8, @isscalar); 
    parser.addParamValue('BCFW_max_iterations', 75000, @isscalar); 
    parser.addParamValue('structure_type', 'loopy', @ischar); 
    parser.addParamValue('experiment_name', 'loopy_model_collection_hidden_model', @ischar); 
    parser.addParamValue('email_for_notifications', '1live.life.queen.size1@gmail.com', @ischar); 
    parser.addParamValue('yeti_user', 'darpa', @ischar); 
    parser.addParamValue('compute_true_logZ', true, @islogical); 
    parser.addParamValue('reweight_denominator', 'max_degree'); 
    parser.addParamValue('num_samples', 0);
    
    parser.addParamValue('s_lambda_splits', 1, @isscalar); 
    parser.addParamValue('s_lambdas_per_split', 1, @isscalar); 
    parser.addParamValue('s_lambda_min', 1e-01, @isscalar);
    parser.addParamValue('s_lambda_max', 1e-01, @isscalar);
    
    parser.addParamValue('density_splits', 1, @isscalar); 
    parser.addParamValue('densities_per_split', 1, @isscalar); 
    parser.addParamValue('density_min', 0.05, @isscalar);
    parser.addParamValue('density_max', 0.05, @isscalar);
    
    parser.addParamValue('p_lambda_splits', 1, @isscalar); 
    parser.addParamValue('p_lambdas_per_split', 1, @isscalar); 
    parser.addParamValue('p_lambda_min', 1e+01, @isscalar);
    parser.addParamValue('p_lambda_max', 1e+01, @isscalar);

    parser.parse(varargin{:})
    
    training_test_split = parser.Results.training_test_split;
    BCFW_max_iterations = parser.Results.BCFW_max_iterations;
    structure_type = parser.Results.structure_type;
    experiment_name = parser.Results.experiment_name;
    email_for_notifications = parser.Results.email_for_notifications;
    yeti_user = parser.Results.yeti_user;
    compute_true_logZ = parser.Results.compute_true_logZ;
    if (compute_true_logZ); compute_true_logZ_str='true'; else;  compute_true_logZ_str='false'; end
    reweight_denominator = parser.Results.reweight_denominator;
    num_samples = parser.Results.num_samples;
    
    s_lambda_splits = parser.Results.s_lambda_splits;
    s_lambdas_per_split = parser.Results.s_lambdas_per_split;
    s_lambda_min = parser.Results.s_lambda_min;
    s_lambda_max = parser.Results.s_lambda_max;
    
    density_splits = parser.Results.density_splits;
    densities_per_split = parser.Results.densities_per_split;
    density_min = parser.Results.density_min;
    density_max = parser.Results.density_max;
    
    p_lambda_splits = parser.Results.p_lambda_splits;
    p_lambdas_per_split = parser.Results.p_lambdas_per_split;
    p_lambda_min = parser.Results.p_lambda_min;
    p_lambda_max = parser.Results.p_lambda_max;
    
    display('CHECK INFO BELOW');
    display(sprintf('Writing config files for yet user %s', yeti_user));
    display(sprintf('Experiment name: %s', experiment_name));
    display(sprintf('Total jobs to be submitted: %d', p_lambda_splits*s_lambda_splits*density_splits));
    
    % Write config files    
    config_file_count = 0;
    for i=1:p_lambda_splits
        for j=1:s_lambda_splits
            for k=1:density_splits
                config_file_count = config_file_count + 1;
                fid = fopen(sprintf('config%d.m',config_file_count),'w');
                fprintf(fid,'params.split = %f;\n', training_test_split);
                fprintf(fid,'params.BCFW_max_iterations = %d;\n', BCFW_max_iterations);
                fprintf(fid,'params.structure_type = ''%s'';\n', structure_type);
                fprintf(fid,'params.compute_true_logZ = %s;\n', compute_true_logZ_str);
                if ischar(reweight_denominator)
                    fprintf(fid,'params.reweight_denominator = ''%s'';\n', reweight_denominator);
                else
                    fprintf(fid,'params.reweight_denominator = %d;\n', reweight_denominator);
                end
                
                % get real data (params.data)
                if num_samples == 0
                    fprintf(fid,'[params.data, params.variable_names] = get_real_data();\n');
                else
                    fprintf(fid,'[params.data, params.variable_names] = get_real_data(%d);\n', num_samples);
                end

                if strcmp(structure_type, 'loopy')
                    % slambda
                    fprintf(fid,'s_lambdas = logspace(%f,%f,%d);\n', log10(s_lambda_min), log10(s_lambda_max), s_lambdas_per_split*s_lambda_splits);
                    fprintf(fid,'params.s_lambda_count = %d;\n', s_lambdas_per_split);
                    fprintf(fid,'params.s_lambda_min = s_lambdas(%d);\n', (j-1)*s_lambdas_per_split + 1);
                    fprintf(fid,'params.s_lambda_max = s_lambdas(%d);\n', j*s_lambdas_per_split);

                    % density
                    fprintf(fid,'densities = linspace(%f,%f,%d);\n', density_min, density_max, densities_per_split*density_splits);
                    fprintf(fid,'params.density_count = %d;\n', densities_per_split);
                    fprintf(fid,'params.density_min = densities(%d);\n', (k-1)*densities_per_split + 1);
                    fprintf(fid,'params.density_max = densities(%d);\n', k*densities_per_split);
                end
                    
                % plambda
                fprintf(fid,'p_lambdas = logspace(%f,%f,%d);\n', log10(p_lambda_min), log10(p_lambda_max), p_lambdas_per_split*p_lambda_splits);
                fprintf(fid,'params.p_lambda_count = %d;\n', p_lambdas_per_split);
                fprintf(fid,'params.p_lambda_min = p_lambdas(%d);\n', (i-1)*p_lambdas_per_split + 1);
                fprintf(fid,'params.p_lambda_max = p_lambdas(%d);\n', i*p_lambdas_per_split);
                
                fclose(fid);
            end
        end
    end

    % Write YETI script
    fid = fopen('yeti_config.sh','w');

    fprintf(fid,'#!/bin/sh\n');
    fprintf(fid,'#yeti_config.sh\n\n');
    fprintf(fid,'#Torque script to run Matlab program\n');

    fprintf(fid,'\n#Torque directives\n');
    fprintf(fid,'#PBS -N %s\n', experiment_name);
    fprintf(fid,'#PBS -W group_list=yetidsi\n');
    fprintf(fid,'#PBS -l nodes=1,walltime=12:00:00,mem=800mb\n');
    fprintf(fid,'#PBS -m abe\n');
    fprintf(fid,'#PBS -M %s\n', email_for_notifications);
    fprintf(fid,'#PBS -V\n');
    fprintf(fid,'#PBS -t 1-%d\n',p_lambda_splits*s_lambda_splits*density_splits);

    fprintf(fid,'\n#set output and error directories (SSCC example here)\n');
    fprintf(fid,'#PBS -o localhost:/vega/dsi/users/%s/fwMatch/expt/%s/yeti_logs/\n', yeti_user, experiment_name);
    fprintf(fid,'#PBS -e localhost:/vega/dsi/users/%s/fwMatch/expt/%s/yeti_logs/\n', yeti_user, experiment_name);

    fprintf(fid,'\n#Command below is to execute Matlab code for Job Array (Example 4) so that each part writes own output\n');
    fprintf(fid,'./run.sh %s $PBS_ARRAYID > expt/%s/job_logs/matoutfile.$PBS_ARRAYID\n', experiment_name, experiment_name);
    fprintf(fid,'#End of script\n');
end

