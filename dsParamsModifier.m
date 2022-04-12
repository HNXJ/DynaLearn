function dsParamsModifier(tempfuncname, map)

    fileID = fopen(tempfuncname, 'w');
    fprintf(fileID, 'function dlTempFuncParamsChanger(dlPath)\n\n');
    fprintf(fileID, '\tp = load([dlPath, ''params.mat'']);\n\n');
    n = size(map);
    
    labels = map.keys();
    values = map.values();
    
    for i = 1:n
    
        if strcmpi(class(values{1, i}), 'double')
            
            m = max(size(values{1, i}));
            if m == 1
                
                fprintf(fileID, '\tp.p.%s = %d;\n', labels{1, i}, values{1, i});
            
            else
                
                x = values{1, i};
                fprintf(fileID, '\tp.p.%s = [%d', labels{1, i}, x(1));
                for i = 2:m-1
                    fprintf(fileID, ' %d', x(i));
                end
                fprintf(fileID, ' %d];\n', x(m));
                
            end
            
        elseif ischar(values{1, i})
            
            fprintf(fileID, '\tp.p.%s = ''%s'';\n', labels{1, i}, values{1, i});
        
        else
            
            fprintf(fileID, '\tp.p.%s = %g;\n', labels{1, i}, values{1, i});
        
        end
        
    end
    
    fprintf(fileID, '\n\tsave([obj.dlPath, ''/params.mat''], ''-struct'', ''p'');\n\nend');
    fclose(fileID);

end