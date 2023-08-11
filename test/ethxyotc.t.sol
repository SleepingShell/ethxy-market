pragma solidity 0.8.21;

import "forge-std/Test.sol";
import "../src/ethxyotc.sol";

contract ethxyotcTest is Test {
  ethxyotc otc;

  function setUp() public {
    otc = new ethxyotc();
  }
}