function [phase deg] = phase_from_complex(num)

x=real(num);
y=imag(num);
sign_real=sign(x);
sign_img=sign(y);

switch sign_real
    case 1
       phase=atan(y/x);
    case -1
        if (sign_img==-1)
        phase=atan(y/x) -pi;
 
        else
         phase=atan(y/x) +pi;

        end
    case 0
          if (sign_img==-1)
              phase=-pi;
          elseif  (sign_img==1)
               phase=pi;
          else
             phase=NaN; %%indeterminate!!
            
          end
end

          deg = radtodeg(phase);
end