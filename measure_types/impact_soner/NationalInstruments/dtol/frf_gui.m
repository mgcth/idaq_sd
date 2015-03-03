function frf_gui(t,y,freq,FRF,stdFRF,RN,RH,RS)
%FRF_GUI
%Alt 1:  
%         No input parameters will do an initialization
%Alt 2:
%Inputs:  t
%         y
%         freq   - The frequencies stepped through
%         FRF    - The corresponding FRF data
%         stdFRF - The standard deviation of given FRF
%         RN     - Residual noise
%         RH     - Residual harmonic distorsion
%         RS     - Residual lack of stationarity
%Call:    frf_gui(freq,FRF,stdFRF,RN,RH,RS)

%Copyright: Applied Mechanics, Chalmers University of Technology
%Written:  October 28, 2010/TA

%% ------------------------------------------------------------------------
%                                                                    Global
%                                                                    ------
global CH HFRFGUI

if nargin==0
  HFRFGUI.hFigfd=figure;clf; % FRF window
  set(HFRFGUI.hFigfd,'Position',[5 368 710 440],'Number','off',...
                                    'Name','FRF window','Visible','on');
  HFRFGUI.hFigtd=figure;clf; % Time data window
  set(HFRFGUI.hFigtd,'Position',[728 368 710 440],'Number','off',...
                  'Name','Time window','Visible','on','MenuBar','None');
  HFRFGUI.TWpos=get(HFRFGUI.hFigtd,'Position');
  HFRFGUI.hFigdd=figure;clf; % Distorsion window
  set(HFRFGUI.hFigdd,'Position',[728 40 712 285],'Number','off',...
            'Name','Distorsion window','Visible','on','MenuBar','None');
  HFRFGUI.DWpos=get(HFRFGUI.hFigdd,'Position');

 
%%                                                                Start GUI
%sssGUI(setdiff(CH.active,CH.refch));
sssGUI(CH.active);
     
else
%%                                                    Create current legend
  ind=get(HFRFGUI.LB(1:3),'Value');
  chplot=[];
  for I=1:3
    if ind{I}>1
        str=get(HFRFGUI.LB(I),'String');        
        chplot=[chplot;str2num(str{ind{I}})];
    end
  end    
  Legend=[];
  for I=1:length(chplot)
      Legend{I}=['ch# ' int2str(chplot(I))];
  end
   
%%                                                   Create plot quantities   
  nf=size(FRF,2);
  freq=freq(1:nf);freq3=[freq(:);freq(:);freq(:)];freq3=sort(freq3); 
  for III=nf:-1:1
       FRFstd(:,(III-1)*3+1)=(abs(FRF(:,III))-stdFRF(:,III)) ...
                                             .*FRF(:,III)./abs(FRF(:,III));
       FRFstd(:,(III-1)*3+2)=(abs(FRF(:,III))+stdFRF(:,III)) ...
                                             .*FRF(:,III)./abs(FRF(:,III));
       FRFstd(:,(III-1)*3+3)=NaN*FRF(:,III);
  end
  
%%                                                                     Plot

%%                                              FRF/Bode/Nyquist/Multiorder
  plotopt=get(HFRFGUI.RB(1:4),'Value');
  if plotopt{1}; % FRF plot
     figure(HFRFGUI.hFigfd);clf
     semilogy(freq3,abs(FRFstd(chplot,:))','k')
     hold on
     semilogy(freq,abs(FRF(chplot,:))')
     hold off
     legend(Legend)
  elseif plotopt{2}; % Bode plot  
     figure(HFRFGUI.hFigfd);clf
     magphase(freq_seq,FRF(chplot(1),:));
     legend(Legend{1})
  elseif plotopt{3}; % Nyquist plot
     figure(HFRFGUI.hFigfd);clf
     plot(real(FRF(chplot(1),:)),imag(FRF(chplot(1),:)));
     axis equal
     legend(Legend{1})
  else plotopt{4};   % Multiorder FRF plot  
  end
  
%%                                                                Time data
  if get(HFRFGUI.RB(5),'Value')
     figure(HFRFGUI.hFigtd);clf
     plot(t,y(:,chplot));
     legend(Legend)
  end
  
%%                                                                Residuals
  if get(HFRFGUI.RB(6),'Value')
     figure(HFRFGUI.hFigdd)
     set(gcf,'Position',HFRFGUI.DWpos,'MenuBar','None');
     semilogy(freq,RN(chplot(1),:),freq,RH(chplot(1),:),...
                                                      freq,RS(chplot(1),:))
     legend('Relative noise residual','Relative harmonic distorsion',...
         'Relative lack of stationarity')
     grid
  else
     try
       HGUI.DWpos=get(HFRFGUI.hFigdd,'Position');
       close(HFRFGUI.hFigdd)
     catch,end
  end
end

%%                                                   Helper function sssGUI
function sssGUI(ind)
global HFRFGUI
HFRFGUI.Fig=figure;
set(HFRFGUI.Fig,'MenuBar','None','NumberTitle','Off', ...
                 'Name','Simo Stepped Sine GUI','Position',[5 135 500 150])
uicontrol(HFRFGUI.Fig,'Style','Frame','Position',[19 19 152 22])
uicontrol(HFRFGUI.Fig,'Style','Frame','Position',[19 39 152 22])
uicontrol(HFRFGUI.Fig,'Style','Frame','Position',[19 59 152 82])
Callbackstr='global HFRFGUI,Hrb=gcbo;ind=find(HFRFGUI.RB==Hrb);set(HFRFGUI.RB(1:4),''Value'',0),set(HFRFGUI.RB(ind),''Value'',1)';
HFRFGUI.RB(1)=uicontrol(HFRFGUI.Fig,'Style','Radio','String','FRF Plot',...
               'Value',1,'Position',[20 120 150 18],'Callback',Callbackstr);
HFRFGUI.RB(2)=uicontrol(HFRFGUI.Fig,'Style','Radio','String','Bode Plot',...
               'Value',0,'Position',[20 100 150 18],'Callback',Callbackstr);
HFRFGUI.RB(3)=uicontrol(HFRFGUI.Fig,'Style','Radio','String','Nyquist Plot',...
                'Value',0,'Position',[20 80 150 18],'Callback',Callbackstr);
HFRFGUI.RB(4)=uicontrol(HFRFGUI.Fig,'Style','Radio','String','Multiorder FRF Plot',...
                'Value',0,'Position',[20 60 150 18],'Callback',Callbackstr);
HFRFGUI.RB(5)=uicontrol(HFRFGUI.Fig,'Style','Radio','String','Plot Time Data',...
                                      'Value',1,'Position',[20 40 150 18]);
HFRFGUI.RB(6)=uicontrol(HFRFGUI.Fig,'Style','Radio','String','Plot Distorsion',...
                                      'Value',1,'Position',[20 20 150 18]);

uicontrol(HFRFGUI.Fig,'Style','Frame','Position',[179 19 82 122])
uicontrol(HFRFGUI.Fig,'Style','Frame','Position',[279 19 82 122])
uicontrol(HFRFGUI.Fig,'Style','Frame','Position',[379 19 82 122])
                                  
ListBoxString{1}='None';for I=1:length(ind),ListBoxString{I+1}=int2str(ind(I));end
HFRFGUI.LB(1)=uicontrol(HFRFGUI.Fig,'Style','Listbox','String',ListBoxString,...
                                      'Value',2,'Position',[180 20 80 90]);
HFRFGUI.LB(2)=uicontrol(HFRFGUI.Fig,'Style','Listbox','String',ListBoxString,...
                                      'Value',1,'Position',[280 20 80 90]);
HFRFGUI.LB(3)=uicontrol(HFRFGUI.Fig,'Style','Listbox','String',ListBoxString,...
                                      'Value',1,'Position',[380 20 80 90]);

uicontrol(HFRFGUI.Fig,'Style','Text','String','Curve 1 ch#','Position',[180 120 80 20]);
uicontrol(HFRFGUI.Fig,'Style','Text','String','Curve 2 ch#','Position',[280 120 80 20]);
uicontrol(HFRFGUI.Fig,'Style','Text','String','Curve 3 ch#','Position',[380 120 80 20]);

drawnow