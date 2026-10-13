%% Slapping data cleaning

% Filter specifications: a second-order recursive, bidirectional Butterworth filter at 50 Hz.
order = 2;        % Second-order filter
fs = 120;         % Sampling frequency in Hz
fc = 10;          % Cutoff frequency in Hz

velcrit=0.0005;
filestart=0;
pnum=[12 13 15:22 25:34 36:42 51:54];
for p=7:31;
%for p = 2
    filename=strcat('/Users/heatherneyedli/Documents/Experiments/Dontspillmybeer/Slapping/Data/',int2str(pnum(p)),'/testing/P',int2str(pnum(p)),'_rawdata.mat');
    load(filename)
 
    for i = 1:height(data)
        data.StartJ(i)=0;
        data.EndJ(i)=0;
        
        %Extract Trajecotry
        trajx= -data.xpos{i};
        trajy= data.ypos{i};
        trajz= data.zpos{i};
        
        triallength=size(trajx);
        test(i)=triallength(1,1)/10;
        if triallength(1,1)>1;
            for j=1:10 %separate makers in columns
                for k=1:triallength(1,1)/10;
                    trajxx(k,j)=trajx(k*10-j+1);
                    trajyy(k,j)=trajy(k*10-j+1);
                    trajzz(k,j)=trajz(k*10-j+1);
                end
            end
            
            data.allmarkersx{i}=trajxx;
            data.allmarkersy{i}=trajyy;
            data.allmarkersz{i}=trajzz;
            
            trajx_mean = mean(trajxx, 2);
            trajy_mean = mean(trajyy, 2);
            trajz_mean = mean(trajzz, 2);
            
            trajx_smooth = trajx_mean-trajx_mean(1);
            trajy_smooth = trajy_mean-trajy_mean(1);
            trajz_smooth = trajz_mean-trajz_mean(1);
            
            
            % Compute filter coefficients
            [b, a] = butter(order, fc /(fs / 2), 'low');
            %[b, a] = butter(order, 50/200/2, 'low');
            ba_filtered_trajx = filtfilt(b,a,trajx_smooth);
            trajx_filt = (ba_filtered_trajx);
            
            ba_filtered_trajy = filtfilt(b,a,trajy_smooth);
            trajy_filt = (ba_filtered_trajy);
            
            ba_filtered_trajz = filtfilt(b,a,trajz_smooth);
            trajz_filt = (ba_filtered_trajz);
            
            %Compute Velocity
            vx=diff(trajx_filt);
            vy=diff(trajy_filt);
            vz=diff(trajz_filt);
            
            
            %  keep same length as original
            vx = [vx; NaN];   % pad to match length
            vy = [vy; NaN];
            vz = [vz; NaN];
            
            
            %Compute Acceleration
            ax=diff(vx);
            ay=diff(vy);
            az=diff(vz);
            
            %Compute Jerk
            jx=diff(ax);
            jy=diff(ay);
            jz=diff(az);
            
            %  keep same length as original
            jx = [jx; NaN];   % pad to match length
            jy = [jy; NaN];
            jz = [jz; NaN];
            
            %  keep same length as original
            ax = [ax; NaN];   % pad to match length
            ay = [ay; NaN];
            az = [az; NaN];
            
            % Find start of movementplot
            Started = 0;
            Ended = 0;
            for j=5:triallength/10;
                if (vy(j))>velcrit && (vy(j-1))>velcrit && (vy(j-2))>velcrit && Started==0
                    data.StartJ(i)=j-1;
                    Started=1;
                end
                if Started == 1 && Ended==0 && (vy(j))< velcrit && (vy(j-1))<velcrit && (vy(j-2))<velcrit && (vy(j-3))<velcrit && (vy(j-4))<velcrit && (vy(j-5))<velcrit
                    data.EndJ(i)=j-1;
                    Ended=1;
                    
                end
                
            end
            if data.StartJ(i)>0 && data.EndJ(i)>0;
                % Store result truncated at movement start end end
                data.Xacc{i} = ax(data.StartJ(i):data.EndJ(i));
                data.Yacc{i} = ay(data.StartJ(i):data.EndJ(i));
                data.Zacc{i} = az(data.StartJ(i):data.EndJ(i));
                data.XVelkeep{i} = vx(data.StartJ(i):data.EndJ(i));
                data.YVelkeep{i} = vy(data.StartJ(i):data.EndJ(i));
                data.ZVelkeep{i} = vz(data.StartJ(i):data.EndJ(i));
                data.Xjerk{i} = jx(data.StartJ(i):data.EndJ(i));
                data.Yjerk{i} = jy(data.StartJ(i):data.EndJ(i));
                data.Zjerk{i} = jz(data.StartJ(i):data.EndJ(i));
                
                
                data.XPos_clean{i} = trajx_filt(data.StartJ(i):data.EndJ(i));
                data.YPos_clean{i} = trajy_filt(data.StartJ(i):data.EndJ(i));
                data.ZPos_clean{i} = trajz_filt(data.StartJ(i):data.EndJ(i));
            end
            
            %         %Store result whole collection
            %             data.Xacc{i} = ax;
            %             data.Yacc{i} = ay;
            %             data.Zacc{i} = az;
            %             data.XVelkeep{i} = vx;
            %             data.YVelkeep{i} = vy;
            %             data.ZVelkeep{i} = vz;
            %             data.Xjerk{i} = jx;
            %             data.Yjerk{i} = jy;
            %             data.Zjerk{i} = jz;
            %
            %
            %             data.XPos_clean{i} = trajx_filt;
            %             data.YPos_clean{i} = trajy_filt;
            %             data.ZPos_clean{i} = trajz_filt;
            
            
        end
    end
    p
    rows1 = 7:66;
    rows2 = 73:132;
    rows3 = 139:198;
    rows4 = 205:264;
    for i=rows1;
        if strcmp(data.target_loc{i}, 'left')
            subplot(1,4,1)
            plot(data.XPos_clean{i},data.YPos_clean{i},'r');
            hold on
        else if strcmp(data.target_loc{i}, 'right')
                subplot(1,4,1)
                plot(data.XPos_clean{i},data.YPos_clean{i},'g');
                hold on
            else
                subplot(1,4,1)
                plot(data.XPos_clean{i},data.YPos_clean{i},'b');
                hold on
            end
        end
        
    end
    
    for i=rows2;
        if strcmp(data.target_loc{i}, 'left')
            subplot(1,4,2)
            plot(data.XPos_clean{i},data.YPos_clean{i},'r');
            hold on
        else if strcmp(data.target_loc{i}, 'right')
                subplot(1,4,2)
                plot(data.XPos_clean{i},data.YPos_clean{i},'g');
                hold on
            else
                subplot(1,4,2)
                plot(data.XPos_clean{i},data.YPos_clean{i},'b');
                hold on
            end
        end
        
    end
    
    for i=rows3;
        if strcmp(data.target_loc{i}, 'left')
            subplot(1,4,3)
            plot(data.XPos_clean{i},data.YPos_clean{i},'r');
            hold on
        else if strcmp(data.target_loc{i}, 'right')
                subplot(1,4,3)
                plot(data.XPos_clean{i},data.YPos_clean{i},'g');
                hold on
            else
                subplot(1,4,3)
                plot(data.XPos_clean{i},data.YPos_clean{i},'b');
                hold on
            end
        end
        
    end
    
    for i=rows4;
        if strcmp(data.target_loc{i}, 'left')
            subplot(1,4,4)
            plot(data.XPos_clean{i},data.YPos_clean{i},'r');
            hold on
        else if strcmp(data.target_loc{i}, 'right')
                subplot(1,4,4)
                plot(data.XPos_clean{i},data.YPos_clean{i},'g');
                hold on
            else
                subplot(1,4,4)
                plot(data.XPos_clean{i},data.YPos_clean{i},'b');
                hold on
            end
        end
       
    end
    ginput(1);
    close Figure 1
    if p == 4 || p==5 || p==6
        data.response_time=str2double(data.response_time);
    end
    cd ('/Users/heatherneyedli/Documents/Experiments/Dontspillmybeer/Slapping/Data/');
    savepfilename=strcat('P',int2str(pnum(p)),'_cleandata.mat');
    save (savepfilename, 'data')
%     if filestart == 0
%         LongFormResults=data;
%         filestart = 1;
%     else
%         LongFormResults=[LongFormResults; data];
%     end
%     
end

%%
% rows1 = 7:66;
% rows2 = 73:132;
% rows3 = 139:198;
% rows4 = 205:264;
% for i=rows1;
%     if strcmp(data.target_loc{i}, 'left')
%         plot(data.XPos_clean{i},data.YPos_clean{i},'r');
%         hold on
%     else if strcmp(data.target_loc{i}, 'right')
%
%             plot(data.XPos_clean{i},data.YPos_clean{i},'g');
%             hold on
%         else
%
%             plot(data.XPos_clean{i},data.YPos_clean{i},'b');
%             hold on
%         end
%     end
%
% end
% figure
% for i=rows2;
%     if strcmp(data.target_loc{i}, 'left')
%         plot(data.XPos_clean{i},data.YPos_clean{i},'r');
%         hold on
%     else if strcmp(data.target_loc{i}, 'right')
%
%             plot(data.XPos_clean{i},data.YPos_clean{i},'g');
%             hold on
%         else
%
%             plot(data.XPos_clean{i},data.YPos_clean{i},'b');
%             hold on
%         end
%     end
%
% end
% figure
% for i=rows3;
%     if strcmp(data.target_loc{i}, 'left')
%         plot(data.XPos_clean{i},data.YPos_clean{i},'r');
%         hold on
%     else if strcmp(data.target_loc{i}, 'right')
%
%             plot(data.XPos_clean{i},data.YPos_clean{i},'g');
%             hold on
%         else
%
%             plot(data.XPos_clean{i},data.YPos_clean{i},'b');
%             hold on
%         end
%     end
%
% end
% figure
% for i=rows4;
%     if strcmp(data.target_loc{i}, 'left')
%         plot(data.XPos_clean{i},data.YPos_clean{i},'r');
%         hold on
%     else if strcmp(data.target_loc{i}, 'right')
%
%             plot(data.XPos_clean{i},data.YPos_clean{i},'g');
%             hold on
%         else
%
%             plot(data.XPos_clean{i},data.YPos_clean{i},'b');
%             hold on
%         end
%     end
%
% end

%%

% for i=1:264
% %     if strcmp(data.hand_used{i}, 'right') && strcmp(data.side_used{i},'back');
% %         plot(data.XPos_clean{i},data.YPos_clean{i},'r');
% %         hold on
% %     elseif strcmp(data.hand_used{i}, 'right') && strcmp(data.side_used{i},'front');
% %         plot(data.XPos_clean{i},data.YPos_clean{i},'m');
% %         hold on
%     if strcmp(data.hand_used{i}, 'left') && strcmp(data.side_used{i},'back');
%         plot(data.XPos_clean{i},data.YPos_clean{i},'b');
%         hold on
%     elseif strcmp(data.hand_used{i}, 'left') && strcmp(data.side_used{i},'front');
%         plot(data.XPos_clean{i},data.YPos_clean{i},'c');
%         hold on
%     end
% end

