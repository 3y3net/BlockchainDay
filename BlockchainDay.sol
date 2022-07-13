//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// DEPLOYED AT: 0x710F8bC86dB7E72e81DE4FA71588A7Bd7aCe37eb
// POLYGON NETWORK


contract BlockchainDay is ERC1155Supply, AccessControlEnumerable, Ownable {
    
    bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;

    //Royaties address and amount
    address payable private _royaltiesAddress;
    uint96 _royaltiesBasicPoints;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant WITHDRAW_ROLE = keccak256("WITHDRAW_ROLE");

    constructor() ERC1155("http://nft.myownsatoshi.com/data/bday/{id}.json") {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(BURNER_ROLE, _msgSender());
        _setupRole(WITHDRAW_ROLE, _msgSender());

        //Royaties address and amount
        _royaltiesAddress=payable(address(this)); //Contract creator by default
        _royaltiesBasicPoints=500; //5% default
    }
    
    function mint (address _to, uint256 item, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(_to, item, amount, "");
    }

    function burn(address from, uint256 id, uint256 amount) public onlyRole(BURNER_ROLE) {
        require(balanceOf(from, id)>=amount, "Not enough items!");
        _burn(from, id, amount);
    }

     //May receive crypto... well who knows
    receive() external payable {}

    function uri(uint256 tokenId) public view virtual override returns (string memory) {
        return string(
            abi.encodePacked(
            string(abi.encodePacked("http://nft.myownsatoshi.com/data/bday/",Strings.toString(tokenId))),
            ".json")
            
            );
    }

    //Royalties Address
    function setRoyaltiesAddress(address payable rAddress) public onlyOwner {
        _royaltiesAddress=rAddress;
    }

    //Royalties fee
    function setRoyaltiesBasicPoints(uint96 rBasicPoints) public onlyOwner {
        _royaltiesBasicPoints=rBasicPoints;
    }

    //The SC is not desgined to receive funds but it's better to have this funtion... believe me
    function withdraw(uint amount) external {
        require(hasRole(WITHDRAW_ROLE, _msgSender()), "Exception: must have withdraw role to get crypto");
        payable(msg.sender).transfer(amount);
    }
    
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice ) external view returns ( address receiver, uint256 royaltyAmount) {
        if(exists(_tokenId))
            return(_royaltiesAddress, (_salePrice * _royaltiesBasicPoints)/10000);        
        return (_royaltiesAddress, (_salePrice * _royaltiesBasicPoints)/10000);        
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, AccessControlEnumerable) returns (bool) {
        if(interfaceId == _INTERFACE_ID_ERC2981) {
            return true;
        }
        return super.supportsInterface(interfaceId);
    }
}
