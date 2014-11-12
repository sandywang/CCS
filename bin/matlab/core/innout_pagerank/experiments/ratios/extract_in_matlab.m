>> [nmults resids] = parse_bvpr_log('ubc-cs-inout-99-4.log');               
>> for i = [10 50 100 500], fprintf('=%g/%g\n', resids(i+1), resids(i)); end
=0.0122108/0.0127258
=0.00470079/0.00479612
=0.00180312/0.00183732
=3.64275e-06/3.69137e-06
>> [nmults resids] = parse_bvpr_log('arabic-2005-inout-99-4.log');
??? Error using ==> fclose
Invalid file identifier.  Use fopen to generate a valid file identifier.

Error in ==> parse_bvpr_log at 67
    fclose(fid);

>> [nmults resids] = parse_bvpr_log('arabic-2005-inout-8.log');   
>> for i = [10 50 100 500], fprintf('=%g/%g\n', resids(i+1), resids(i)); end
=0.0181914/0.0193627
=0.00421954/0.00432961
=0.00145938/0.00148664
=5.20599e-06/5.27186e-06
>> [nmults resids] = parse_bvpr_log('sk-2005-inout-8.log');    
>> for i = [10 50 100 500], fprintf('=%g/%g\n', resids(i+1), resids(i)); end
=0.0186848/0.01997
=0.0042959/0.00439553
=0.00159251/0.00162173
=4.7235e-06/4.78492e-06
>> [nmults resids] = parse_bvpr_log('sk-2005-inout-85-8.log');
>> for i = [10 50], fprintf('=%g/%g\n', resids(i+1), resids(i)); end        
=0.00237235/0.00299102
=1.04912e-06/1.25107e-06
>> [nmults resids] = parse_bvpr_log('arabic-2005-inout-85-8.log');
>> for i = [10 50], fprintf('=%g/%g\n', resids(i+1), resids(i)); end
=0.00258192/0.0032535
=1.15164e-06/1.37767e-06
>> addpath('../../matlab');

