function nfailed = check_bvpr_codes(graph,a,pr2)

methods = {'power','inout'};
trans_methods = {'gs','inoutgs'};
codes = {'bvpr','bvmcpr','bvtranspr','bvmctranspr'};
codedir = '.';
nfailed = 0;
for ci = 1:length(codes)
    c = codes{ci};
    for mi = 1:length(methods)
        m = methods{mi};
        cmd = sprintf('%s %s test %s %f', [codedir filesep c], graph, m, a);
        status = system(cmd);
        if status == 0
            pr=binload('test.pr'); diff = norm(pr-pr2,1);
            if diff>(1/(1-a))*1e-8
                warning('bvpr:incorrect',...
                    '%s (%s) returned x with ||x-x*||_1 = %g',...
                    c, m, diff); 
                nfailed = nfailed + 1;
            end
        else
            error('bvpr:failed','%s failed!',cmd);
        end
    end
end

c = 'bvtranspr';
for mi = 1:length(trans_methods)
    m = trans_methods{mi};
    cmd = sprintf('%s %s test %s %f', [codedir filesep c], graph, m, a);
    status = system(cmd);
    if status == 0
        pr=binload('test.pr'); diff = norm(pr-pr2,1);
        if diff>(1/(1-a))*1e-8
            warning('bvpr:incorrect',...
                '%s (%s) returned x with ||x-x*||_1 = %g',...
                c, m, diff); 
            nfailed = nfailed + 1;
        end
    else
        error('bvpr:failed','%s failed!',cmd);
    end
end
