function[result] = f(a)
 if  a>(24/116)^3
     result = a^(1/3);
 end
 
 if a<=(24/116)^3
     result= 841*a/108+16/116;
 end
 
