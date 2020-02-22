% compoversamp.m  
%  
% Insert zero data to Ich and Qch input data  
%  
% programmed by H.Harada  
%  
function [iout,qout] = compoversamp( idata, qdata , nsymb , sample)   
%****************** variables *************************  
% idata : input Ich data  
% qdata : input Qch data  
% iout : output Ich data  
% qout : output Qch data  
% nsymb   : Number of burst symbol  
% sample : Number of oversample  
% *****************************************************  
  
iout=zeros(1,nsymb*sample);  
qout=zeros(1,nsymb*sample);  
iout(1:sample:1+sample*(nsymb-1))=idata;  
qout(1:sample:1+sample*(nsymb-1))=qdata;  
%******************** end of file *************************** 