#include <stdio.h>

int main() {
	int i,j,k;
	// for each row in matrix A
	for (i=0; i<n; ++i) {
		// for each col in matrix B
		for (j=0; j<n; ++j) {
			// init C[ij] to 0 as accumulator
			C[i][j] = 0;
			// sum-reduce a[i][j] x b[j][i] to C[i][j]
			for (k=0; k<n; ++k) {
				// in each loop of k, i,j remian unchanged
				C[i][j] = C[i][j] + A[i][k] * B[k][j]
			}
		}
	}
}
