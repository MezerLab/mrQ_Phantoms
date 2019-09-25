  function  minfit= mrQ_simplefit_complex(x,mininput)
  % This function computes 2 parameter fitting using minimazation to the
  % function Y=C*exp(-TI/T1)
      fitsig= x(1).*(1-2.*exp(-mininput.ti./x(2)));
      minfit=mininput.sig-abs(fitsig);
  end
  