pragma solidity ^0.5.0;

import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';
import 'openzeppelin-solidity/contracts/drafts/Counter.sol';
import 'openzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol';
import { ISaiTub as SaiTub } from './lib/sai/ITub.sol';

contract DeftyWrap is Ownable, ERC721Full {

  using Counter for Counter.Counter;
  Counter.Counter private tokenCounter;

  enum WrapState {
    Undefined,
    Proved,
    Wrapped,
    Unwrapped
  }

  struct ProofOfOwnership {
    bytes32 cup;
    uint256 nft;
    address lad;
    WrapState state;
  }

  address public tubAddress;
  mapping(bytes32 => ProofOfOwnership) public proofRegistery;
  mapping(uint256 => bytes32) public cdpRegistry;

  event Proved(address sender, bytes32 cup, WrapState state);
  event Wrapped(address sender, bytes32 cup, uint256 token);
  event Unwrapped(address sender, bytes32 cup, uint256 token);

  constructor(address tubAddress_)
    Ownable()
    ERC721Full('DeftyToken', 'DTY')
    public
  {
    setTubAddress(tubAddress_);
  }

  function setTubAddress(address tubAddress_) public {
    require(msg.sender == owner(), 'Unauthorised');
    tubAddress = tubAddress_;
  }

  function getCupId(uint256 token) public view returns (bytes32) {
    return cdpRegistry[token];
  }

  function gettoken(bytes32 cup) public view returns (uint256) {
    return proofRegistery[cup].nft;
  }

  function getStatus(bytes32 cup) public view returns (WrapState) {
    return proofRegistery[cup].state;
  }

  function proveOwnership(bytes32 cup)
    public
  {
    SaiTub untrustedMkr = SaiTub(tubAddress);
    require(untrustedMkr.lad(cup) == msg.sender, 'The msg.sender is not the owner of the CDP');

    proofRegistery[cup].cup = cup;
    proofRegistery[cup].lad = msg.sender;
    proofRegistery[cup].state = WrapState.Proved;
    emit Proved(msg.sender, cup, proofRegistery[cup].state);
  }

  function wrap(bytes32 cup)
    public
    returns (uint256 nft)
  {
    SaiTub untrustedMkr = SaiTub(tubAddress);
    require(proofRegistery[cup].state != WrapState.Undefined, 'You must proveOwnership() of CDP before wrapping');
    require(proofRegistery[cup].lad == msg.sender, 'You must be the lad in order to wrap a CDP');
    require(untrustedMkr.lad(cup) == address(this), 'You must give() the CDP to this contract before calling wrap()');

     nft = tokenCounter.next();
    _mint(msg.sender, nft);

    proofRegistery[cup].nft = nft;
    proofRegistery[cup].state = WrapState.Wrapped;

    cdpRegistry[nft] = cup;
    emit Wrapped(msg.sender, cup, nft);
  }

  function unwrap(uint256 nft)
    public
    returns (bool)
  {
    SaiTub untrustedMkr = SaiTub(tubAddress);
    bytes32 cup = cdpRegistry[nft];

    require(msg.sender == ownerOf(nft), 'Only the DYT owner can unwrap the NFT');
    untrustedMkr.give(cup, msg.sender); // When placed in a require get TypeError: No matching declaration found after argument-dependent lookup.

    _burn(nft);
    cdpRegistry[nft];
    proofRegistery[cup].state = WrapState.Unwrapped;

    emit Unwrapped(msg.sender, cup, nft);
  }
}
