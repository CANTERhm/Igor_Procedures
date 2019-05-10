#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.


function save_graph_as_tif([dpi_value])

variable dpi_value

if (dpi_value == 0)

	dpi_value = 600
	
endif

SavePICT/E=-7/RES=(dpi_value)/M/W=(0,0,14,7.5)


end