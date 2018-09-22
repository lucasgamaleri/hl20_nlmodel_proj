classdef hl20
    % HL-20 Data
    % Derivativas, parámetros másicos y cálculo de coeficientes
	properties (Constant)
        ft_2_m    = 0.0254*12;
        kg_2_slug = 0.0685218;   % kg to slug
        kg_2_lb   = 2.20462;
        lb_2_kg   = 1/hl20.kg_2_lb; 
        sl_2_kg   = 1/hl20.kg_2_slug;

        % NASA Technical Memorandum 4302
        % Preliminary Subsonic Aerodynamic Model for Simulation 
        % Studies of the HL-20 Lifting Body
        
        % filas: -10° < α < 30°, -10° < β < 10°
        % [1 α α² α³ α^4 α^5 α^6 β β² β³ β^4 α|β|
        % columnas
        % [CN Cmo CA] = [-CZ Cm -CX]
        Po = [-9.025e-2  2.632e-2  7.362e-2
               4.070e-2 -2.226e-3 -2.560e-4
               3.094e-5 -1.859e-5 -2.208e-4
               1.564e-5  6.001e-7 -2.262e-6
              -1.386e-6  1.828e-7  2.966e-7
               2.545e-8 -9.733e-9 -3.640e-9
              -1.189e-10 1.710e-10 9.388e-12
               2.564e-3 -5.233e-4 -5.299e-4
               8.501e-4  6.795e-5 -4.709e-4
              -1.156e-4 -1.993e-5  8.572e-5
               3.416e-6  1.341e-6 -4.199e-6
              -4.8562e-4 6.061e-5  1.295e-4];
        Cn_alpha = [-10 -5 0 5 10 15 20 25 30];
        Cn_beta  = [0 2 5 10];
        Cn = [0 0.46 1.15 2.30
              0 0.56 1.40 2.80
              0 1.00 2.00 4.00
              0 0.50 1.40 3.00
              0 0.80 1.80 3.00
              0 0.60 1.50 3.00
              0 0.70 1.00 1.20
              0 0.17 0.53 0.99
              0 -0.29 -0.24 0.02]*1e-2;
        CYb = -0.01242; % per deg
        Clb = -0.00787; % per deg

        % damping coefficients (per rad/sec)
        Cdamp_alpha = [0 5 10 12 14 16 18 20 22 25 30];
        Cmq = [-2.03 -1.58 -1.16 -1.76 -1.76 -1.75 -1.74 -2.52   -2.99  -5.71  -8   ]*1e-1;
        Cnp = [ 3.81  3.53  2.19  2.44  1.79  1.67  2.01  2.22    3.07   3.79   8.50]*1e-1;
        Clp = [-4.98 -6.0  -3.98 -5.79 -4.25 -4.99 -6.49 -6.19   -8.10  -8.72 -24.10]*1e-1;
        Cnr = [-7.94 -8.37 -9.21 -9.22 -8.67 -9.22 -9.46 -10.07 -10.90 -12.86 -20.41]*1e-1;
        Clr = [ 4.96  5.98  8.40  8.06  6.86  5.72  6.03  8.99    9.57  13.57  44.90]*1e-1;
        
        % δe : symmetric wing flaps (elevator) 
        % filas: [1 α α² α³ α^4]
        Pde = [ 5.140e-3 -1.903e-3 -1.854e-4
                3.683e-5 -1.593e-5  2.830e-6
               -6.092e-6  2.611e-6 -6.966e-7
                2.818e-9  5.116e-8  1.323e-7
               -2.459e-9 -1.626e-9 -2.758e-9];        
        % δa : differential wing flaps (ailerons)
        % filas: [1 α α² α³ α^4]
        Pda = [-2.503e-4  1.471e-4  9.776e-4  3.357e-3 -2.769e-3  2.538e-3 
                4.987e-5  4.673e-5 -2.703e-5 -1.661e-5 -4.377e-5  1.963e-5
               -2.274e-6 -8.282e-6 -8.303e-6 -3.280e-6  9.952e-6 -3.725e-6
               -1.407e-7  4.891e-7  6.645e-7  5.526e-8 -3.642e-7  3.539e-8
                5.135e-9 -8.742e-9 -1.273e-8 -3.269e-10 4.692e-9 -1.778e-10];         
        % δf+ : positive (lower) body flaps
        % filas: [1 α² α^4]
        Pfp = [ 3.779e-3 -9.896e-4 1.310e-4
               -7.017e-7 -1.494e-9 1.565e-6
                1.400e-10 6.303e-11 -1.542e-9];
        % δf- : negative (upper) body flaps
        % filas: [1 α α² α³ α^4]
        Pfn = [ 3.711e-3 -1.086e-3 -4.415e-4
               -3.547e-5  1.570e-5 -4.056e-6
               -2.706e-6 -4.174e-7 -4.657e-7
                2.938e-7 -1.133e-7  0
               -5.552e-9  2.723e-9  0];
        % δΔf : differential body flaps
        % filas: [1 α α² α³ α^4]
        Pdf = [-6.043e-4  2.672e-5 -5.107e-5   7.453e-4
               -1.858e-5 -3.849e-5  1.108e-5  -1.811e-5
                8.000e-7  4.564e-7 -1.547e-8  -1.264e-7
               -4.845e-8  1.798e-8 -1.552e-8   9.972e-8
                1.360e-9 -4.099e-10 1.413e-10 -2.684e-9];
        % δr  : all-movable rudder
        % filas: [1 α α² α³ α^4]
        Prd = [ 5.173e-4 -5.116e-5   5.812e-4  1.855e-3  -1.278e-3  2.260e-4
                7.359e-5 -1.516e-5   1.410e-5  1.128e-5   1.320e-5 -1.299e-5
               -8.270e-7  1.729e-6  -2.585e-6  6.069e-6  -4.720e-6  5.565e-6
               -6.034e-7 -2.481e-8   3.051e-7 -1.780e-7   2.371e-7 -3.382e-7
                2.016e-8 -7.867e-10 -8.161e-9 -1.886e-12 -3.340e-9  6.461e-9];
          
        % Real-Time Simulation Model of the HL-20 Lifting Body - NTRS - NASA
        % https://ntrs.nasa.gov/archive/nasa/casi.ntrs.nasa.gov/19920021916.pdf

        cbar =  28.24 * hl20.ft_2_m; 
        sref = 286.45 * hl20.ft_2_m^2; 
        bref =  13.89 * hl20.ft_2_m; 
        vlen = 27.31 * hl20.ft_2_m;      % Vehicle Length
        x_ref = 0.540 * hl20.vlen;       % Reference point from nose
        x_cg  = 0.575 * hl20.vlen;       % Center of Gravity (Full)
        mass = 11739;
        fuel =  2948 * hl20.lb_2_kg; 
        Ixx  = 12430;
        Iyy  = 72478;
        Izz  = 72478;
    end
end

