function  MC=mrQ_MC(pd,t1)
% Input-pd for all the cuevettes -last is the buffer!
%%t1 for all the cuevettes-last is the buffer!
% R1= (1-PD)*Factor*R1B+PD*Rfree
% -->
%Factor*R1B=(R1-PD*R1free)./(1-PD)
%
%Mc=Factor*R1B;
%MTV=1-PD;
% -->
%Mc=(R1-PD*R1free)./mtv;

l=length(pd);
r1=1./t1;

for ii=1:l-1
   mtv(ii)=1-pd(ii);%%MTV,pd=Water fraction
   
    MC(ii)=(r1(ii)-pd(ii)*r1(l))/mtv(ii);
    
    
end    
    


end

