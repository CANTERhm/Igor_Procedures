#pragma rtGlobals=3		// Use modern global access method and strict wave access.

function bimodal_fit_aggrecan([ind])

// initialisation of variables and waves
variable ind					// optional variable to match the window position of the result histogram with a pre-processed function
variable end_value = 3e6
variable bin_width = 30e3
variable bin_num
variable A1
variable E1
variable w1
variable A2
variable E2
variable w2
variable y_max
variable x_min
variable x_max
variable x_mean
variable x_sdev
variable first_peak
variable second_peak
variable ges_wave_max
variable gauss_num
variable stat_chioce

KillWaves/A/Z

string wave_name_y
string first_peak_string
string second_peak_string
string unit
string text_string
string stat_prompt

wave Young_s_Modulus_ges_Hist


// determin initial values for end_value and bin_width
DoWindow  Result_Table
if (V_flag == 1)
	variable wave_check
	wave_check=WaveExists($"Young_s_Modulus_ges")
	if (wave_check==1)
		ges_wave_max = WaveMax($"Young_s_Modulus_ges")
		end_value = ges_wave_max
	endif
endif


// dialog to get the Wave, end_value and bin_width
string hist_wave_name = "Young_s_Modulus_ges"
prompt hist_wave_name,"Choose wave for histogram",popup,WaveList("*",";","")
prompt bin_width,"Enter the bin width of histogram:"
prompt end_value,"Enter last value of histogram evaluation and plot:"
prompt stat_prompt,"Would you like to get a statistics table?",popup,"no;yes"
DoPrompt "Select wave and define histogram parameters",hist_wave_name,bin_width,end_value,stat_prompt

stat_chioce = 0
if (stringMatch(stat_prompt,"yes"))
	stat_chioce = 1
endif
	

wave hist_wave = $hist_wave_name

if (V_flag == 1)
	return -1
endif

// create Histogram of choosen wave
DoWindow Resulting_Histogram
if (V_flag == 1)
	KillWindow Resulting_Histogram
endif

bin_num = end_value/bin_width
print bin_num

try
	Make/N=(bin_num)/O Young_s_Modulus_ges_Hist
catch
	// me if you can
endtry

Histogram/C/B={0,bin_width,bin_num} hist_wave,Young_s_Modulus_ges_Hist
Display/M/W=(20+ind,2+ind,20+13.8994+0.0352+ind,7.33778+0.03528+2+ind) /N=Resulting_Histogram Young_s_Modulus_ges_Hist
Make/D/O/N=(bin_num) x_hist
x_hist = p*bin_width


// Modify Histogram apperance
ModifyGraph mode=5,hbFill=5
SetAxis bottom,0,end_value
if (end_value/1e6>=1)
	ModifyGraph prescaleExp(bottom)=-6
	Label bottom "Young's Modulus [MPa]"
elseif (end_value/1e3<1)
	Label bottom "Young's Modulus [Pa]"
else
	ModifyGraph prescaleExp(bottom)=-3
	Label bottom "Young's Modulus [kPa]"
endif



// calculate initial values for bimodal fit
WaveStats/Q $hist_wave_name
x_min = V_min
x_max = V_max
x_mean = V_avg
x_sdev = V_sdev
wave_name_y = WaveName("Resulting_Histogram",0,1)

WaveStats/Q Young_s_Modulus_ges_Hist
y_max = V_max
A1 = y_max-y_max*0.1
E1 = x_hist[V_maxRowLoc]
w1 = x_sdev/2
A2 = 1/3*A1
E2 = x_mean + x_sdev
w2 = x_sdev

print A1,E1,w1,A2,E2,w2

// fit the bimodal distribution to histogram
try
	Make/D/N=6/O W_coef
catch
	// me if you can
endtry

W_coef[0] = {A1,E1,w1,A2,E2,w2}
FuncFit/X=1/NTHR=0 bimodal W_coef  Young_s_Modulus_ges_Hist /D 

// modify fit apperance and add single gussian distributions to graph
ModifyGraph rgb(fit_Young_s_Modulus_ges_Hist)=(0,15872,65280)
ModifyGraph lsize(fit_Young_s_Modulus_ges_Hist)=1.2
KillWaves/Z  y_Gauss1,y_Gauss2,x_Gauss
try
	Make/O/N=60000/D y_Gauss1,y_Gauss2,x_Gauss
catch
	// me if you can
endtry

gauss_num = end_value/60000
x_Gauss = p*gauss_num
y_Gauss1=W_coef[0]*exp(-((x_Gauss-W_coef[1])/W_coef[2])^2)
y_Gauss2=W_coef[3]*exp(-((x_Gauss-W_coef[4])/W_coef[5])^2)		
AppendToGraph/W=Resulting_Histogram y_Gauss1,y_Gauss2 vs x_Gauss							
ModifyGraph mode(y_Gauss1)=0,lstyle(y_Gauss1)=7,rgb(y_Gauss1)=(0,0,0);DelayUpdate
ModifyGraph mode(y_Gauss2)=0,lstyle(y_Gauss2)=7,rgb(y_Gauss2)=(0,0,0)
SetAxis/A/N=1 left

// append text to graph with the right peak values and units
first_peak = W_coef[1]
second_peak = W_coef[4]

	if (first_peak >= 1e6)
		first_peak = first_peak/1e6	
		unit = "MPa"
		sprintf first_peak_string,"%.2f %s",first_peak,unit
	elseif (first_peak<1e3)
		first_peak = first_peak
		unit = "Pa"
		sprintf first_peak_string,"%.2f %s",first_peak,unit	
	else
		first_peak = first_peak/1e3
		unit = "kPa"
		sprintf first_peak_string,"%.2f %s",first_peak,unit					
	endif
	
	if (second_peak >= 1e6)
		second_peak = second_peak/1e6	
		unit = "MPa"
		sprintf second_peak_string,"%.2f %s",second_peak,unit
	elseif (second_peak<1e3)
		second_peak = second_peak
		unit = "Pa"
		sprintf second_peak_string,"%.2f %s",second_peak,unit
	else
		second_peak = second_peak/1e3
		unit = "kPa"
		sprintf second_peak_string,"%.2f %s",second_peak,unit					
	endif

sprintf text_string,"Peak values:\rE1 = %s\rE2 = %s",first_peak_string,second_peak_string
TextBox/W=Resulting_Histogram/A=RT/C/N=text0 text_string

// save histogram as tiff

DoAlert /T="Save histogram as tiff" 1,"Do you want to save the final histogram as a tiff-file?"
if (V_flag == 1)
	SavePICT/E=-7/RES=600/M/W=(0,0,14,7.5)
endif

if (stat_chioce == 1)
	

	variable leftx_hist
	variable leftx_center_hist
	variable rightx_hist
	variable rightx_center_hist
	variable deltax_hist
	variable i
	variable hist_append
	variable p_before
	
	// bin_width
	try
		Make/T peak_name = {"Peak 1","Peak 2"}
		Make histx_calculated = {0}
		Make peak_pos = {0,0}
		Make peak_standard_deviation = {0,0}
		Make values_in_distribution = {0,0}
		Make peak_standard_error = {0,0}
	catch
		// me if you can
	endtry
	
	deltax_hist = deltax(Young_s_Modulus_ges_Hist)
	leftx_hist = leftx(Young_s_Modulus_ges_Hist)
	leftx_center_hist = leftx_hist + deltax_hist/2
	rightx_hist = rightx(Young_s_Modulus_ges_Hist)
	rightx_center_hist = rightx_hist - deltax_hist/2
	
	DeletePoints 1,numpnts(histx_calculated),histx_calculated
	histx_calculated[0] = leftx_center_hist
	i = 1
	do
		p_before = numpnts(histx_calculated)
		InsertPoints p_before,1,histx_calculated
		hist_append = histx_calculated[i-1]+deltax_hist
		histx_calculated[i] = hist_append
		i += 1
	while (hist_append <= rightx_center_hist)
	
	try
		Make/N=(numpnts(histx_calculated)) bin_heigths
	catch
		// me if you can
	endtry
	
	peak_pos[0] = W_coef[1]
	peak_pos[1] = W_coef[4]
	peak_standard_deviation[0] = W_coef[2]/sqrt(2)
	peak_standard_deviation[1] = W_coef[5]/sqrt(2)
	bin_heigths = W_coef[0]*exp(-((histx_calculated-W_coef[1])/W_coef[2])^2)
	values_in_distribution[0] = floor(sum(bin_heigths))
	bin_heigths = W_coef[3]*exp(-((histx_calculated-W_coef[4])/W_coef[5])^2)
	values_in_distribution[1] = floor(sum(bin_heigths))
	peak_standard_error[0] = peak_standard_deviation[0]/sqrt(values_in_distribution[0])
	peak_standard_error[1] = peak_standard_deviation[1]/sqrt(values_in_distribution[1])
	
	
	Edit peak_name,peak_pos,peak_standard_deviation,values_in_distribution,peak_standard_error as "Statistics Table"
	
endif

end
