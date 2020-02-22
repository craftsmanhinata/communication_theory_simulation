% qpskdemod.m
%
% Function to perform QPSK demodulation
%
% programmed by H.Harada
%
function [demodata]=qpskdemod(idata,qdata,para,nd,ml)
%****************** variables *************************
% idata :input Ich data
% qdata :input Qch data
% demodata: demodulated data (para-by-nd matrix)
% para   : Number of paralell channels
% nd : Number of data
% ml : Number of modulation levels
% (QPSK ->2  16QAM -> 4)
% *****************************************************
demodata=zeros(para,ml*nd);
%��������ͼ
scatter(idata((1:para),(1:nd)),qdata((1:para),(1:nd)),'.');
axis([-2 2 -2 2]);

demodata((1:para),(1:ml:ml*nd-1))=idata((1:para),(1:nd))>=0;
demodata((1:para),(2:ml:ml*nd))=qdata((1:para),(1:nd))>=0;
%��Ϊ��ʱ��ɵĴ��������ڽ����ʱ��Ҳ����
%******************** end of file **********************