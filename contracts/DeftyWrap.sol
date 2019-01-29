pragma solidity ^0.5.0;

import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';
import 'openzeppelin-solidity/contracts/drafts/Counter.sol';
import 'openzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol';
import 'openzeppelin-solidity/contracts/token/ERC721/IERC721Metadata.sol';
import 'openzeppelin-solidity/contracts/token/ERC721/ERC721MetadataMintable.sol';
import './IMakerCDP.sol';
import './UtilsLib.sol';

contract DeftyWrap is Ownable, IERC721Metadata, ERC721Full, ERC721MetadataMintable {

  using Counter for Counter.Counter;
  Counter.Counter private tokenId;

  enum WrapState {
    Undefined,
    PendingTransfer,
    Wrapped,
    Unwrapped
  }

  struct ProofOfOwnership {
    bytes32 cdpId;
    address previousOwner;
    WrapState state;
  }

  address public cdpAddress;
  bytes32 public cupId;
  address public cupLad;
  address public sender;

  mapping(bytes32 => ProofOfOwnership) public proofRegistery;

  event Wrap(address sender, bytes32 cdpId, address myself);

  constructor(address _cdpAddress)
    Ownable()
    ERC721Full('DeftyToken', 'DTY')
    public
  {
    setCdpAddress(_cdpAddress);
  }


  function setCdpAddress(address _cdpAddress) public {
    require(msg.sender == owner(), 'Unauthorised');
    cdpAddress = _cdpAddress;
  }

  function getCdpAddress() view external returns (address) {
    return cdpAddress;
  }

  /*
    - Receive an existing cdpId
    - If msg.sender is the current 'lad' we create a temporary NFT.
      associate it to the cdpId and set it's state to inactive
    - Set the owner of the tempNFT to msg.sender
    The next step for the user would be to .give() the cdp to this contract.
  */
  function proveOwnership(bytes32 _cdpId)
    public
  {

    MakerCDP untrustedMkr = MakerCDP(cdpAddress);
    cupId = _cdpId;
    cupLad = untrustedMkr.lad(_cdpId);
    sender = msg.sender;
    require(cupLad == msg.sender, 'The msg.sender is not the owner of the CDP');

    proofRegistery[_cdpId].cdpId = _cdpId;
    proofRegistery[_cdpId].previousOwner = msg.sender;
    proofRegistery[_cdpId].state = WrapState.PendingTransfer;
  }

  /*
    - We check that the contract is the owner of the cdp
    - And that the sender is the owner of the tempNFT
    - create a real NFT from the temp NFT
    - destroy the temp NFT
  */
  function wrap(bytes32 _cdpId)
    public
    returns (uint256 _deftyTokenId)
  {
    MakerCDP untrustedMkr = MakerCDP(cdpAddress);
    require(proofRegistery[_cdpId].state != WrapState.Undefined, 'Please proveOwnership() of CDP before wrapping');
    require(proofRegistery[_cdpId].previousOwner == msg.sender, 'You must be the preivousOwner of the CDP to create an DYT');
    require(untrustedMkr.lad(_cdpId) == address(this), 'Transfer ownership to this contract before wrapping');

     _deftyTokenId = tokenId.next();
    mintWithTokenURI(msg.sender, _deftyTokenId, UtilsLib._bytes32ToStr(_cdpId));

    proofRegistery[_cdpId].state = WrapState.Wrapped;
  }

  /*
    Since we are the owner, unwrapping is easy.
    - Check that msg.sender is NFT owner
    - get the associated cdpId
    - give() cdp to sender
    - burn NFT.
  */
  function unwrap(uint256 _deftyTokenId)
    public
    returns (bool)
  {
    require(msg.sender == ownerOf(_deftyTokenId), 'Only the DYT owner can unwrap the NFT');

    string memory _cdpString = this.tokenURI(_deftyTokenId);
    bytes32 _cdpId = UtilsLib._stringToBytes32(_cdpString);

    MakerCDP untrustedMkr = MakerCDP(cdpAddress);
    untrustedMkr.give(_cdpId, msg.sender); // should require success of call ?

    _burn(_deftyTokenId);
    proofRegistery[_cdpId].state = WrapState.Unwrapped;
  }
}
