pragma circom 2.0.0;

include "mimcsponge.circom";


template MerkleTree (n) {  

   signal input leaves[n]; 
   signal output root;  
   var N = n*2-1;
   signal hashes[N];
   component components[N];
    var k = 0;
    var j = 0;
    
    for(var i = 0; i < N; i++) {
        if(i < n) {
            // hashing the leaves
            components[i] = MiMCSponge(1, 220, 1);
            components[i].k <== i;
            components[i].ins[0] <== leaves[i];
        } else {
            // Here, from bottom to top, we are constructing the tree
            components[i] = MiMCSponge(2, 220, 1);
            components[i].k <== i;
            components[i].ins[0] <== hashes[j];
            components[i].ins[1] <== hashes[j+1];
            j+=2;
        }
        hashes[i] <== components[i].outs[0];
    }

    // we are returning hash of root
    root <== hashes[N-1];
} 

//Here we declare the input as "public"
component main {public [leaves]} = MerkleTree(8);