#pragma rtGlobals=3		// Use modern global access method and strict wave access.
Function bimodal(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = A1*exp(-((x-E1)/w1)^2)+A2*exp(-((x-E2)/w2)^2)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 6
	//CurveFitDialog/ w[0] = A1
	//CurveFitDialog/ w[1] = E1
	//CurveFitDialog/ w[2] = w1
	//CurveFitDialog/ w[3] = A2
	//CurveFitDialog/ w[4] = E2
	//CurveFitDialog/ w[5] = w2

	return w[0]*exp(-((x-w[1])/w[2])^2)+w[3]*exp(-((x-w[4])/w[5])^2)
End