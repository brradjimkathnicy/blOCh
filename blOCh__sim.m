function varargout = blOCh__sim(Fun,spc,khr,opt,varargin)
% function [sim,Msg] = blOCh__sim(spc,khr,opt,varargin)
%
%   This script simulates an output from blOCh
%
%
%
%     Copyright (C) 2017  Mads Sloth Vinding
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
%

if isempty(Fun)
    warning off
    Status = 0;
    varargout{1} = -1;
    
    if spc.pTx > 1
        valid_sim_Txs = {'all','sep'};
        def_sim_Tx = valid_sim_Txs{1};
        
    else
        valid_sim_Txs = {'all'};
        def_sim_Tx = valid_sim_Txs{1};
    end
    
    valid_sim_ks = {'last','all','firstlast'};
    def_sim_k = valid_sim_ks{1};
    
    valid_sim_ns = {'last','all'};
    def_sim_n = valid_sim_ns{1};
    
    valid_opt_ns = {'opt1','opt2'};
    def_opt_n = 'opt1';
    valid_sim_Rlxs = [1,0];
    def_sim_Rlx = valid_sim_Rlxs(2);
    
    valid_Shows = [1,0];
    def_Show = valid_Shows(1);
    

    
    valid_SaveFigs = [1,0];
    def_SaveFig = valid_SaveFigs(1);
    
    valid_Nuc      = {'1H','13C','19F'};
    
    def_Nuc = '1H';
    def_B1inhom_lim = [1,1];
    def_B1inhom_N = 1;
    def_B0inhom_lim = [0;0];
    def_B0inhom_N = 1;
    def_dt  = [];
    def_u = [];
    def_v = [];
    def_g = [];
    
    p = inputParser;
    
    try p.addRequired('Fun', @(x)isstruct(x)||isempty(x));
        try p.addRequired('spc', @(x)isstruct(x));
            try p.addRequired('khr', @(x)isstruct(x)||isempty(x));
                try p.addRequired('opt', @(x)isstruct(x)||isempty(x));
                    try p.addParamValue('opt_n',def_opt_n,@(x)any(valid_opt_ns));
                        try p.addParamValue('sim_Rlx',def_sim_Rlx,@(x)any(valid_sim_Rlxs));
                            try p.addParamValue('sim_Tx',def_sim_Tx,@(x)any(strcmpi(x,valid_sim_Txs)));
                                try p.addParamValue('sim_k',def_sim_k,@(x)Validate_ks(x));
                                    try p.addParamValue('sim_n',def_sim_n,@(x)any(strcmpi(x,valid_sim_ns))); % ||validateattributes(x,{'numeric'},{'size',[1,1],'real','integer','>=',1,'<=',opt.N})
                                        try p.addParamValue('Show',def_Show,@(x)any(valid_Shows));
                                            
                                            try p.addParamValue('B1inhom_lim',def_B1inhom_lim,@(x)validateattributes(x,{'numeric'},{'size',[1,2],'real','>=',0,'<=',2}));
                                                try p.addParamValue('B1inhom_N',def_B1inhom_N,@(x)validateattributes(x,{'numeric'},{'size',[1,1],'real','>=',1,'real','finite'}));
                                                    try p.addParamValue('B0inhom_lim',def_B0inhom_lim,@(x)validateattributes(x,{'numeric'},{'size',[1,2],'real','finite'}));
                                                        try p.addParamValue('B0inhom_N',def_B0inhom_N,@(x)validateattributes(x,{'numeric'},{'size',[1,1],'real','>=',1,'real','finite'}));
                                                            
                                                            try p.addParamValue('dt',def_dt,@(x)validateattributes(x,{'numeric'},{'size',[NaN,NaN],'real','finite','>',0}));
                                                                try p.addParamValue('u',def_u,@(x)validateattributes(x,{'numeric'},{'size',[NaN,NaN,NaN],'real','finite'}));
                                                                    try p.addParamValue('v',def_v,@(x)validateattributes(x,{'numeric'},{'size',[NaN,NaN,NaN],'real','finite'}));
                                                                        try p.addParamValue('g',def_g,@(x)validateattributes(x,{'numeric'},{'size',[NaN,NaN,NaN],'real','finite'}));
                                                                            try p.addParamValue('Nuc',def_Nuc,@(x)any(strcmpi(x,valid_Nuc)));
                                                                                try p.addParamValue('SaveFig',def_SaveFig,@(x)any(valid_SaveFigs));
                                                                                        Status = 1;
                                                                                    
                                                                                catch  me;Display_Message(['blOCh__sim: ',me.message],2);end
                                                                            catch  me;Display_Message(['blOCh__sim: ',me.message],2);end
                                                                        catch  me;Display_Message(['blOCh__sim: ',me.message],2);end
                                                                    catch  me;Display_Message(['blOCh__sim: ',me.message],2);end
                                                                catch  me;Display_Message(['blOCh__sim: ',me.message],2);end
                                                            catch  me;Display_Message(['blOCh__sim: ',me.message],2);end
                                                            
                                                        catch  me;Display_Message(['blOCh__4_0__sim: ',me.message,' B0inhom_N: Resolution to simulate B0 inhomogeneity in'],2);end
                                                    catch  me;Display_Message(['blOCh__4_0__sim: ',me.message,' B0inhom_lim: should be a [a,b] array of units Hz like [-200,200] to simulate RF inhomogeneity from -200 Hz to 200 Hz'],2);end
                                                catch  me;Display_Message(['blOCh__4_0__sim: ',me.message,' B1inhom_N: Resolution to simulate RF inhomogeneity in'],2);end
                                            catch  me;Display_Message(['blOCh__4_0__sim: ',me.message,' B1inhom_lim: should be a [a,b] array like [0.9,1.1] to simulate RF inhomogeneity of 90% to 110%'],2);end
                                        catch  me;Display_Message(['blOCh__sim: ',me.message],2);end
                                    catch  me;Display_Message(['blOCh__sim: ',me.message],2);end
                                catch  me;Display_Message(['blOCh__sim: ',me.message],2);end
                            catch  me;Display_Message(['blOCh__sim: ',me.message,' sim_n: the time frame(s) the simulation stores; ''last'', ''all'', or # (number of dt between frames)'],2); end
                        catch  me;Display_Message(['blOCh__sim: ',me.message,' sim_k: the iteration(s) the simulation does; ''last'', ''all'', ''firstlast'', or # (a specific iteration)'],2); end
                    catch  me;Display_Message(['blOCh__sim: ',me.message,' sim_Tx:'],2);end
                catch  me;Display_Message(['blOCh__sim: ',me.message,' sim_Rlx:'],2);end
            catch  me;Display_Message(['blOCh__sim: ',me.message],2);end
        catch  me;Display_Message(['blOCh__sim: ',me.message],2);end
    catch  me;Display_Message(['blOCh__sim: ',me.message],2);end
    
    if Status
        try
            p.parse(Fun,spc,khr,opt,varargin{:})
            
            sim.sim_n = p.Results.sim_n;
            sim.opt_n = p.Results.opt_n;
            sim.sim_Tx = p.Results.sim_Tx;
            sim.sim_k = p.Results.sim_k;
            sim.sim_Rlx = p.Results.sim_Rlx;
            sim.Show = p.Results.Show;
            sim.SaveFig = p.Results.SaveFig;
            
            sim.B1inhom_lim = p.Results.B1inhom_lim;
            sim.B1inhom_N = p.Results.B1inhom_N;
            sim.B0inhom_lim = p.Results.B0inhom_lim;
            sim.B0inhom_N = p.Results.B0inhom_N;
            
            
            sim.temp.u = p.Results.u;
            sim.temp.v = p.Results.v;
            sim.temp.g = p.Results.g;
            sim.temp.dt = p.Results.dt;
            sim.temp.Nuc = p.Results.Nuc;
            switch sim.sim_Tx
                case 'all'
                    sim.S = 1;
                    sim.s = 1;
                case 'sep'
                    sim.S = spc.pTx+1;
                    sim.s = [1:sim.S];
            end
            
        catch me
            Display_Message(['blOCh__sim: ',me.message],2)
            
        end
        
        if ~isempty(opt) && ~isempty(khr)
            
            if isdef(varargin,'g')
                Display_Message(sprintf('blOCh__sim: both khr and g were specified. g will be ignored'),1);
            end
            if isdef(varargin,'u') || isdef(varargin,'v')
                Display_Message(sprintf('blOCh__sim: both opt and u or v were specified. u,v will be ignored'),1);
            end
            if isdef(varargin,'dt')
                Display_Message(sprintf('blOCh__sim: both opt and dt were specified. dt will be ignored'),1);
            end
            if isdef(varargin,'Nuc')
                Display_Message(sprintf('blOCh__sim: both khr and Nuc were specified. Nuc will be ignored'),1);
            end
            
            if strcmp(sim.opt_n,'opt1')
                sim.uo = opt.opt1.uo;
                sim.vo = opt.opt1.vo;
                Kact = opt.opt1.ksafe;
                sim.MaxIter = opt.opt1.MaxIter;
                sim.mon = opt.opt1.mon;
                sim.g = opt.opt1.g;
                
                sim.OptNum = 1;
            elseif strcmp(sim.opt_n,'opt2')
                sim.uo = opt.opt2.uo;
                sim.vo = opt.opt2.vo;
                Kact = opt.opt2.ksafe;
                sim.MaxIter = opt.opt2.MaxIter;
                sim.mon = opt.opt2.mon;
                sim.g = opt.opt2.g;
                
                sim.OptNum = 2;
            end
            sim.dt = opt.dt;
            
            Nact = opt.N;
            
        elseif isempty(opt) && ~isempty(khr)
            
            if isdef(varargin,'g')
                Display_Message(sprintf('blOCh__sim: both khr and g were specified. g will be ignored'),1);
            end
            if isdef(varargin,'u') && isdef(varargin,'v')
                Display_Message(sprintf('blOCh__sim: both u and v were specified. '),1);
            elseif isdef(varargin,'u') && ~isdef(varargin,'v')
                Display_Message(sprintf('blOCh__sim: only u was specified. Aborting '),2);
                return
            elseif ~isdef(varargin,'u') && isdef(varargin,'v')
                Display_Message(sprintf('blOCh__sim: only v was specified. Aborting '),2);
                return
            end
            if isdef(varargin,'dt')
                Display_Message(sprintf('blOCh__sim: dt was specified.'),1);
            end
            if isdef(varargin,'Nuc')
                Display_Message(sprintf('blOCh__sim: both khr and Nuc were specified. Nuc will be ignored'),1);
            end
            
            
%             sim.dt = sim.temp.dt; % bug 170309
            sim.dt = khr.dt;
            sim.uo = sim.temp.u;
            sim.vo = sim.temp.v;
            sim.Nuc = khr.Nuc;
            Nact = size(sim.uo,2);
            Kact = size(sim.uo,3);
            sim.MaxIter = Kact-1;
            sim.N = Nact;
            sim.OptNum = 1;
            sim.Mask = 0;
            sim = blOCh__opt('Prepare_khr_4_opt',[],[],[],[],sim,khr);
            
            
        elseif isempty(opt) && isempty(khr)
            
            if isdef(varargin,'g')
                Display_Message(sprintf('blOCh__sim: g was specified.'),1);
            else
                Display_Message(sprintf('blOCh__sim: g needs to be specified. Aborting '),2);
                return
            end
            if isdef(varargin,'u') && isdef(varargin,'v')
                Display_Message(sprintf('blOCh__sim: both u and v were specified. '),1);
            elseif isdef(varargin,'u') && ~isdef(varargin,'v')
                Display_Message(sprintf('blOCh__sim: only u was specified. Aborting '),2);
                return
            elseif ~isdef(varargin,'u') && isdef(varargin,'v')
                Display_Message(sprintf('blOCh__sim: only v was specified. Aborting '),2);
                return
            end
            if isdef(varargin,'dt')
                Display_Message(sprintf('blOCh__sim: dt was specified.'),1);
            else
                Display_Message(sprintf('blOCh__sim: dt needs to be specified. Aborting '),2);
                return
            end
            if isdef(varargin,'Nuc')
                Display_Message(sprintf('blOCh__sim: Nuc was specified. '),1);
            else
                Display_Message(sprintf('blOCh__sim: Nuc wasn''t specified. Assuming it''s 1H'),1);
                
            end
            
            
            
            
            
            sim.dt = sim.temp.dt;
            sim.g = sim.temp.g;
            sim.uo = sim.temp.u;
            sim.vo = sim.temp.v;
            sim.Nuc = sim.temp.Nuc;
            Nact = size(sim.uo,2);
            Kact = size(sim.uo,3);
            sim.MaxIter = 1;
            sim.OptNum = 1;
            sim.mon = true(1,Nact);
            %             khr.Nuc = sim.Nuc;
            switch sim.Nuc
                case '1H'
                    sim.gamma = 2.6751289e8;
                case '13C'
                    sim.gamma = 67.262e6;
                case '19F'
                    sim.gamma = 251.662e6;
            end
            khr.gamma = sim.gamma;
            khr.GmHW = 1;
            khr.Gmpct = 1;
            khr.SmHW = 1;
            khr.Smpct = 1;
            
        end
        
        switch sim.sim_n
            
            case 'last'
                sim.M = 1;
                sim.N = Nact;
            case 'all'
                sim.M = Nact+1;
                sim.N = Nact;
                
        end
        
        
        switch sim.sim_k
            
            case 'last'
                sim.K = 1;
                sim.k = Kact;
            case 'all'
                sim.K = Kact;
                sim.k = [1:Kact];
            case 'firstlast'
                sim.K =  2;
                sim.k = [1,Kact];
            otherwise
                sim.K = 1;
                sim.k = sim.sim_k;
        end
        
        
        if sim.sim_Rlx == 1
            sim.Rlx = 1;
        else
            sim.Rlx = 0;
        end
        
        sim.M_t_big = zeros(3*spc.P,sim.M,sim.K,sim.S,sim.B1inhom_N,sim.B0inhom_N);
        
        if exist('blOCh__Get_Relaxors','file') && sim.sim_Rlx == 1
            
            [sim.FRlxT1,sim.FRlxT2,sim.CRlxT1] = blOCh__Get_Relaxors(spc.T1map,spc.T2map,sim.dt,spc.P);
        end
        
        for b0i = 1:sim.B0inhom_N
            
            sim.B0inhom_offsets = linspace(sim.B0inhom_lim(1),sim.B0inhom_lim(2),sim.B0inhom_N);
            sim.B0inhom_offset = sim.B0inhom_offsets(b0i);
            
            for rfi = 1:sim.B1inhom_N
                
                sim.B1inhom_scales = linspace(sim.B1inhom_lim(1),sim.B1inhom_lim(2),sim.B1inhom_N);
                sim.B1inhom_scale = sim.B1inhom_scales(rfi);
                
                
                
                k_counter = 1;
                for k = sim.k
                    if size(sim.g,3)>1
                    g = sim.g(:,:,k);
                    else
                      g = sim.g;  
                    end
                    for s = sim.s
                        
                        switch sim.sim_Tx
                            
                            case 'all'
                                sim.u = sim.uo(:,:,k);
                                sim.v = sim.vo(:,:,k);
                            case 'sep'
                                if s == sim.S
                                    sim.u = sim.uo(:,:,k);
                                    sim.v = sim.vo(:,:,k);
                                else
                                    
                                    sim.u = zeros(size(sim.uo,1),size(sim.uo,2));
                                    sim.v = zeros(size(sim.vo,1),size(sim.vo,2));
                                    sim.u(s,:) = sim.uo(s,:,k);
                                    sim.v(s,:) = sim.vo(s,:,k);
                                end
                        end
                        
                        
                        sim = blOCh__opt('Allocate_Variables',[],[],[],[],spc,khr,sim);
                        sim = rmfield(sim,'L_t');
                        sim = rmfield(sim,'Durations');
                        sim = rmfield(sim,'Fun');
                        sim = rmfield(sim,'Eff');
                        sim = rmfield(sim,'Pen');
                        sim = rmfield(sim,'dFun');
                        %                         sim = rmfield(sim,'MaxIter');
                        
                        
                        
                        if exist('blOCh__Rotate_Relax','file') && sim.sim_Rlx == 1
                            for n = 1:sim.N
                                [R11f,R12f,R13f,R21f,R22f,R23f,R31f,R32f,R33f] = blOCh__opt('Get_Rotator',[],[],[],[],sim.u.*sim.B1inhom_scale,sim.v.*sim.B1inhom_scale,g,sim.w0+2*pi*sim.B0inhom_offset,sim.yx,sim.yy,sim.yz,spc.pTx,sim.sr,sim.si,sim.dt,n);
                                sim.M_t(:,n+1) = blOCh__Rotate_Relax(sim.M_t(:,n),R11f,R12f,R13f,R21f,R22f,R23f,R31f,R32f,R33f,sim.FRlxT1,sim.FRlxT2,sim.CRlxT1,'Forward');
                            end
                            
                            
                        else
                            for n = 1:sim.N
                                [R11f,R12f,R13f,R21f,R22f,R23f,R31f,R32f,R33f] = blOCh__opt('Get_Rotator',[],[],[],[],sim.u.*sim.B1inhom_scale,sim.v.*sim.B1inhom_scale,g,sim.w0+2*pi*sim.B0inhom_offset,sim.yx,sim.yy,sim.yz,spc.pTx,sim.sr,sim.si,sim.dt,n);
                                sim.M_t(:,n+1) = blOCh__opt('Rotate',[],[],[],[],sim.M_t(:,n),R11f,R12f,R13f,R21f,R22f,R23f,R31f,R32f,R33f,'Forward');
                                
                            end
                            
                        end
                        
                        
                        sim.idxtot = spc.idxtot;
                        switch sim.sim_n
                            
                            case 'last'
                                sim.M_t_big(:,1,k_counter,s,rfi,b0i) = sim.M_t(:,end);
                            case 'all'
                                sim.M_t_big(:,:,k_counter,s,rfi,b0i) = sim.M_t;
                        end
                        
                    end
                    k_counter = k_counter + 1;
                end
            end
        end
        sim.M_t = sim.M_t_big;
        sim = rmfield(sim,'M_t_big');
        %         size(sim.M_t_big)
        sim.Dim = spc.Dim;
        sim.pTx = spc.pTx;
        sim.R = spc.R;
        sim.Rv = spc.Rv;
        sim.D = spc.D;
        sim.Dv = spc.Dv;
        sim.Md = spc.Md;
        sim.idxtot=spc.idxtot;
        
        if sim.Show > 0
        sim.fig = Show_Sim(sim);
        end
        

        
        
        
        varargout{1} = sim;
    end
else
    Nargout = nargout;
    fun = str2func(Fun);
    test = version('-release');
    if strcmp(test,'2015a')
    v = [];
    else
        v = {};
    end
    
    switch Nargout
        case 0
            fun(varargin{:});
        case 1
            v{1} = fun(varargin{:});
        case 2
            [v{1},v{2}] = fun(varargin{:});
        case 3
            [v{1},v{2},v{3}] = fun(varargin{:});
        case 4
            [v{1},v{2},v{3},v{4}] = fun(varargin{:});
        case 5
            [v{1},v{2},v{3},v{4},v{5}] = fun(varargin{:});
        case 6
            [v{1},v{2},v{3},v{4},v{5},v{6}] = fun(varargin{:});
        case 7
            [v{1},v{2},v{3},v{4},v{5},v{6},v{7}] = fun(varargin{:});
        case 8
            [v{1},v{2},v{3},v{4},v{5},v{6},v{7},v{8}] = fun(varargin{:});
        case 9
            [v{1},v{2},v{3},v{4},v{5},v{6},v{7},v{8},v{9}] = fun(varargin{:});
        case 10
            [v{1},v{2},v{3},v{4},v{5},v{6},v{7},v{8},v{9},v{10}] = fun(varargin{:});
        otherwise
            Display_Message(['spc: Fun: This switch needs to be expanded'],2)
            
    end
    
    varargout = v;
    
end
end

function test = Validate_rf(x,spc,khr,RFinputtype)

test = false;

if isempty(x) && RFinputtype == 1
    
    test = true;
    
elseif ~isempty(x) && RFinputtype == 2
    
    
    
    
    
end




end

function Out = isdef(In,Case)
Out = false;
for n = 1:length(In)
    if ischar(In{n})
        if strcmp(In{n},Case)
            Out = true;
        end
    end
end


end

function test = Validate_ks(x)

test = false;

if ischar(x)
    
    switch x
        
        case {'last','all','firstlast'}
            
            test = true;
        otherwise
            
    end
    
elseif isnumeric(x)
    
    
    
    test = true;
    
end

end


function Display_Message(Msg,Type)
if nargin == 1
    Type = 0;
end

if iscell(Msg)
    
    for n = 1:length(Msg)
        Msg_temp = Msg{n};
        Msg_temp = Repair_Msg(Msg_temp);
        
        if Type == 1
            
            fprintf(1,[Msg_temp,'\n']);
            
        elseif Type == 2
            
            fprintf(2,[Msg_temp,'\n']);
        elseif Type == 3
            
            fprintf(1,[Msg_temp]);
            
        else
            
            fprintf(Type,[Msg,'\n']);
        end
    end
else
    Msg_temp = Msg;
    Msg_temp = Repair_Msg(Msg_temp);
    
    if Type == 1
        
        fprintf(1,[Msg_temp,'\n']);
        
    elseif Type == 2
        
        fprintf(2,[Msg_temp,'\n']);
    elseif Type == 0
        
    elseif Type == 3
        
        fprintf(1,[Msg]);
    else
        
        fprintf(1,[Msg,'\n']);
    end
end


end

function Msg = Repair_Msg(Msg)
% function Msg = Repair_Msg(Msg)

Msg = regexprep(Msg,'\\','msv8');

Msg = regexprep(Msg,'msv8','\\\');
end

function fig = Show_Sim(varargin)
global hsim

hsim.sim = varargin{1};


    hsim.fig = figure('Visible','on');


mp = get(0, 'MonitorPositions');
if size(mp,1) > 1
    mp = mp(1,:);
end

set(hsim.fig,'Units','pixels')
set(hsim.fig,'Position',[1,1,mp(3).*0.9,mp(4).*0.9])
WHratio = get(hsim.fig,'Position');
WHratio = WHratio(3)/WHratio(4);
set(hsim.fig,'Units','normalized')

%%



clear varargin
%%

    hsim.axes1 = axes('Parent',hsim.fig,'Visible','on');
hsim.axes2 = axes('Parent',hsim.fig,'Visible','on');


hsim.listbox1= uicontrol('Style','listbox','Callback',@listbox1_Callback);

hsim.slider1= uicontrol('Style','slider','Callback',@slider1_Callback);
hsim.slider2= uicontrol('Style','slider','Callback',@slider2_Callback);
hsim.slider3= uicontrol('Style','slider','Callback',@slider3_Callback);
hsim.slider4= uicontrol('Style','slider','Callback',@slider4_Callback);
hsim.slider5= uicontrol('Style','slider','Callback',@slider5_Callback);
hsim.slider6= uicontrol('Style','slider','Callback',@slider6_Callback);
hsim.slider7= uicontrol('Style','slider','Callback',@slider7_Callback);
hsim.popupmenu1= uicontrol('Style','popupmenu','Callback',@popupmenu1_Callback);
hsim.pushbutton1= uicontrol('Style','pushbutton','Callback',@pushbutton1_Callback);
hsim.pushbutton2= uicontrol('Style','pushbutton','Callback',@pushbutton2_Callback);
hsim.pushbutton3= uicontrol('Style','pushbutton','Callback',@pushbutton3_Callback);

hsim.text1= uicontrol('Style','text');
hsim.text2= uicontrol('Style','text');
hsim.text3= uicontrol('Style','text');
hsim.text4= uicontrol('Style','text');
hsim.text5= uicontrol('Style','text');
hsim.text6= uicontrol('Style','text');
hsim.text7= uicontrol('Style','text');
hsim.text8= uicontrol('Style','text');
hsim.text9= uicontrol('Style','text');


Sliderheight = 0.02;
Textheight = 0.02;
Textwidth = 0.04;
Spacer  = 0.001;

set(hsim.slider1,'Units','normalized')
set(hsim.slider2,'Units','normalized')
set(hsim.slider3,'Units','normalized')
set(hsim.slider4,'Units','normalized')
set(hsim.slider5,'Units','normalized')
set(hsim.slider6,'Units','normalized')
set(hsim.slider7,'Units','normalized')

set(hsim.pushbutton1,'Units','normalized')
set(hsim.pushbutton2,'Units','normalized')
set(hsim.pushbutton3,'Units','normalized')


set(hsim.text1,'Units','normalized')
set(hsim.text2,'Units','normalized')
set(hsim.text3,'Units','normalized')
set(hsim.text4,'Units','normalized')
set(hsim.text5,'Units','normalized')
set(hsim.text6,'Units','normalized')
set(hsim.text7,'Units','normalized')
set(hsim.text8,'Units','normalized')
set(hsim.text9,'Units','normalized')

set(hsim.axes1,'Units','normalized')
set(hsim.axes2,'Units','normalized')

set(hsim.listbox1,'Units','normalized')

set(hsim.popupmenu1,'Units','normalized')


%%

hsim.r.x_slider1 = 0.69;
hsim.r.x_slider2 = 0.69;
hsim.r.x_slider3 = 0.69;
hsim.r.x_slider4 = 0.69;
hsim.r.x_slider5 = 0.69;
hsim.r.x_slider6 = 0.69;
hsim.r.x_slider7 = 0.69;



hsim.r.y_slider7 = 0.005;
hsim.r.y_slider6 = hsim.r.y_slider7+Sliderheight+0.001;
hsim.r.y_slider5 = hsim.r.y_slider6+Sliderheight+0.001;
hsim.r.y_slider4 = hsim.r.y_slider5+Sliderheight+0.001;
hsim.r.y_slider3 = hsim.r.y_slider4+Sliderheight+0.001;
hsim.r.y_slider2 = hsim.r.y_slider3+Sliderheight+0.001;
hsim.r.y_slider1 = hsim.r.y_slider2+Sliderheight+0.001;

hsim.r.w_slider1 = 0.3;
hsim.r.w_slider2 = 0.3;
hsim.r.w_slider3 = 0.3;
hsim.r.w_slider4 = 0.3;
hsim.r.w_slider5 = 0.3;
hsim.r.w_slider6 = 0.3;
hsim.r.w_slider7 = 0.3;

hsim.r.h_slider1 = Sliderheight;
hsim.r.h_slider2 = Sliderheight;
hsim.r.h_slider3 = Sliderheight;
hsim.r.h_slider4 = Sliderheight;
hsim.r.h_slider5 = Sliderheight;
hsim.r.h_slider6 = Sliderheight;
hsim.r.h_slider7 = Sliderheight;

hsim.r.x_axes1 = 0.05;
hsim.r.xo_axes1 = 0.01;
hsim.r.yo_axes1 = 0.2;
hsim.r.y_axes1 = 0.25;
hsim.r.ho_axes1 = 0.7;
hsim.r.h_axes1 = 0.65;
hsim.r.wo_axes1 = hsim.r.ho_axes1/WHratio;
hsim.r.w_axes1 = hsim.r.h_axes1/WHratio;
% WHratio
hsim.r.x_axes2 = 0.625;
hsim.r.y_axes2 = 0.25;
hsim.r.h_axes2 = 0.65;
hsim.r.w_axes2 = 0.02;


hsim.r.y_text9 = hsim.r.y_slider7;
hsim.r.y_text8 = hsim.r.y_slider6;
hsim.r.y_text7 = hsim.r.y_slider5;
hsim.r.y_text6 = hsim.r.y_slider4;
hsim.r.y_text5 = hsim.r.y_slider3;
hsim.r.y_text4 = hsim.r.y_slider2;
hsim.r.y_text3 = hsim.r.y_slider1;
hsim.r.y_text1 = 0.91;%0.095+Sliderheight+Spacer;
hsim.r.y_text2 = 0.2;% 0.05+Sliderheight+Spacer;


hsim.r.w_text1 =0.05;% 0.98;
hsim.r.w_text2 =0.05;% 0.48;
hsim.r.w_text3 =0.19;% 0.48;
hsim.r.w_text4 =0.19;% 0.48;
hsim.r.w_text5 =0.19;% 0.48;
hsim.r.w_text6 =0.19;% 0.2;
hsim.r.w_text7 =0.19;% 0.2;
hsim.r.w_text8 =0.19;% 0.2;
hsim.r.w_text9 =0.19;% 0.2;

hsim.r.x_text1 = 0.62;
hsim.r.x_text2 = 0.62;
hsim.r.x_text3 = 0.49;
hsim.r.x_text4 = 0.49;
hsim.r.x_text5 = 0.49;
hsim.r.x_text6 = 0.49;
hsim.r.x_text7 = 0.49;
hsim.r.x_text8 = 0.49;
hsim.r.x_text9 = 0.49;

hsim.r.h_text1 = Textheight;
hsim.r.h_text2 = Textheight;
hsim.r.h_text3 = Textheight;
hsim.r.h_text4 = Textheight;
hsim.r.h_text5 = Textheight;
hsim.r.h_text6 = Textheight;
hsim.r.h_text7 = Textheight;
hsim.r.h_text8 = Textheight;
hsim.r.h_text9 = Textheight;

hsim.r.x_popupmenu1 = 0.005;
hsim.r.y_popupmenu1 = 0.94;
hsim.r.w_popupmenu1 = 0.68;
hsim.r.h_popupmenu1 = 0.05;


hsim.r.x_listbox1 = 0.69;
hsim.r.y_listbox1 = 0.2;%0.2+0.266667*2;
hsim.r.w_listbox1 = 0.3;
hsim.r.h_listbox1 = 0.26*3;% 0.26;


hsim.r.x_pushbutton1 = 0.69;
hsim.r.y_pushbutton1 = 0.17;
hsim.r.w_pushbutton1 = 0.1;
hsim.r.h_pushbutton1 = 0.02;

hsim.r.x_pushbutton2 = 0.69+0.1;
hsim.r.y_pushbutton2 = 0.17;
hsim.r.w_pushbutton2 = 0.1;
hsim.r.h_pushbutton2 = 0.02;

hsim.r.x_pushbutton3 = 0.69+0.2;
hsim.r.y_pushbutton3 = 0.17;
hsim.r.w_pushbutton3 = 0.1;
hsim.r.h_pushbutton3 = 0.02;

set(hsim.slider1,'Position',[hsim.r.x_slider1,hsim.r.y_slider1,hsim.r.w_slider1,hsim.r.h_slider1])
set(hsim.slider2,'Position',[hsim.r.x_slider2,hsim.r.y_slider2,hsim.r.w_slider2,hsim.r.h_slider2])
set(hsim.slider3,'Position',[hsim.r.x_slider3,hsim.r.y_slider3,hsim.r.w_slider3,hsim.r.h_slider3])
set(hsim.slider4,'Position',[hsim.r.x_slider4,hsim.r.y_slider4,hsim.r.w_slider4,hsim.r.h_slider4])
set(hsim.slider5,'Position',[hsim.r.x_slider5,hsim.r.y_slider5,hsim.r.w_slider5,hsim.r.h_slider5])
set(hsim.slider6,'Position',[hsim.r.x_slider6,hsim.r.y_slider6,hsim.r.w_slider6,hsim.r.h_slider6])
set(hsim.slider7,'Position',[hsim.r.x_slider7,hsim.r.y_slider7,hsim.r.w_slider7,hsim.r.h_slider7])

set(hsim.text1,'Position',[hsim.r.x_text1,hsim.r.y_text1,hsim.r.w_text1,hsim.r.h_text1])
set(hsim.text2,'Position',[hsim.r.x_text2,hsim.r.y_text2,hsim.r.w_text2,hsim.r.h_text2])
set(hsim.text3,'Position',[hsim.r.x_text3,hsim.r.y_text3,hsim.r.w_text3,hsim.r.h_text3],'HorizontalAlignment','right')
set(hsim.text4,'Position',[hsim.r.x_text4,hsim.r.y_text4,hsim.r.w_text4,hsim.r.h_text4],'HorizontalAlignment','right')
set(hsim.text5,'Position',[hsim.r.x_text5,hsim.r.y_text5,hsim.r.w_text5,hsim.r.h_text5],'HorizontalAlignment','right')
set(hsim.text6,'Position',[hsim.r.x_text6,hsim.r.y_text6,hsim.r.w_text6,hsim.r.h_text6],'HorizontalAlignment','right')
set(hsim.text7,'Position',[hsim.r.x_text7,hsim.r.y_text7,hsim.r.w_text7,hsim.r.h_text7],'HorizontalAlignment','right')
set(hsim.text8,'Position',[hsim.r.x_text8,hsim.r.y_text8,hsim.r.w_text8,hsim.r.h_text8],'HorizontalAlignment','right')
set(hsim.text9,'Position',[hsim.r.x_text9,hsim.r.y_text9,hsim.r.w_text9,hsim.r.h_text9],'HorizontalAlignment','right')

set(hsim.axes1,'OuterPosition',[hsim.r.xo_axes1,hsim.r.yo_axes1,hsim.r.wo_axes1,hsim.r.ho_axes1])
set(hsim.axes1,'Position',[hsim.r.x_axes1,hsim.r.y_axes1,hsim.r.w_axes1,hsim.r.h_axes1])
set(hsim.axes2,'Position',[hsim.r.x_axes2,hsim.r.y_axes2,hsim.r.w_axes2,hsim.r.h_axes2])
set(hsim.listbox1,'Position',[hsim.r.x_listbox1,hsim.r.y_listbox1,hsim.r.w_listbox1,hsim.r.h_listbox1])
% set(hsim.listbox2,'Position',[hsim.r.x_listbox2,hsim.r.y_listbox2,hsim.r.w_listbox2,hsim.r.h_listbox2])
% set(hsim.listbox3,'Position',[hsim.r.x_listbox3,hsim.r.y_listbox3,hsim.r.w_listbox3,hsim.r.h_listbox3])
set(hsim.popupmenu1,'Position',[hsim.r.x_popupmenu1,hsim.r.y_popupmenu1,hsim.r.w_popupmenu1,hsim.r.h_popupmenu1])

set(hsim.pushbutton1,'Position',[hsim.r.x_pushbutton1,hsim.r.y_pushbutton1,hsim.r.w_pushbutton1,hsim.r.h_pushbutton1],'String','Play x1')
set(hsim.pushbutton2,'Position',[hsim.r.x_pushbutton2,hsim.r.y_pushbutton2,hsim.r.w_pushbutton2,hsim.r.h_pushbutton2],'String','Play x10')
set(hsim.pushbutton3,'Position',[hsim.r.x_pushbutton3,hsim.r.y_pushbutton3,hsim.r.w_pushbutton3,hsim.r.h_pushbutton3],'String','Play x100')

if str2double(hsim.sim.Dim(1)) > 1
    set(hsim.axes2,'Visible','on')
    set(hsim.text1,'Visible','on')
    set(hsim.text2,'Visible','on')
else
    set(hsim.axes2,'Visible','off')
    set(hsim.text1,'Visible','off')
    set(hsim.text2,'Visible','off')
end
set(hsim.text6,'Visible','on')
set(hsim.text7,'Visible','on')
%%
if strcmpi(hsim.sim.sim_n,'last')
    set(hsim.pushbutton1,'Visible','off')
    set(hsim.pushbutton2,'Visible','off')
    set(hsim.pushbutton3,'Visible','off')
    set(hsim.slider1,'Visible','off','Value',1)
    set(hsim.text3,'Visible','off');
    hsim.nNo = 1;
    set(hsim.pushbutton1,'Visible','off')
elseif strcmpi(hsim.sim.sim_n,'all')
    set(hsim.pushbutton1,'Visible','on')
    set(hsim.pushbutton2,'Visible','on')
    set(hsim.pushbutton3,'Visible','on')
    set(hsim.slider1,'Min',1)
    set(hsim.slider1,'Max',hsim.sim.N)
    TimeSliderStep = [1, 1] / (hsim.sim.N - 1);
    set(hsim.slider1,'SliderStep',TimeSliderStep)
    hsim.nNo = hsim.sim.N;
    set(hsim.slider1,'Visible','on','Value',hsim.nNo)
    set(hsim.text3,'Visible','on','String',sprintf('Timeframe %i dt (%1.1e s) of %i dt (%1.1e s)',hsim.nNo,hsim.nNo*hsim.sim.dt,hsim.sim.N,hsim.sim.N.*hsim.sim.dt))
    
end

%%
if hsim.sim.Dim(1) == '3'
    set(hsim.slider2,'Min',1)
    set(hsim.slider2,'Max',hsim.sim.R(3))
    SliceSliderStep = [1, 1] / (hsim.sim.R(3) - 1);
    set(hsim.slider2,'SliderStep',SliceSliderStep)
    hsim.SlNo = round(hsim.sim.R(3)/2);
    set(hsim.slider2,'Visible','on','Value',hsim.SlNo)
    set(hsim.text4,'Visible','on','String',sprintf('Slice %i of %i',hsim.SlNo,hsim.sim.R(3)))
    
else
    set(hsim.slider2,'Visible','off','Value',1)
    set(hsim.text4,'Visible','off');
    hsim.SlNo = 1;
end
%%


if hsim.sim.pTx > 1 && strcmpi(hsim.sim.sim_Tx,'sep')
    set(hsim.slider3,'Min',1)
    set(hsim.slider3,'Max',hsim.sim.pTx+1)
    ChannelSliderStep = [1, 1] / (hsim.sim.pTx+1 - 1);
    set(hsim.slider3,'SliderStep',ChannelSliderStep)
    hsim.pTxNo = hsim.sim.pTx+1;
    set(hsim.slider3,'Visible','on','Value',hsim.pTxNo)
    if hsim.pTxNo == hsim.sim.pTx+1
        set(hsim.text5,'Visible','on','String',sprintf('All %i Tx',hsim.sim.pTx))
    else
        set(hsim.text5,'Visible','on','String',sprintf('Tx %i of %i',hsim.pTxNo,hsim.sim.pTx))
    end
else
    set(hsim.slider3,'Visible','off','Value',1)
    set(hsim.text5,'Visible','off');
    hsim.pTxNo = 1;
end

%%

if hsim.sim.Dim(2) == '+' && hsim.sim.Dim(1) ~= '0'
    hsim.freq = linspace(hsim.sim.Dv(1),hsim.sim.Dv(2),hsim.sim.Rv);
    
    set(hsim.slider4,'Min',1)
    set(hsim.slider4,'Max',hsim.sim.Rv)
    FreqSliderStep = [1, 1] / (hsim.sim.Rv - 1);
    set(hsim.slider4,'SliderStep',FreqSliderStep)
    hsim.freqNo = round(hsim.sim.Rv/2);
    
    if hsim.sim.Dim(1) == '1'
        
        set(hsim.slider4,'Visible','off')
        set(hsim.text6,'Visible','off')
    else
        set(hsim.slider4,'Visible','on','Value',hsim.freqNo)
        set(hsim.text6,'Visible','on','String',sprintf('Frequency: %.2f [Hz]',hsim.freq(hsim.freqNo)))
        
    end
else
    set(hsim.slider4,'Visible','off','Value',1)
    set(hsim.text6,'Visible','off');
    hsim.freqNo = 1;
end
%%
if hsim.sim.K > 1
    set(hsim.slider5,'Min',1)
    set(hsim.slider5,'Max',hsim.sim.K)
    IterationSliderStep = [1, 1] / (hsim.sim.K - 1);
    set(hsim.slider5,'SliderStep',IterationSliderStep)
    hsim.kNo = hsim.sim.K;
    set(hsim.slider5,'Visible','on','Value',hsim.kNo)
    
    set(hsim.text7,'Visible','on','String',sprintf('Iteration %i of %i',hsim.kNo-1,hsim.sim.K-1))
else
    set(hsim.slider5,'Visible','off','Value',1)
    set(hsim.text7,'Visible','off');
    hsim.kNo = 1;
end
%%

%%
if hsim.sim.B1inhom_N==1
    set(hsim.slider6,'Visible','off','Value',1)
    set(hsim.text8,'Visible','off');
    hsim.nB1inh = 1;
else
    set(hsim.slider6,'Min',1)
    set(hsim.slider6,'Max',hsim.sim.B1inhom_N)
    B1SliderStep = [1, 1] / (hsim.sim.B1inhom_N - 1);
    set(hsim.slider6,'SliderStep',B1SliderStep)
    hsim.nB1inh = round(hsim.sim.B1inhom_N/2);
    set(hsim.slider6,'Visible','on','Value',hsim.nB1inh)
    set(hsim.text8,'Visible','on','String',sprintf('B1 scale %i of %i (%1.1e %%)',hsim.nB1inh,hsim.sim.B1inhom_N,hsim.sim.B1inhom_scales(hsim.nB1inh)))
    
end
%%
if hsim.sim.B0inhom_N==1
    set(hsim.slider7,'Visible','off','Value',1)
    set(hsim.text9,'Visible','off');
    hsim.nB0inh = 1;
else
    set(hsim.slider7,'Min',1)
    set(hsim.slider7,'Max',hsim.sim.B1inhom_N)
    B0SliderStep = [1, 1] / (hsim.sim.B0inhom_N - 1);
    set(hsim.slider7,'SliderStep',B0SliderStep)
    hsim.nB0inh = round(hsim.sim.B0inhom_N/2);
    set(hsim.slider7,'Visible','on','Value',hsim.nB0inh)
    set(hsim.text9,'Visible','on','String',sprintf('B0 offset %i of %i (%1.1e Hz)',hsim.nB0inh,hsim.sim.B0inhom_N,hsim.sim.B0inhom_offsets(hsim.nB0inh)))
    
end
%%
List1 = Populate_Listbox(hsim.sim);
set(hsim.listbox1,'String',List1);


%%
if strcmpi(hsim.sim.Dim(1),'3')
    String = cell(1,8);
    String{1} = 'Magnetization, |Mxy| [M0]';
    String{2} = 'Magnetization, Mx [M0]';
    String{3} = 'Magnetization, My [M0]';
    String{4} = 'Magnetization, Mz [M0]';
    String{5} = 'Desired Magnetization, |Mxy| [M0]';
    String{6} = 'Desired Magnetization, Mx [M0]';
    String{7} = 'Desired Magnetization, My [M0]';
    String{8} = 'Desired Magnetization, Mz [M0]';
    
else
    String = cell(1,8);
    String{1} = 'Magnetization, |Mxy| [M0]';
    String{2} = 'Magnetization, Mx [M0]';
    String{3} = 'Magnetization, My [M0]';
    String{4} = 'Magnetization, Mz [M0]';
    String{5} = 'Desired Magnetization, |Mxy| [M0]';
    String{6} = 'Desired Magnetization, Mx [M0]';
    String{7} = 'Desired Magnetization, My [M0]';
    String{8} = 'Desired Magnetization, Mz [M0]';
end
set(hsim.popupmenu1, 'String', String);
set(hsim.popupmenu1, 'Value',1);
%%
[hsim.colmap.Jet,hsim.colmap.Gray] = GetColormaps;

hsim.Colmap = hsim.colmap.Jet;
colormap jet

hsim = Plotting(hsim);

fig = hsim.fig;
end

function popupmenu1_Callback(hOb, ed)
global hsim
hsim.popupmenu1select = get(hsim.popupmenu1,'Value');
hsim = Plotting(hsim);
end

function listbox1_Callback(hOb, ed)
end

function listbox2_Callback(hOb, ed)
end

function listbox3_Callback(hOb, ed)
end

function slider1_Callback(hOb, ed)
global hsim
hsim.nNo = round(get(hOb, 'Value'));
set(hOb, 'Value',hsim.nNo);

set(hsim.slider1,'Visible','on','Value',hsim.nNo)
set(hsim.text1,'Visible','on','String',sprintf('Timeframe %i dt (%1.1e s) of %i dt (%1.1e s)',hsim.nNo,hsim.nNo*hsim.sim.dt,hsim.sim.N,hsim.sim.N.*hsim.sim.dt))
hsim = Plotting(hsim);
end

function slider2_Callback(hOb, ed)
global hsim
hsim.SlNo = round(get(hOb, 'Value'));
% hsim.SlNo
set(hsim.text4,'String',sprintf('Slice %i of %i',hsim.SlNo,hsim.sim.R(3)))
hsim = Plotting(hsim);
end

function slider3_Callback(hOb, ed)
global hsim
hsim.pTxNo = round(get(hOb, 'Value'));

if hsim.pTxNo == hsim.sim.pTx+1
    set(hsim.text3,'Visible','on','String',sprintf('All %i Tx',hsim.sim.pTx))
else
    set(hsim.text3,'Visible','on','String',sprintf('Tx %i of %i',hsim.pTxNo,hsim.sim.pTx))
end

hsim = Plotting(hsim);
end

function slider4_Callback(hOb, ed)
global hsim
hsim.freqNo = round(get(hOb, 'Value'));
set(hOb, 'Value',hsim.freqNo);
set(hsim.text6,'Visible','on','String',sprintf('Frequency: %.2f [Hz]',hsim.freq(hsim.freqNo)))
hsim = Plotting(hsim);
end

function slider5_Callback(hOb, ed)
global hsim
hsim.kNo = round(get(hOb, 'Value'));
set(hOb, 'Value',hsim.kNo);
set(hsim.text7,'Visible','on','String',sprintf('Iteration %i of %i',hsim.kNo-1,hsim.sim.K-1))
hsim = Plotting(hsim);
end

function slider6_Callback(hOb, ed)
global hsim
hsim.nB1inh = round(get(hOb, 'Value'));
set(hOb, 'Value',hsim.nB1inh);
set(hsim.text8,'Visible','on','String',sprintf('B1 scale %i of %i (%1.1e %%)',hsim.nB1inh,hsim.sim.B1inhom_N,hsim.sim.B1inhom_scales(hsim.nB1inh)))

hsim = Plotting(hsim);
end

function slider7_Callback(hOb, ed)
global hsim
hsim.nB0inh = round(get(hOb, 'Value'));
set(hOb, 'Value',hsim.nB0inh);
set(hsim.text9,'Visible','on','String',sprintf('B0 offset %i of %i (%1.1e Hz)',hsim.nB0inh,hsim.sim.B0inhom_N,hsim.sim.B0inhom_offsets(hsim.nB0inh)))

hsim = Plotting(hsim);
end

function List = Populate_Listbox(Struct)
global hsim
names = fieldnames(Struct);
vals = cell(length(names),1);
for n = 1:length(names)
    
    if ischar(getfield(Struct,names{n}))
        vals{n} = getfield(Struct,names{n});
    elseif isnumeric(getfield(Struct,names{n}))
        [A,B,C,D,E] = size(getfield(Struct,names{n}));
        % 		[A,B,C,D,E]
        
        if E == 1
            
            if D == 1 && C == 1 && B == 1 && A == 1
                vals{n} = num2str(getfield(Struct,names{n}));
            elseif D == 1 && C == 1 && B ~= 1 && A == 1
                if B < 6
                    temp = getfield(Struct,names{n});
                    
                    Str = '[';
                    for b = 1:B
                        
                        Str = [Str,num2str(temp(b))];
                        if b<B
                            Str = [Str,sprintf('\t\t,\t\t')];
                        end
                    end
                    Str = [Str,']'];
                    vals{n} = Str;
                else
                    
                    vals{n} = sprintf('<%ix%i>',A,B);
                end
            elseif D == 1 && C == 1 && B ~= 1 && A ~= 1
                if B < 4 && A < 3
                    temp = getfield(Struct,names{n});
                    
                    Str = '[';
                    for a = 1:A
                        for b = 1:B
                            
                            Str = [Str,num2str(temp(a,b))];
                            if b<B
                                Str = [Str,sprintf(',')];
                            end
                        end
                        if a ~=  A
                            Str = [Str,sprintf(';')];
                            
                        end
                    end
                    Str = [Str,']'];
                    vals{n} = Str;
                else
                    
                    vals{n} = sprintf('<%ix%i>',A,B);
                end
            elseif D == 1 && C == 1 && B == 1 && A ~= 1
                if A < 3
                    temp = getfield(Struct,names{n});
                    
                    Str = '[';
                    for a = 1:A
                        for b = 1:B
                            
                            Str = [Str,num2str(temp(a,b))];
                            if b<B
                                Str = [Str,sprintf(',')];
                            end
                        end
                        if a ~=  A
                            Str = [Str,sprintf(';')];
                            
                        end
                    end
                    Str = [Str,']'];
                    vals{n} = Str;
                else
                    
                    vals{n} = sprintf('<%ix%i>',A,B);
                end
            else
                
                vals{n} = sprintf('<%ix%ix%ix%i>',A,B,C,D);
            end
            
        else
            vals{n} = sprintf('<%ix%ix%ix%ix%i>',A,B,C,D,E);
        end
        
        
    elseif iscell(getfield(Struct,names{n}))
        [A,B,C,D,E] = size(getfield(Struct,names{n}));
        if E == 1
            
            if D == 1 && C == 1 && B == 1 && A == 1
                vals{n} = num2str(getfield(Struct,names{n}));
            elseif D == 1 && C == 1 && B ~= 1 && A == 1
                
                vals{n} = sprintf('<%ix%i cell>',A,B);
                
            elseif D == 1 && C == 1 && B ~= 1 && A ~= 1
                
                vals{n} = sprintf('<%ix%i cell>',A,B);
                
            elseif D == 1 && C == 1 && B == 1 && A ~= 1
                
                vals{n} = sprintf('<%ix%i cell>',A,B);
                
            else
                
                vals{n} = sprintf('<%ix%ix%ix%i cell>',A,B,C,D);
            end
            
        else
            vals{n} = sprintf('<%ix%ix%ix%ix%i cell>',A,B,C,D,E);
        end
        
    elseif isstruct(getfield(Struct,names{n}))
        [A,B] = size(getfield(Struct,names{n}));
        vals{n} = sprintf('<%ix%i struct>',A,B);
    end
end

List = cell(length(names),1);

for n = 1:length(names)
    List{n} = sprintf('%s\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t%s',names{n},vals{n});
    
end
end

function [Jet,Gray] = GetColormaps

jett = colormap(jet(512));

Jet = zeros(512,10,3);
Jet(:,:,1) = repmat(jett(:,1),[1,10,1]);
Jet(:,:,2) = repmat(jett(:,2),[1,10,1]);
Jet(:,:,3) = repmat(jett(:,3),[1,10,1]);


grayy = colormap(gray(512));

Gray = zeros(512,10,3);
Gray(:,:,1) = repmat(grayy(:,1),[1,10,1]);
Gray(:,:,2) = repmat(grayy(:,2),[1,10,1]);
Gray(:,:,3) = repmat(grayy(:,3),[1,10,1]);
end

function pushbutton1_Callback(hOb, ed)
global hsim
for n = 1:hsim.sim.N
    hsim.nNo = n;
    set(hsim.slider1,'Value',hsim.nNo)
    set(hsim.text3,'String',sprintf('Timeframe %i dt (%1.1e s) of %i dt (%1.1e s)',hsim.nNo,hsim.nNo*hsim.sim.dt,hsim.sim.N,hsim.sim.N.*hsim.sim.dt))
    hsim = Plotting(hsim);
    pause(0.05)
    drawnow
end
end

function pushbutton2_Callback(hOb, ed)
global hsim

n_ = round(linspace(1,hsim.sim.N,hsim.sim.N/10));

for n = n_;
    hsim.nNo = n;
    set(hsim.slider1,'Value',hsim.nNo)
    set(hsim.text3,'String',sprintf('Timeframe %i dt (%1.1e s) of %i dt (%1.1e s)',hsim.nNo,hsim.nNo*hsim.sim.dt,hsim.sim.N,hsim.sim.N.*hsim.sim.dt))
    hsim = Plotting(hsim);
    pause(0.05)
    drawnow
end
end

function pushbutton3_Callback(hOb, ed)
global hsim

n_ = round(linspace(1,hsim.sim.N,hsim.sim.N/100));

for n = n_;
    hsim.nNo = n;
    set(hsim.slider1,'Value',hsim.nNo)
    set(hsim.text3,'String',sprintf('Timeframe %i dt (%1.1e s) of %i dt (%1.1e s)',hsim.nNo,hsim.nNo*hsim.sim.dt,hsim.sim.N,hsim.sim.N.*hsim.sim.dt))
    hsim = Plotting(hsim);
    pause(0.05)
    drawnow
end
end

function hsim = what2plot(hsim)
% tic
M_t = blOCh__spc('list2grid',[],[],[],[],hsim.sim.M_t(:,hsim.nNo,hsim.kNo,hsim.pTxNo,hsim.nB1inh,hsim.nB0inh),[hsim.sim.R,hsim.sim.Rv],hsim.sim.idxtot,3);
Md = blOCh__spc('list2grid',[],[],[],[],hsim.sim.Md,[hsim.sim.R,hsim.sim.Rv],hsim.sim.idxtot,3);
% toc
switch get(hsim.popupmenu1,'Value')
    
    case 1
        
        
        
        ordinate = abs(complex(M_t(:,:,:,:,1),M_t(:,:,:,:,2)));
        
        
        hsim.ordinate_mn = 0;
        hsim.ordinate_mx = max( ordinate(:));
        %       'Desired Magnetization, |Mxy| [M0]';
    case 2
        %       'Desired Magnetization, Mx [M0]';
        ordinate = M_t(:,:,:,:,1);
        
        hsim.ordinate_mn = min( ordinate(:));
        hsim.ordinate_mx = max( ordinate(:));
    case 3
        %       'Desired Magnetization, My [M0]';
        ordinate = M_t(:,:,:,:,2);
        hsim.ordinate_mn = min( ordinate(:));
        hsim.ordinate_mx = max( ordinate(:));
    case 4
        %       'Desired Magnetization, Mz [M0]';
        ordinate = M_t(:,:,:,:,3);
        hsim.ordinate_mn = min( ordinate(:));
        hsim.ordinate_mx = max( ordinate(:));
    case 5
        
        
        ordinate = abs(complex(Md(:,:,:,:,1),Md(:,:,:,:,2)));
        
        
        hsim.ordinate_mn = 0;
        hsim.ordinate_mx = max( ordinate(:));
        %       'Desired Magnetization, |Mxy| [M0]';
    case 6
        %       'Desired Magnetization, Mx [M0]';
        ordinate = Md(:,:,:,:,1);
        
        hsim.ordinate_mn = min( ordinate(:));
        hsim.ordinate_mx = max( ordinate(:));
    case 7
        %       'Desired Magnetization, My [M0]';
        ordinate = Md(:,:,:,:,2);
        hsim.ordinate_mn = min( ordinate(:));
        hsim.ordinate_mx = max( ordinate(:));
    case 8
        %       'Desired Magnetization, Mz [M0]';
        ordinate = Md(:,:,:,:,3);
        hsim.ordinate_mn = min( ordinate(:));
        hsim.ordinate_mx = max( ordinate(:));
end
if hsim.ordinate_mx == hsim.ordinate_mn
    hsim.ordinate_mx = hsim.ordinate_mx + eps;
end
% hsim.ordinate = ordinate;

switch hsim.sim.Dim
    
    case '1DSI'
        hsim.Dim1ticklabel = linspace(hsim.sim.D(1,3),hsim.sim.D(2,3),5);
        
        hsim.Dim1axis = linspace(1,hsim.sim.R(3),5);
        hsim.Dim2label = ' z [m]';
        hsim.ordinate = squeeze(ordinate);
    case '1DAP'
        hsim.Dim1ticklabel = linspace(hsim.sim.D(1,2),hsim.sim.D(2,2),5);
        hsim.Dim1axis = linspace(1,hsim.sim.R(2),5);
        hsim.Dim2label = ' y [m]';
        hsim.ordinate = squeeze(ordinate);
    case '1DRL'
        hsim.Dim1ticklabel = linspace(hsim.sim.D(1,1),hsim.sim.D(2,1),5);
        hsim.Dim1axis = linspace(1,hsim.sim.R(1),5);
        hsim.Dim2label = ' x [m]';
        hsim.ordinate = squeeze(ordinate);
    case '1+1DSI'
        hsim.Dim1ticklabel = linspace(hsim.sim.D(1,3),hsim.sim.D(2,3),5);
        hsim.Dim2ticklabel = linspace(hsim.sim.Dv(1),hsim.sim.Dv(2),5);
        hsim.Dim1axis = linspace(1,hsim.sim.R(3),5);
        hsim.Dim2axis = linspace(1,hsim.sim.Rv,5);
        hsim.Dim1label = ' z [m]';
        hsim.Dim2label = ' v [Hz]';
        hsim.ordinate = squeeze(ordinate);
    case '1+1DAP'
        hsim.Dim1ticklabel = linspace(hsim.sim.D(1,2),hsim.sim.D(2,2),5);
        hsim.Dim2ticklabel = linspace(hsim.sim.Dv(1),hsim.sim.Dv(2),5);
        hsim.Dim1axis = linspace(1,hsim.sim.R(2),5);
        hsim.Dim2axis = linspace(1,hsim.sim.Rv,5);
        hsim.Dim1label = ' y [m]';
        hsim.Dim2label = ' v [Hz]';
        hsim.ordinate = squeeze(ordinate);
    case '1+1DRL'
        hsim.Dim1ticklabel = linspace(hsim.sim.D(1,1),hsim.sim.D(2,1),5);
        hsim.Dim2ticklabel = linspace(hsim.sim.Dv(1),hsim.sim.Dv(2),5);
        hsim.Dim1axis = linspace(1,hsim.sim.R(1),5);
        hsim.Dim2axis = linspace(1,hsim.sim.Rv,5);
        hsim.Dim1label = ' x [m]';
        hsim.Dim2label = ' v [Hz]';
        hsim.ordinate = squeeze(ordinate);
    case '2DAx'
        hsim.Dim2ticklabel = linspace(hsim.sim.D(1,1),hsim.sim.D(2,1),5);
        hsim.Dim1ticklabel = linspace(hsim.sim.D(1,2),hsim.sim.D(2,2),5);
        hsim.Dim2axis = linspace(1,hsim.sim.R(1),5);
        hsim.Dim1axis = linspace(1,hsim.sim.R(2),5);
        hsim.Dim1label = ' y [m]';
        hsim.Dim2label = ' x [m]';
        hsim.ordinate = squeeze(ordinate);
    case '2DCo'
        hsim.Dim2ticklabel = linspace(hsim.sim.D(1,1),hsim.sim.D(2,1),5);
        hsim.Dim1ticklabel = linspace(hsim.sim.D(1,3),hsim.sim.D(2,3),5);
        hsim.Dim2axis = linspace(1,hsim.sim.R(1),5);
        hsim.Dim1axis = linspace(1,hsim.sim.R(3),5);
        
        hsim.Dim2label = ' x [m]';
        hsim.Dim1label = ' z [m]';
        hsim.ordinate = squeeze(ordinate);
    case '2DSa'
        hsim.Dim1ticklabel = linspace(hsim.sim.D(1,2),hsim.sim.D(2,2),5);
        hsim.Dim2ticklabel = linspace(hsim.sim.D(1,3),hsim.sim.D(2,3),5);
        hsim.Dim1axis = linspace(1,hsim.sim.R(2),5);
        hsim.Dim2axis = linspace(1,hsim.sim.R(3),5);
        hsim.Dim2label = ' y [m]';
        hsim.Dim1label = ' z [m]';
        hsim.ordinate = squeeze(ordinate);
    case '2+1DAx'
        hsim.Dim1ticklabel = linspace(hsim.sim.D(1,1),hsim.sim.D(2,1),5);
        hsim.Dim2ticklabel = linspace(hsim.sim.D(1,2),hsim.sim.D(2,2),5);
        hsim.Dim1axis = linspace(1,hsim.sim.R(1),5);
        hsim.Dim2axis = linspace(1,hsim.sim.R(2),5);
        hsim.Dim2label = ' x [m]';
        hsim.Dim1label = ' y [m]';
        
        hsim.ordinate = squeeze(ordinate(:,:,:,hsim.freqNo));
    case '2+1DCo'
        hsim.Dim2ticklabel = linspace(hsim.sim.D(1,1),hsim.sim.D(2,1),5);
        hsim.Dim1ticklabel = linspace(hsim.sim.D(1,3),hsim.sim.D(2,3),5);
        hsim.Dim2axis = linspace(1,hsim.sim.R(1),5);
        hsim.Dim1axis = linspace(1,hsim.sim.R(3),5);
        
        hsim.Dim2label = ' x [m]';
        hsim.Dim1label = ' z [m]';
        hsim.ordinate = squeeze(ordinate(:,:,:,hsim.freqNo));
    case '2+1DSa'
        hsim.Dim1ticklabel = linspace(hsim.sim.D(1,2),hsim.sim.D(2,2),5);
        hsim.Dim2ticklabel = linspace(hsim.sim.D(1,3),hsim.sim.D(2,3),5);
        hsim.Dim1axis = linspace(1,hsim.sim.R(2),5);
        hsim.Dim2axis = linspace(1,hsim.sim.R(3),5);
        hsim.Dim2label = ' y [m]';
        hsim.Dim1label = ' z [m]';
        hsim.ordinate = squeeze(ordinate(:,:,:,hsim.freqNo));
    case '3D'
        hsim.Dim1ticklabel = linspace(hsim.sim.D(1,1),hsim.sim.D(2,1),5);
        hsim.Dim2ticklabel = linspace(hsim.sim.D(1,2),hsim.sim.D(2,2),5);
        hsim.Dim1axis = linspace(1,hsim.sim.R(1),5);
        hsim.Dim2axis = linspace(1,hsim.sim.R(2),5);
        hsim.Dim2label = ' x [m]';
        hsim.Dim1label = ' y [m]';
        hsim.ordinate = squeeze(ordinate(:,:,hsim.SlNo,1));
    case '3+1D'
        hsim.Dim1ticklabel = linspace(hsim.sim.D(1,1),hsim.sim.D(2,1),5);
        hsim.Dim2ticklabel = linspace(hsim.sim.D(1,2),hsim.sim.D(2,2),5);
        hsim.Dim1axis = linspace(1,hsim.sim.R(1),5);
        hsim.Dim2axis = linspace(1,hsim.sim.R(2),5);
        hsim.Dim2label = ' x [m]';
        hsim.Dim1label = ' y [m]';
        hsim.ordinate = squeeze(ordinate(:,:,hsim.SlNo,hsim.freqNo));
    case '0+1D'
        hsim.Dim1ticklabel = linspace(hsim.sim.Dv(1),hsim.sim.Dv(2),5);
        hsim.Dim1axis = linspace(1,hsim.sim.Rv,5);
        hsim.Dim1label = ' v [Hz]';
        hsim.ordinate = squeeze(ordinate);
end
end

function hsim=Plotting(hsim)

hsim = what2plot(hsim);

switch hsim.sim.Dim(1:2)
    
    case {'1D','0+'}
        
        
        axes(hsim.axes1)
        
        plot(hsim.ordinate)
        set(hsim.axes1,'XTick',hsim.Dim1axis)
        set(hsim.axes1,'XTickLabel',hsim.Dim1ticklabel)
        xlabel(hsim.Dim1label)
        
    case {'1+','2D','2+','3D','3+'}
        axes(hsim.axes1)
        imagesc(hsim.ordinate,[hsim.ordinate_mn,hsim.ordinate_mx])
        set(hsim.axes1,'XTick',hsim.Dim2axis,'YTick',hsim.Dim1axis)
        set(hsim.axes1,'XTickLabel',hsim.Dim2ticklabel,'YTickLabel',hsim.Dim1ticklabel)
        set(hsim.axes1,'Ydir','normal')
        xlabel(hsim.Dim2label)
        ylabel(hsim.Dim1label)
        axes(hsim.axes2)
        imagesc(permute(hsim.Colmap,[1,2,3])), axis off
        set(hsim.text1,'Visible','on','string',sprintf('%1.10f',hsim.ordinate_mn))
        set(hsim.text2,'Visible','on','string',sprintf('%1.10f',hsim.ordinate_mx))
end
end


