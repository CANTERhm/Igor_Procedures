#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#include ":Igor Procedures:bimodal_fit_aggrecan"

function multi_map_processing()

// kill all waves not in use
KillWaves/A/Z

// initialisation of waves, variables and strings
wave Young_s_Modulus_ges
variable refNum
variable firstCol = 15
variable ind = 0
string Wave_string
string Hist_string
string Map_string
string message = "Select one or more tsv-files"
string outputPaths
string fileFilters = "Data Files (*.tsv):.tsv;"
fileFilters += "All Files:.*;"

// open dialog to choose multiple tsv-files
open /D /R /MULT=1 /F=fileFilters /M=message refNum
outputPaths=S_fileName

// prompt to enter the column of the tsv-files containing the right Young's Modulus values
prompt firstCol,"Enter the column number of the Young's Modulus values:"
DoPrompt "Enter column number",firstCol
if (V_Flag)
	return -1
	Print "Cancelled"
endif
firstCol -= 1

// get the Young's Modulus values from each file
if (strlen(outputPaths) == 0)
	Print "Cancelled"
else
	variable numFilesSelected = ItemsInList(outputPaths, "\r")
	variable i
	Edit /N=Result_Table
	for (i = 0; i<numFilesSelected; i+=1)
		// get Young's Modulus values from current file and append it to the result table
		String path = StringFromList(i,outputPaths,"\r")
		LoadWave /A=Young_s_Modulus_Pa_  /D /E=2 /J/K=0 /L={0,1,0,firstCol,1} path
		Wave_string = "Young_s_Modulus_Pa_"+num2str(i)
		AppendToTable /W=Result_Table $Wave_string 
		// add the Young's Modulus of the current file to the Young_s_Modulus_ges wave
		Concatenate /NP {$Wave_string},Young_s_Modulus_ges
		
		// create histogram of current map
		// Hist_string = Wave_string+"_Hist"
		// Make/N=50/O $Hist_string;
		// Histogram/C/B=1 $Wave_string,$Hist_string
		// Display/M/W=(20+i,1+i,13.8994,7.33778) $Hist_string
		// Map_string = "Map "+num2str(i+1)
		// TextBox/C/N=text0/A=RT Map_string
		// ModifyGraph mode=5,hbFill=5
		// Label bottom "Young's Modulus [Pa]"
		
		// create histogram of current map
		Hist_string = Wave_string+"_Hist"
		Make/N=50/O $Hist_string;
		Histogram/C/B=1 $Wave_string,$Hist_string
		Display/M/W=(20+i,2+i,20+13.8994+0.0352+i,7.33778+0.03528+2+i) $Hist_string
		Map_string = "Map "+num2str(i+1)
		TextBox/C/N=text0/A=RT Map_string
		ModifyGraph mode=5,hbFill=5
		Label bottom "Young's Modulus [Pa]"
	endfor
	AppendToTable /W=Result_Table Young_s_Modulus_ges
endif

bimodal_fit_aggrecan(ind=i)

end
