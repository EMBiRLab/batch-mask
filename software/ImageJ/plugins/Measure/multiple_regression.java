import ij.*;
import ij.process.*;
import ij.gui.*;
import java.awt.*;
import ij.plugin.*;
import ij.plugin.frame.*;

import ij.measure.ResultsTable;

import Jama.Matrix;
import Jama.QRDecomposition;

public class  multiple_regression implements PlugIn {

public void run(String arg) {

	ResultsTable rt =  ResultsTable.getResultsTable();

	String[] columns = rt.getHeadings();

	int N = 0;        // number of 
	int p = 0;        // number of dependent variables
	Matrix beta;  // regression coefficients
	double SSE = 0.0;         // sum of squared
	double SST = 0.0;         // sum of squared

	double[] y = rt.getColumnAsDoubles(0);

	double[][] x = new double[y.length][columns.length];

	for(int i=1; i<columns.length; i++){
		double[] tempX = rt.getColumnAsDoubles(i);
		for(int j=0; j<y.length; j++)
			x[j][i] = tempX[j];
	}
	for(int j=0; j<y.length; j++)
		x[j][0] = 1.0; // fill first column with ones
		

	if (x.length != y.length) throw new RuntimeException("dimensions don't agree");	
	N = y.length;
	p = x[0].length;

	Matrix X = new Matrix(x);

	// create matrix from vector
	Matrix Y = new Matrix(y, N);

	// find least squares solution
	QRDecomposition qr = new QRDecomposition(X);
	beta = qr.solve(Y);



	// mean of y[] values
	double sum = 0.0;
	for (int i = 0; i < N; i++)
		sum += y[i];
	double mean = sum / N;

	// total variation to be accounted for
	for (int i = 0; i < N; i++) {
		double dev = y[i] - mean;
		SST += dev*dev;
	}

	// variation not accounted for
	Matrix residuals = X.times(beta).minus(Y);
	SSE = residuals.norm2() * residuals.norm2();

	IJ.log("Multiple Linear Regression Results");


	//IJ.log("Intercept: " + beta.get(0,0));
	//for(int i = 1; i<columns.length; i++)
	//	IJ.log(columns[i] + ": " + beta.get(i,0));
	IJ.log("R2: " + (1.0 - SSE/SST) );

	String eqn = beta.get(0,0) + " ";
	for(int i = 1; i<columns.length; i++)
		eqn += "+(" + columns[i] + "*" + beta.get(i,0) + ")";
	IJ.log(eqn);

}
}
