function [mrQ_complex]=phase_to_complex(phas,mag)

rnge=pi-(-pi);
coff=rnge/4096;



x=mag.*cos(phas.*coff-pi);
y=i*mag.*sin(phas.*coff-pi);




mrQ_complex=x+y;


end

