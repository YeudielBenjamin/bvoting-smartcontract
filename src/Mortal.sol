pragma solidity ^0.4.21;

import "./Owned.sol";

contract Mortal is Owned {
    function kill() onlyowner public {
        selfdestruct(owner);
    }
}