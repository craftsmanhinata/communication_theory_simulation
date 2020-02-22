% compconv.m
%
% Function to perform convolution between signal and filter
%
% programmed by H.Harada and M.Okita
%
function [iout, qout] = compconv(idata, qdata, filter)

% **************************************************************** 
%idata: ich data sequcence
%qdata: qch data sequcence
%?? filter????? : filter tap coefficience
% **************************************************

iout = conv(idata,filter);
qout = conv(qdata,filter);
%******************** end of file ***************************