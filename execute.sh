

circom merkle.circom --r1cs --wasm --sym --c



node generate_witness.js merkle.wasm input.json witness.wtns


snarkjs powersoftau new bn128 14 pot14_0000.ptau -v

snarkjs powersoftau contribute pot14_0000.ptau pot14_0001.ptau --name="First contribution" -v



snarkjs powersoftau prepare phase2 pot14_0001.ptau pot14_final.ptau -v

snarkjs groth16 setup merkle.r1cs pot14_final.ptau merkle_0000.zkey

snarkjs zkey contribute merkle_0000.zkey merkle_0001.zkey --name="1st Contributor Name" -v

snarkjs zkey export verificationkey merkle_0001.zkey verification_key.json



snarkjs groth16 prove merkle_0001.zkey witness.wtns proof.json public.json



snarkjs groth16 verify verification_key.json public.json proof.json



snarkjs zkey export solidityverifier mtree_0001.zkey verifier.sol