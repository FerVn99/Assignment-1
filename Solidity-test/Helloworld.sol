// SPDX-License-Identifier: UNLICENSED.
pragma solidity ^0.8.0;

/* 
* Simple "Hello World" contract.
* By Fernando V.
*/

//Defining the contract name.
contract Hi {
    
    uint HelloWorld;
    
    //storing the unsigned integer
    function store(uint helloWorldimp) public {
         HelloWorld = helloWorldimp;
    }
    
    //Retrieving the previously stored integer and returning it.
    function retrieve() public view returns(uint) {
        return HelloWorld;
    }
}

