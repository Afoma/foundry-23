Remember that to create a variable in Solidity, you have to follow the syntax of 
`type visibility name`

Because with each deployment of the contract below, a new instance of the `SimpleStorage` is created in the `StorageFactory` contract.
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {SimpleStorage} from "contracts/SimpleStorage.sol";

contract StorageFactory{

    SimpleStorage public simpleStorage;

    function createSimpleStorage() public{
        simpleStorage = new SimpleStorage();
    }
}
```
However, the deployed contracts are not beig saved, so we will rewrite some parts of the code.
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {SimpleStorage} from "contracts/SimpleStorage.sol";

contract StorageFactory{

    SimpleStorage[] public listOfSimpleStorageContracts;

    function createSimpleStorage() public{
        SimpleStorage newSimpleStorage = new SimpleStorage();
        listOfSimpleStorageContracts.push(newSimpleStorage);
    }
}
```
notice that ` SimpleStorage newSimpleStorage` doesn't have memory in between. this is because contracts are not deployed to memory but to the blockchain, hence to storage references and not memory.
for us to interact with other contracts or some parts of another contract, we need two things- address and ABI (Application Binary Interface). the ABI tells our code exactly how it can interact with another contract. 


in the first part of a function, if there will be parameters, they will have names but in a return function, the paramters or the things in the bracket won't have names but they will only be displayed as the variable types like `uint256`, `string memory`, `address`, etc, like this
```
    function retrieve() public view returns (string memory, uint256) {
        return (names, numbers);
    }
```

it is the data set `string, uint256` that is written in the `returns` statement that tells the compiler what the function will be returning and not by the name `names, numbers` the `return` keyword intends to return because that is just an english name and the compiler converts code and not english to byte-readable code. however, it is best practise to give meaningful names so that the code will be easily understandable by a human being.
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {SimpleStorage} from "contracts/SimpleStorage.sol";

contract StorageFactory{

    SimpleStorage[] public listOfSimpleStorageContracts;

    function createSimpleStorage() public{
        SimpleStorage newSimpleStorage = new SimpleStorage();
        listOfSimpleStorageContracts.push(newSimpleStorage);
    }
    function sfStore(uint256 _simpleStorageIndex, uint256 _newSimpleStorageNumber) public{
        SimpleStorage mySimpleStorage = listOfSimpleStorageContracts[_simpleStorageIndex];
        mySimpleStorage.store(_newSimpleStorageNumber);
    }
    function sfGet(uint256 _simpleStorageIndex) public view returns(uint256){
        SimpleStorage mySimpleStorage = listOfSimpleStorageContracts[_simpleStorageIndex];
        return mySimpleStorage.retrieve();
    }
    
}
```
know that the `.store` and `.retrieve` you see in the code aren't written there as default solidity methods, rather, they are written there to access `function store` and `function retrieve` in the SimpleStorage contract.

do you know why this function has a parameter in it

function sfGet(uint256 _simpleStorageIndex) public view returns(uint256){
        return listOfSimpleStorageContracts[_simpleStorageIndex].retrieve();
    }

and this one doesn't have

    function getlistOfSimpleStorageContractsLength() public view returns(uint256){
        return listOfSimpleStorageContracts.length;
    }
it is because in Solidity, a parameter is added to a function when you need to pass some data from outside the contract into it. The `_simpleStorageIndex` in `sfGet()` serves as an identifier for which specific instance of `SimpleStorage` you want to retrieve information about.
The difference between these two functions lies in what they're trying to achieve:

`getlistOfSimpleStorageContractsLength()`: This function simply returns the length (i.e., number) of contracts stored in an array (`listOfSimpleStorageContracts`). It doesn't need any specific data from outside, so it has no parameters.
`sfGet(uint256 _simpleStorageIndex)`: Here, you're trying to retrieve information about a particular contract instance based on its index within the `listOfSimpleStorageContracts` array. This requires knowing which index (`_simpleStorageIndex`) corresponds to that specific contract.
