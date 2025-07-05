// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18; //solidity versions

contract SimpleStorage {
    uint256 public myFavouriteNumber;

    struct Person {
        uint256 favouriteNumber;
        string name;
    }

    Person[] public listOfPeople;

    mapping(string => uint256) public nameToFavouriteNumber;

    function store(uint256 _favouriteNumber) public virtual {
        myFavouriteNumber = _favouriteNumber;
    }

    function retrieve() public view returns (uint256) {
        return myFavouriteNumber;
    }

    function addPerson(string memory _name, uint256 _favouriteNumber) public {
        // Person memory newPerson = Person(_name, _favNumber);
        // listOfPeople.push(newPerson);
        listOfPeople.push(Person(_favouriteNumber, _name));
        nameToFavouriteNumber[_name] = _favouriteNumber;
    }

    function displayListOfPeople() public view returns (Person[] memory) {
        return listOfPeople;
    }
}
