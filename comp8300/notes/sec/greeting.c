#include <mpi.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char** argv) {
    MPI_Init(&argc, &argv);

    int world_rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);

    int world_size;
    MPI_Comm_size(MPI_COMM_WORLD, &world_size);

    const int MAX_STRING = 100;
    char greeting[MAX_STRING];

	// i sends msg to i+1 but the last proc sends msg to p0
	int next_rank = (world_rank + 1) % world_size;

    if (world_rank != 0) {
        // Receive a message from the previous process
        MPI_Recv(greeting,		 /* data */
				 MAX_STRING,	 /* data num */
				 MPI_CHAR,		 /* data type  */
				 world_rank - 1, /* source */
				 0,				 /* tag */
				 MPI_COMM_WORLD, /* communicator */
				 MPI_STATUS_IGNORE);
        printf("Process %d received message '%s' from process %d\n",
			   world_rank, greeting, world_rank - 1);
    } else {
        // Process 0 starts the chain
        snprintf(greeting, MAX_STRING, "Hello from process %d", world_rank);
    }

    // Send the message to the next process
    MPI_Send(greeting,
			 strlen(greeting) + 1,
			 MPI_CHAR,
			 next_rank,
			 0,
			 MPI_COMM_WORLD);

    // Process 0 receives the message from the last process to complete the chain
    if (world_rank == 0) {
        MPI_Recv(greeting,
				 MAX_STRING,
				 MPI_CHAR,
				 world_size - 1,
				 0,
				 MPI_COMM_WORLD,
				 MPI_STATUS_IGNORE);
        printf("Process %d received message '%s' from process %d\n",
			   world_rank, greeting, world_size - 1);
    }

    MPI_Finalize();
    return 0;
}
