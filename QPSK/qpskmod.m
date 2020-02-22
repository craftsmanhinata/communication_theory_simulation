% qpskmod.m
%
% Function to perform QPSK modulation
%
% Programmed by H.Harada
%
function [iout,qout]=qpskmod(paradata,para,nd,ml)
%****************** variables *************************
% paradata : input data (para-by-nd matrix)
% iout :output Ich data
% qout :output Qch data
% para : Number of paralell channels,
% nd : Number of data
% ml : Number of modulation levels
% (QPSK ->2 16QAM -> 4)
% *****************************************************

m2=ml./2;

paradata2=paradata.*2-1;%输入数据从0、1序列 -> +1和-1的双极性码
count2=0;

for jj=1:nd  %遍历每个码元
    
	isi = zeros(para,1);
	isq = zeros(para,1);

	for ii = 1:m2
		isi = isi + 2.^(m2-ii).*paradata2((1:para),ii+count2);
		isq = isq + 2.^(m2-ii).*paradata2((1:para),m2+ii+count2);	
	end

	iout((1:para),jj) = isi;
	qout((1:para),jj) = isq;
	
	count2 = count2+ml;
end
%******************** end of file ***************************