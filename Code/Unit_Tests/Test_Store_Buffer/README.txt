Simple unit-tester for Store_Buffer.

'mkTop' instantiates the Store-buffer,
    sends it requests from a StmtFSM,
    prints and drain responses.
    See test1, test2, ... in Top.bsv for which test is run.

On the other side of the store-buffer, mkTop models a simple small memory.

The StmtFSM has a macro `DELAY defined to either delay the FSM after
each request from the Tb to the store-buffer, or allow pipelined
access.  The former (delay) prevents interleaving of debug messages.
The final outputs should be the same, either way.
