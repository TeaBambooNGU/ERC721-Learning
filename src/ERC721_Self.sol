// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/interfaces/IERC721.sol";
import "openzeppelin-contracts/contracts/interfaces/IERC721Metadata.sol";
import "openzeppelin-contracts/contracts/interfaces/IERC721Receiver.sol";
import "openzeppelin-contracts/contracts/interfaces/IERC165.sol";
import "openzeppelin-contracts/contracts/utils/Address.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";

abstract contract ERC721 is IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    string public override name;
    string public override symbol;
    // tokenId => owner的address
    mapping (uint => address) private _owners;
    // owner => 币的持有数量
    mapping (address => uint) private _balances;
    // tokenID => 授权地址
    mapping (uint => address) _tokenApprovals;
    // owner地址 => 授权者地址 => 是否授权
    mapping (address => mapping (address => bool)) private _operatorApprovals;
    
    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }
    // 实现IERC165接口supportsInterface 表明该合约支持的接口
    function supportsInterface(bytes4 interfaceId) external pure override returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId;
    }

    function balanceOf(address owner) external view override returns (uint) {
        require(owner != address(0), "owner = zero address");
        return _balances[owner];
    }

    function ownerOf(uint tokenId) public view override returns (address owner) {
        owner = _owners[tokenId];
        require(owner != address(0),"token doesn't exist");
    }

    function isApprovedForAll(address owner, address operator) external view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function setApprovalForAll(address operator, bool approved) external override {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }
    // 得到tokenId的授权地址
    function getApproved(uint tokenId) external view override returns (address) {
        require(_owners[tokenId] != address(0), "token doesn't exist");
        return _tokenApprovals[tokenId];
    }
    // 业务逻辑函数 私有 不暴露
    function _approve(address owner, address to, uint tokenId) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }
    // 实现IERC721的approve，将tokenId授权给 to 地址
    function approve(address to, uint tokenId) external override {
        address owner = _owners[tokenId];
        require (
            owner == msg.sender || _operatorApprovals[owner][msg.sender],
            "not owner nor approved for all"
        );
        _approve(owner,to,tokenId);
    }
    // 查询 spender地址是否可以使用tokenId（他是owner或被授权地址）。
    function _isApproveOrOwner(address owner, address spender, uint tokenId) private view returns (bool) {
        return (spender == owner || _tokenApprovals[tokenId] == spender || _operatorApprovals[owner][spender]);
    }
    
    function _transfer(address owner, address from, address to, uint tokenId) private {
        require(from == owner, "not owner");
        require(to != address(0), "transfer to the zero address");
        // 转账的时候需要清空这个货币之前的授权 因为货币的所有人的马上要变化了 之前的授权应该无效化
        _approve(owner,address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function transferFrom(address from, address to, uint tokenId) external override {
        address owner = _owners[tokenId];
        require(_isApproveOrOwner(owner,msg.sender,tokenId),"not owner nor approved");
        _transfer(owner,from,to,tokenId);
    }
    // isContract 当合约在构造期会被错误识别为 非合约 导致绕过检测 已废弃 @Link https://despac1to.medium.com/carefully-use-openzeppelins-address-iscontract-msg-sender-4136cc6ff66d
    function _checkOnERC721Received(address from, address to, uint tokenId, bytes memory _data) private returns (bool) {
        if(to.code.length > 0){
            return
                IERC721Receiver(to).onERC721Received(
                    msg.sender, from, tokenId, _data
                ) == IERC721Receiver.onERC721Received.selector;
        }else {
            return true;
        }

    }
    /**
     * 安全转账，安全地将 tokenId 代币从 from 转移到 to，会检查合约接收者是否了解 ERC721 协议，以防止代币被永久锁定
     * @param owner 代币所有人
     * @param from  不能是0地址
     * @param to    不能是0地址 （如果 to 是智能合约, 他必须支持 IERC721Receiver-onERC721Received）
     * @param tokenId 代币Id （代币必须存在，并且被 from拥有）
     * @param _data 参数
     */
    function _safeTransfer(address owner, address from, address to, uint tokenId, bytes memory _data) private {
        _transfer(owner,from,to,tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data),"not ERC721Receiver");
    }

    function safeTransferFrom(address from, address to, uint tokenId, bytes memory _data) public override {
        address owner = ownerOf(tokenId);
        require(_isApproveOrOwner(owner, msg.sender, tokenId),"not owner nor approved");
        _safeTransfer(owner, from, to, tokenId, _data);
    }

    function safeTransferFrom(address from, address to, uint tokenId) public {
        address owner = ownerOf(tokenId);
        require(_isApproveOrOwner(owner, msg.sender, tokenId),"not owner nor approved");
        _safeTransfer(owner, from, to, tokenId, "");
    }
    /**
     * 铸币函数
     * @param to 铸造给谁
     * @param tokenId 代币ID 需要没有存在过的ID
     */
    function _mint(address to, uint tokenId) internal virtual {
        require(to != address(0), "mint to zero address");
        require(_owners[tokenId] == address(0),"token already minted");

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint tokenId) internal virtual {
        address owner = ownerOf(tokenId);
        require(msg.sender == owner, "not owner of token");

        _approve(owner,address(0),tokenId);

        _balances[owner] -=1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }
    /**
     * 计算{tokenURI}的BaseURI，tokenURI就是把baseURI和tokenId拼接在一起，需要开发重写。
     * BAYC的baseURI为ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/
     */
    function _baseURI() internal view virtual returns (string memory){
        return "";
    }

    function tokenURI(uint tokenId) public view virtual override returns (string memory){
        require(_owners[tokenId] != address(0)," Token not Exist");
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI,tokenId.toString())) : "";
    }


}