
clc;
close all;
clear all;
%%TAKE INPUT

S=input('Enter the KVA Rating')
 
%%VOLTAGE PER TURN 
ET=.4564*sqrt(S)
ET=input('choose Et :');
Bmax=input('Enter Flux Density :');
Ai=ET*1e6/(4.44*50*Bmax)
d=sqrt(4*Ai/(.88*.92*pi))
d=input('Specify d in mm :');
Ai=.88*.92*pi*(d^2)/4
Bmax=ET*1e6/(4.44*50*Ai)
 
%%WINDOW AREA
CD=input('Enter current density :');
Hv=input('Enter high volatge in KV :')
Kw=10/(30+Hv)
Aw=(S*1e9)/(3.33*Ai*Kw*CD*Bmax*50)
width=input('enter  window  width :');
height=input('enter window height :');
Aw=height*width
Dactual=.95*d
tot_width=(3*Dactual+2*width)
tot_hight=878
%%TURN NUMBER OF L.V. WINDING
 
Lv=input('Enter low volatge in volts :');
fprintf('For Low Voltage Side:\n');
Lv_con=input('If star connected type "s"\nIf delta connected type "d" :','s')
if Lv_con=='s'
    LVpri=(Lv/sqrt(3))
else
    LVpri=Lv
end
LV_Win_Turn=25
%%TURN NUMBER IN H.V. WINDING
 
Hv=input('Enter high volatge in volts :');
fprintf('For High Voltage Side:\n');
Hv_Connection=input('If star connected type "s"\nIf delta connected type "d" :','s')
if Hv_Connection=='s'
    HVpri=(Hv/sqrt(3))
else
    HVpri=Hv
end
Hv_Winding_Turn=(round(HVpri/ET))
 
%%L.V. WINDING
 
if Lv_con=='s'
    Ip_lv=(S*1000)/(sqrt(3)*Lv)
else
    Ip_lv=(S*1000)/(3*Lv)
end
Area_LV_cond=Ip_lv/CD
fprintf('For Low Voltage Side:\n');
x1=input('Thikness of coductor:>>')
y1=input('Width of conductor:>>')
Area_LV_cond=round(2*x1*y1)
 
%%H.V. WINDING
 
if Hv_Connection=='s'
    IpH=(S*1000)/(sqrt(3)*Hv)
else
    IpH=(S*1000)/(3*Hv)
end
Area_HV_cond=IpH/CD
Con_dia=sqrt(4*Area_HV_cond/pi);
fprintf('Calculated h.v. conductor Diameter in mm =%f \n',Con_dia);
Con_dia=input('Choose h.v. conductor Diameter in mm:>>')
Area_HV_cond=(pi*Con_dia^2)/4
C_area_W=2*((Area_LV_cond*LV_Win_Turn)+(Area_HV_cond*Hv_Winding_Turn))
 
%%Design and layout of l.v winding
layer_LV=input('\n Choose layer of l.v. winding:>>')
turn_per_layer_lv=round(LV_Win_Turn/layer_LV)
Hight_lv_winding=round(turn_per_layer_lv*(y1+0.25))
thickness_lv=2*2*(x1+.25)
Inner_dia_lv=d+(2*3.5)
Outer_dia_lv=(Inner_dia_lv+2*thickness_lv)
Mean_dia_lv=(Inner_dia_lv+thickness_lv)
Mean_length_turn_lv=pi*Mean_dia_lv
 
%%Design and layout of h.v winding
Inner_dia_hv=Outer_dia_lv+(2*12)
Turn_Each_coil=round(Hv_Winding_Turn/4)
D_with_insulation=Con_dia+.25 %h.v. conductor diameter with paper insulation
layer_HiV=input('Choose layer of h.v. winding:>>')
turn_per_layer_hv=(Turn_Each_coil/layer_HiV)
hight_hv_per_coil=(turn_per_layer_hv*D_with_insulation)
Thickness_each_coil_hv=layer_HiV*D_with_insulation
Outside_dia_hv=(Inner_dia_hv+(Thickness_each_coil_hv*2))
Mean_dia_hv=(Inner_dia_hv+Outside_dia_hv)/2
Mean_length_turn_hv=pi*Mean_dia_hv
Height_hv_coil_window=(hight_hv_per_coil*4)+8+8+8
Height_window_requird=Height_hv_coil_window+26*2
if (Height_window_requird>height)
    fprintf('Re-enter the hight of window')
end
 
%%Precentage reactance
Avg_length=(Mean_length_turn_lv+Mean_length_turn_hv)/2
AT=LV_Win_Turn*Ip_lv
Mean_height=(Height_hv_coil_window+Hight_lv_winding)/(2*1000) %in meter.
a1=12;b1=Thickness_each_coil_hv;b2=thickness_lv
c1=a1+((b1+b2)/3) %in mm.
per_reactance=((2*pi*50*4*pi*1e-7*(Avg_length/1000)*AT*(c1/1000))*100)/(Mean_height*ET)
 
%%Percentage resistance
P20=0.01724 
a20=.00393
P75=P20*(1+(a20*(75-20)))
Res_lv_winding=(P75*Mean_length_turn_lv*LV_Win_Turn)/(Area_LV_cond*1000)
Res_hv_winding=(P75*Mean_length_turn_hv*Hv_Winding_Turn)/(Area_HV_cond*1000)
Ratio_transf=(HVpri/LVpri)
Req=Res_hv_winding+((Ratio_transf)^2*Res_lv_winding)
per_resistance=(Req*IpH*100)/HVpri
 
%%percentage impedence
 
per_impedence=sqrt((per_resistance)^2+(per_reactance)^2)
 
%%Core Loss
 
wei_core_yoke=(Ai*(2*tot_width+3*height)*7.85)/(1000*1000)
core_loss_per_kg=input('Enter core loss for Bmax :')
Core_Loss=wei_core_yoke*core_loss_per_kg
 
%%copper loss
 
C_loss=3*IpH*IpH*Req;
fprintf('copper loss = %.2f\n',C_loss);
 
%%add stray loss 7% then load loss at 75 degree
Load_loss_with_stray=C_loss*1.07;
fprintf('LOAD loss %.2f\n',Load_loss_with_stray);
NoLoad_loss=Core_Loss
Tot_loss=Load_loss_with_stray+NoLoad_loss;%total loss
fprintf('Total loss %.2f\n',Tot_loss);
 
%%Efficiency
 
Pf=input('Enter Power Factor:')
OP=S*1000*Pf;
load_a=input('Enter amount of load in percentage:')
Loadlossfinal=Load_loss_with_stray*(load_a/100)*(load_a/100)';
Tot_loss_final=Loadlossfinal+Core_Loss;
Efficiency=OP/(OP+Tot_loss_final);
fprintf('Efficincy on %.2f percent load is : %.2f',load_a,Efficiency)

