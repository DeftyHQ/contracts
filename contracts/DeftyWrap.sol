pragma solidity ^0.5.0;

import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';
import 'openzeppelin-solidity/contracts/drafts/Counter.sol';
import 'openzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol';
import 'openzeppelin-solidity/contracts/token/ERC721/IERC721Metadata.sol';
import { ISaiTub as SaiTub } from './lib/sai/ITub.sol';

contract DeftyWrap is Ownable, IERC721Metadata, ERC721Full {

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
    uint256 tokenId;
    address previousOwner;
    WrapState state;
  }

  address public cdpAddress;
  mapping(bytes32 => ProofOfOwnership) public proofRegistery;
  mapping(uint256 => bytes32) public tokenIdToCdpId;

  event Proved(address sender, bytes32 cdpId, WrapState state);
  event Wrapped(address sender, bytes32 cdpId, uint256 tokenId);
  event Unwrapped(address sender, bytes32 cdpId, uint256 tokenId);

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

  function proveOwnership(bytes32 _cdpId)
    public
  {
    SaiTub untrustedMkr = SaiTub(cdpAddress);
    require(untrustedMkr.lad(_cdpId) == msg.sender, 'The msg.sender is not the owner of the CDP');

    proofRegistery[_cdpId].cdpId = _cdpId;
    proofRegistery[_cdpId].previousOwner = msg.sender;
    proofRegistery[_cdpId].state = WrapState.PendingTransfer;
    emit Proved(msg.sender, _cdpId, proofRegistery[_cdpId].state);
  }

  function wrap(bytes32 _cdpId)
    public
    returns (uint256 _deftyTokenId)
  {
    SaiTub untrustedMkr = SaiTub(cdpAddress);
    require(proofRegistery[_cdpId].state != WrapState.Undefined, 'You must proveOwnership() of CDP before wrapping');
    require(proofRegistery[_cdpId].previousOwner == msg.sender, 'You must be the previousOwner in order to wrap a CDP');
    require(untrustedMkr.lad(_cdpId) == address(this), 'You must give() the CDP to this contract before calling wrap()');

     _deftyTokenId = tokenId.next();
    _mint(msg.sender, _deftyTokenId);

    proofRegistery[_cdpId].tokenId = _deftyTokenId;
    proofRegistery[_cdpId].state = WrapState.Wrapped;

    tokenIdToCdpId[_deftyTokenId] = _cdpId;
    emit Wrapped(msg.sender, _cdpId, _deftyTokenId);
  }

  function unwrap(uint256 _deftyTokenId)
    public
    returns (bool)
  {
    SaiTub untrustedMkr = SaiTub(cdpAddress);
    bytes32 _cdpId = tokenIdToCdpId[_deftyTokenId];

    require(msg.sender == ownerOf(_deftyTokenId), 'Only the DYT owner can unwrap the NFT');
    untrustedMkr.give(_cdpId, msg.sender); // When placed in a require get TypeError: No matching declaration found after argument-dependent lookup.

    _burn(_deftyTokenId);
    tokenIdToCdpId[_deftyTokenId];
    proofRegistery[_cdpId].state = WrapState.Unwrapped;

    emit Unwrapped(msg.sender, _cdpId, _deftyTokenId);
  }
}
