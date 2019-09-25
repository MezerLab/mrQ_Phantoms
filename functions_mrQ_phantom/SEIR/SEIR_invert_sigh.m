function [ z]=SEIR_invert_sigh(tot_num,TI)

l=length(TI);


imag_part=squeeze(imag(tot_num))';



real_part=squeeze(real(tot_num))';


[xi,yi] = polyxpoly(TI,imag_part,TI,real_part);

for i=1:l
  if (TI(i)<xi)
      z(i)=-1;
  
  else
      z(i)=1;
  end

end



end
