function [iret,H,ynotused,C,opt]=simostationarityengine(y,Ts,f,refch,Ncyc,Ct,H0,opt)
%%SIMOSTATIONARITYENGINE
%Inputs: y     -
%        Ts
%        f
%        refch
%        Ncyc
%        Ct    - Treshold for correlation coefficient
%        H0
%        opt   - Optional data. opt.A is LS fitting matrix
%Output: iret  - 0 if stationarity found, -1 if not 
%        H     - Transfer function estimate of last evaluated block
%        ynotused  - The data not used after a premature exit
%        opt   - opt.A gives LS fitting matrix
%Call:   [iret,H,ynotused,opt]=simostationarityengine(y,Ts,f,refch,...
%                                                     Ncyc,Ct,H0,opt)

%Copyleft: 2015-04-25, Thomas Abrahamsson, Chalmers University of Technology

%% 
global plotK Xsave Xsave_

if nargin<6, Ct=0.999;end

%%                                                                 Initiate
[ny,nt]=size(y);nf=length(f);
if ny<2,error('At least two signals need to be in y');end
Nblock=ceil(Ncyc/Ts/min(f));
indu=refch;indy=setdiff(1:ny,indu);

if size(y,2)<Nblock
  iret=-1;
  ynotused=y;
  if nargin<7
     H(ny-1,1,nf)=0;
  else
     H=H0;
  end 
  C=0;
  opt=[];
  return
end  

%%                                                    Initial call to get A
if nargin<8
  [~,~,yl,A]=harmcoeff(y(:,1:1+Nblock-1),Ts,f);
  opt.A=A;
end  

%%                                                                  Do work
if nargin<7, H0(ny-1,1,nf)=0;end
K=0;iret=0;ynotused=[];
while 1,  
  Kdata=[1:Nblock]+K*Nblock;
  if Kdata(end)>nt
    iret=-1;
    C=1;
    ynotused=y(:,K*Nblock+1:end);
  else
    K=K+1; plotK = plotK + 1;
    %if K == 1
    %    keyboard
    %end
    [c,yr,yl]=harmcoeff(y(:,Kdata),Ts,f,opt);
    cu=repmat(c(:,indu),1,length(indy));
    H(:,1,:)=(c(:,indy)./cu).';
    
%     for J=1:ny-1
%       H(J,1,:)=c(:,indy(J))./c(:,indu);
%     end
    nH=norm(H(:),'inf');nH0=norm(H0(:),'inf');
    nmax=max([nH nH0]);nmin=min([nH nH0]);
    C=(nmin/nmax)*sqrt(mac(H(:),H0(:)));
    H0=H;
    Xsave = [Xsave (nmin/nmax)];
    
    %Xsave = [Xsave yr];
    %Xsave_ = [Xsave_ (y(:,Kdata))];
    %figure(10)
    %plotKData = [1:Nblock]+plotK*Nblock;
    %plot(plotKData,y(2,Kdata) - mean(y(2,Kdata)),'b');
    %hold on;
    %plot(plotKData,yr(2,:),'r');
    %title([num2str(C), ' ', num2str(plotK)])
    
    %figure(11)
    %plotKData = [1:Nblock]+plotK*Nblock;
    %plot(plotKData,y(1,Kdata) - mean(y(1,Kdata)),'b');
    %hold on;
    %plot(plotKData,yr(1,:),'r');
  end
  if C>Ct
      if iret == 0
        abs(H(1,1,1))
      end
    %if iret==0,keyboard,end
    break
  end
end

