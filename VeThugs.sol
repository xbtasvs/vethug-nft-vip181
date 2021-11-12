// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import './ERC721Full.sol';
import './Ownable.sol';
contract VeThugs is ERC721Full, Ownable {

  string _baseTokenURI;
  address payable private admin = 0x48dd2157324C94129bBc1ca881919b3c23b3ebee;
  uint256 public constant MAX_ENTRIES = 10000;
  uint256 public constant PRESALE_ENTRIES = 600;
  uint[10] private PRICES =  [ 390 ether, 780 ether, 1170 ether, 1560 ether, 1950 ether, 2000 ether, 2000 ether, 2000 ether, 2000 ether, 2000 ether];
  uint8[2] private MAX_BUYABLE = [1, 10];
  uint8 private currentPriceId = 0;
  mapping (address=>bool) public whitelisted;
  uint256 public totalMinted;
  uint256 public whitelistAccessCount;
  bool public saleStarted;
  uint public startBlock;
  uint256 public blockTime = 13;
  constructor() public
    ERC721Full("VeThugs", "VeThugs") {
      saleStarted = false;
  }
  function giveAway() external {
    require(saleStarted == false, "giveAway amount exceed");
    for (uint8 i = 1; i <= 100; i++)
      _safeMint(admin, i);
    totalMinted = 100;
    saleStarted = true;
    startBlock = block.number;
  }
  function setBlockTime(uint blockT) public onlyOwner {
    blockTime = blockT;
  }
  function mint(uint256 _amount) external payable {
    require(saleStarted == true, "Sale has not started");
    require(_amount + totalMinted <= MAX_ENTRIES, 'Amount exceed');
    if ((block.number - startBlock) * blockTime < 86400) {
      require(totalMinted + _amount <= PRESALE_ENTRIES , "PRESALE LIMIT EXCEED");
      require(whitelisted[msg.sender], 'Only whitelisted address can mint first 500 NFTs');
      require(balanceOf(msg.sender)+_amount <= MAX_BUYABLE[0], 'BUYABLE LIMIT EXCEED');
    }
    else {
      require(_amount <= MAX_BUYABLE[1], 'BUYABLE LIMIT EXCEED');
    }

    uint256 amountForNextPrice = 1000 - (totalMinted % 1000);
    uint256 estimatedPrice = 0;
    if (_amount > amountForNextPrice) {
      estimatedPrice = PRICES[currentPriceId] * amountForNextPrice + PRICES[currentPriceId+1] * (_amount-amountForNextPrice);
      currentPriceId += 1;
    } else {
      estimatedPrice = PRICES[currentPriceId] * _amount;
    }
    require(msg.value >= estimatedPrice, "FTM.VeThugs: incorrect price");
    admin.transfer(address(this).balance);
    for (uint8 i = 1; i <= _amount; i++)
      _safeMint(msg.sender, (totalMinted + i));
    totalMinted += _amount;      
  }

  function _baseURI() internal view returns (string memory) {
    return _baseTokenURI;
  }

  function setBaseURI(string memory baseURI) public onlyOwner {
    _baseTokenURI = baseURI;
  }

  function getCurrentPrice() external view returns (uint256) {
    return PRICES[currentPriceId];
  }

  function addWhiteListAddresses(address[] calldata addresses) external onlyOwner {
    require ( whitelistAccessCount+addresses.length <= 500, "Whitelist amount exceed");
    for (uint8 i = 0; i < addresses.length; i++) 
      whitelisted[addresses[i]] = true;
    whitelistAccessCount += addresses.length;
  }
  
}