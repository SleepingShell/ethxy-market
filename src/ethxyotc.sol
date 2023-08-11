pragma solidity ^0.8.21;

interface IEthXY {
  function grid(uint256 plotid) external view returns (address, uint256);
}

contract ethxyotc {
  IEthXY constant ethxy = IEthXY(0xB1e69773b35a7785A87deA6f010AF155102F282D);

  struct Listing {
    address owner;
    uint128 value;
    uint128 cancelBlock;
  }

  mapping(uint256 => Listing) public listings;

  function increaseSingle(uint256 plotid) external payable {
    _increaseOffer(plotid, uint128(msg.value));
  }

  function increaseMany(uint256[] calldata plotids, uint256[] calldata values) external payable {
    uint256 total;
    for (uint i = 0; i < plotids.length; i++) {
      _increaseOffer(plotids[i], uint128(values[i]));
      total += values[i];
    }
    require (total <= msg.value);
  }

  function initiateCancel(uint256[] calldata plotids) external {
    for (uint i = 0; i < plotids.length; i++) {
      _cancelOffer(plotids[i]);
    }
  }

  function claimCancel(uint256[] calldata plotids) external {
    uint total;
    for (uint i = 0; i < plotids.length; i++) {
      Listing storage listing = listings[plotids[i]];
      require(msg.sender == listing.owner);
      require(block.number >= listing.cancelBlock && listing.cancelBlock != 0);
      total += listing.value;
      delete listings[plotids[i]];
    }
    payable(msg.sender).transfer(total);
  }

  function claim(uint256 plotid) external {
    (address curOwner,) = ethxy.grid(plotid);
    require(msg.sender == curOwner);
    Listing memory listing = listings[plotid];
    payable(msg.sender).transfer(listing.value);

    delete listings[plotid];
  }
  
  function _increaseOffer(uint256 plotid, uint128 value) internal {
    Listing storage listing = listings[plotid];
    if (listing.owner == address(0)) {
      (listing.owner,) = ethxy.grid(plotid);
    }
    unchecked {
      listing.value += value;
    }
  }

  function _cancelOffer(uint256 plotid) internal {
    Listing storage listing = listings[plotid];
    require(msg.sender == listing.owner);

    listing.cancelBlock = uint128(block.number + 20);
  }
}