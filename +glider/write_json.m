function write_json(path,value)
%WRITE_JSON Save readable machine-verifiable receipts.
fid=fopen(path,'w','n','UTF-8'); assert(fid>0,'Cannot open output file.');
cleanup=onCleanup(@()fclose(fid));
fprintf(fid,'%s\n',jsonencode(value,'PrettyPrint',true));
end
