  function  minfit= mrQ_simplefit3(x,mininput)
%   This function computes 3 parameter fitting using minimazation to the
  % function Y=A+B*exp(-TI/T1)
      fitsig= x(1)+x(2).*exp((-mininput.ti)./x(3));
      minfit=mininput.sig-abs(fitsig);
   
  end
  