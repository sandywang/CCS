function [nmults resids dts alpha graph] = parse_bvpr_log(fn)
fid = fopen(fn,'rt');
try
    C = textscan(fid,'%s%s', 6, 'Headerlines', 1, ...
                'Delimiter', ';:= ','MultipleDelimsAsOne',1);
    for i=1:length(C{1})
        switch C{1}{i}
            case 'graphfile'
                [path graph] = fileparts(C{2}{i});
                strrep(graph,'-trans','');
            case 'output'
            case 'alg'
                alg = C{2}{i};
            case 'alpha'
                alpha = str2double(C{2}{i});
        end
    end
    
    switch(alg)
        case 'inout'
            C = textscan(fid,'%s%s%s%n%s%n%s%n%s%n', 'Headerlines', 5, ...
                'Delimiter', ';:= ','MultipleDelimsAsOne',1);
            nmultc = 10;
            deltac = 6;
            dtc = 8;
        case 'power'
            C = textscan(fid,'%s%s%n%s%n%s%n%s', 'Headerlines', 4, ...
                'Delimiter', ';:= ','MultipleDelimsAsOne',1);
            nmultc = 3;
            deltac = 5;
            dtc = 7;
        case 'gs'
            C = textscan(fid,'%s%s%n%s%n%s%n%s%n%s%s%n', 'Headerlines', 5, ...
                'Delimiter', ';:= ','MultipleDelimsAsOne',1);
            nmultc = 12;
            deltac = 7;
            dtc = 9;
        case 'inoutgs'
            C1 = textscan(fid,'%*s%*s%*s%n%*s%n%*s%n', 1, 'Headerlines', 5, ...
                'Delimiter', ';:= ','MultipleDelimsAsOne',1);
            C2 = [];
            while ~feof(fid)
                pos = ftell(fid);
                C2c = textscan(fid,'%*s%*s%*s%n%*s%n%*s%n%*s%n', 1, ...
                    'Delimiter', ';:= ','MultipleDelimsAsOne',1);
                if any(cellfun('length',C2c)<1), break; end
                C2 = [C2; cell2mat(C2c)];
            end
            fseek(fid, pos, 'bof');
            C3 = textscan(fid,'%s%s%s%n%s%n%s%n%s%n%s%s%n', ...
                'Delimiter', ';:=() ','MultipleDelimsAsOne',1);
            C = { [1; C2(:,4); C3{13}], [C1{2}; C2(:,1); C3{8}], [C1{3}; C2(:,3); C3{10}] };
            nmultc = 1;
            deltac = 2;
            dtc = 3;
        otherwise
            error('invalid method');
    end
    
    nmults = C{nmultc};
    resids = C{deltac};
    dts = C{dtc};
    
    fclose(fid);
                
catch 
    fclose(fid);
end