
% PROP Container class used for handling of material and experimental properties.
% Author: T. A. Sipkens, 11/28/2018
%=========================================================================%
% 
% Notes:
% 1 Prop is a handle class and changes to an instance affect all copies
%   of the instance. Use Prop.copy to create a copy of the class that will
%   update independently.
% 2 Prop is a dynamicprops class, meaning that the property list can be
%   alterred used the addprop(Prop,'variablename') function.
% 
%=========================================================================%

classdef Prop < handle & dynamicprops
    
    properties
        h = 6.62606957e-34; % Planck's constant [m^2.kg/s]
        c = 2.99792458e8; % Speed of light in a vacuum [m/s]
        kb = 1.3806488e-23; % Boltzmann constant [m^2.kg/s^2/K]
        R = 8.3144621; % Universal gas constant [J/mol/K]
        phi = 0.0143877696; % Constant for Planck's law, phi = h*c/kb
        
        %-- Sensible energy properties -----------------------------------%
        M = [];
        Tm = [];
        rho = [];
        Arho = [];
        Brho = [];
        Crho = [];
        rho0 = []; % initial nanoparticle density for dpi
        rho_data = []; % used for tabulated densities
        rho_gi = []; % gridded interpolant for tabulated densities
        cp = [];
        Ccp = [];
        Dcp = [];
        Ecp = [];
        
        %-- Conduction properties ----------------------------------------%
        alpha = []; % thermal accommodation coefficient (TAC)
        alpha_std = []; % standard deviation on the TAC
        Tg = []; % gas temperature
        Pg = []; % gas pressure
        mg = []; % mass of the gas
        gamma1 = [];
        gamma2 = [];
        ct = []; % mean speed of the vapor
        zeta_rot = []; % rotational degrees of freedom
        T_del = [];
        
        %-- Evaporation properties ---------------------------------------%
        mv = []; % mass of the vapor [kg]
        Mv = []; % molar mass of the vapor [kg/mol]
        pv = []; % vapor pressure [Pa]
        hv = []; % heat of vaporization, [J/kg]
        Rs = []; % specific gas constant
        hv0 = [];
        hvA = [];
        gamma = []; % function for surface tension
        gamma0 = []; % nominal surface tension
        gammaT = []; % temperature dependent surface tension
        delta = []; % Tolman length, [nm]
        C = []; % CC eqn. parameter
        C1 = []; % vapor pressure eqn. parameter
        C2 = []; % vapor pressure eqn. parameter
        C3 = []; % vapor pressure eqn. parameter
        C4 = []; % vapor pressure eqn. parameter
        Tb = []; % boiling/reference temperature [K]
        Pref = []; % reference pressure for vapor pressure curve [Pa]
        A = []; % alternative constant for vapor pressure curve
        pv0 = []; % storing an alternative vapor pressure
        hvb = []; % heat of vaporization at boiling (or reference) point, [MJ/kg]
        Tcr = []; % critical temperature [K]
        n = []; % critical exponent
        beta = []; % Roman parameter
        alpham = []; % mass accommodation coefficient, []
        a0 = []; % model parameter (pv), e.g. for polynomial fits
        a1 = []; % model parameter (pv)
        a2 = []; % model parameter (pv)
        a3 = []; % model parameter (pv)
        a4 = []; % model parameter (pv)
        b0 = []; % model parameter (Hv)
        b1 = []; % model parameter (Hv)
        b2 = []; % model parameter (Hv)
        b3 = []; % model parameter (Hv)
        b4 = []; % model parameter (Hv)
        b5 = []; % model parameter (Hv)
        c0 = []; % model parameter (Mv)
        c1 = []; % model parameter (Mv)
        c2 = []; % model parameter (Mv)
        c3 = []; % model parameter (Mv)
        c4 = []; % model parameter (Mv)
        
        
        %-- Optical properties -------------------------------------------%
        % Consider grouping these for passing later on
        Em = [];
        Emr = [];
        CEmr = [];
        Emr_const = [];
        Em_data = [];
        Em_gi = [];
        Kopt = [];
        const = [];
        Emod = [];
        omega_p = []; % Drude parameter
        tau = []; % Drude parameter
        
        %-- Absorption properties ----------------------------------------%
        Eml = []; % E(m) at laser wavelength
        F0 = []; % flunece [J/cm2]
        tlp = []; % laser pulse length [s]
        tlm = []; % laser pulse center [s]
        l_laser = 1064; % laser wavelength [nm]
        
        %-- Particle size and signal properties --------------------------%
        dpg = []; % geometric mean particle size [nm]
        dp0 = []; % mean particle size [nm]
        sigma = 0; % size distribution std. dev., Note: sg=1.5 > sigma=0.4055
        C_dp = [];
        Ti = []; % initial temperature for simulation [K]
        l = []; % measurement wavelengths [nm]
        C_J = 1; % constant scaling blackbody distribution (different than smodel.data_sc)
        
        %-- One color, volume fraction calcs. ----------------------------%
        fv = [];
        Tpeak = [];
        eta = [];
        we = [];
        
        
        %-- Options structure --------------------------------------------%
        opts struct = struct(...
            'rho','default',... 
            'cp','default',... 
            'hv','default',... 
            'abs','default',...
            'Em','default',... 
            'M','default',...
            'pv','default',...
            'mv','default',...
            'propmodel','default'...
            );
    end
    
    methods
        
        %-- Constructor method -------------------------------------------%
        function prop = Prop(strs,varargin)
            disp('Reading material properties...');
            
            for ss=1:length(strs) % convert strings to M file names
                strs{ss} = [strs{ss},'.m'];
            end
            
            
            prop = tools.parse_varargin(prop,varargin{:});
                % handle additional options (see function in tools package)
            
            
            %-- Load properties from files -------------------------------%
            if exist('strs','var')
                if ~isempty(strs)
                    for ii=1:length(strs)
                        [~,name,~] = fileparts(strs{ii});
                        eval([name,'(prop,prop.opts);']);
                    end
                end
            end
            %-------------------------------------------------------------%
            
            
            disp('Material properties loaded.');
            disp(' ');
        end
        %-----------------------------------------------------------------%
        
        
        %-- Thermophysical and optical expressions -----------------------%
        [hv] = eq_watson(prop,T); % Watson equation
        [pv] = eq_claus_clap(prop,T,dp,hv); % Clausius-Clapeyron equation
        [pv] = eq_antoine(prop,T,dp,hv); % Antione equation
        [pv] = eq_kelvin(prop,T,dp,hv); % Kelvin equation
        [gamma] = eq_tolman(prop,dp,T); % Tolman equation (dp in nm)
        [Em,n,k] = eq_drude(prop,lambda); % evaluate Drude theory given omega_p and tau (lambda in nm)
        
        
        %-- Helper methods -----------------------------------------------%
        [out] = plotProp(prop,propName,opts); % Plot a property over a range
        [copied] = copy(prop); % make a copy of current propreties
        %-----------------------------------------------------------------%
        
    end
    
    methods(Static)
        
        function out = iif(cond,a,b) % inline if function
            out = b;
            out(cond) = a(cond);
        end
        
        function out = poly(varargin) % inline polynomial function
            out = @(x)sum([varargin{2:2:end}].*x.^[varargin{1:2:end}]);
        end
        
        [hv, pv, mv, alpham] = vaporMichelsen(); % vapor properties of carbon, Michelsen model
        [Em_eff, Q_abs] = get_Mie_solution(n,k,lambda_vec,dp_vec); % get Mie absorption
        
    end
    
end

