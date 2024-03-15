width=8;    %width of rom
depth=1024; %depth of rom
x=linspace(0,2*pi,depth); 
y_sin=sin(x); 
y_sin=round(y_sin*(2^(width-1)-1))+2^(width-1)-1;

fid=fopen('C:\Users\zhenyuliu\Desktop\fir\sin.coe','w');
fprintf(fid,'%d,\n',y_sin); 
fclose(fid); 