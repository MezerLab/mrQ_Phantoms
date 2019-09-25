function  [A]=mrQ_MC2(A,date,P)

%Mc=(R1-PD*R1free)./mtv;

r1b=A.(date).B.Median_R1_Buffer;


for ll=1:length(P.(date).Type.Lipids)
    
    lip=P.(date).Type.Lipids{ll};
        
    A.(date).r1.(lip).MC=(A.(date).r1.(lip).Median_MR-r1b)./A.(date).nWF.(lip).Median_MR;
             
    A.(date).r1.(lip).MC_Median=median( A.(date).r1.(lip).MC);
    A.(date).r1.(lip).MC_STD=std( A.(date).r1.(lip).MC);
end    
    



end
