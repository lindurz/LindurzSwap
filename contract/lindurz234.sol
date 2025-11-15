// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title LINDURZ Token Contract
 * @dev Token LINDURZ (LDRZ) yang sederhana, aman, dan transparan
 * Symbol: LDRZ
 * Decimal: 18
 * Max Supply: 234,000 LDRZ
 * Circulating Supply: 1,000 LDRZ
 * Max per Minting: 1,000 LDRZ
 * Tidak ada burn, blacklist, whitelist, fee changes, anti-whale
 */
contract LINDURZ is ERC20, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    
    uint256 public constant MAX_SUPPLY = 234000 * 10**18; // 234,000 LDRZ
    uint256 public constant MAX_PER_MINT = 1000 * 10**18; // 1,000 LDRZ per mint
    uint256 public constant INITIAL_CIRCULATING_SUPPLY = 1000 * 10**18; // 1,000 LDRZ
    
    // Event untuk transparansi
    event TokensMinted(address indexed to, uint256 amount);
    event NativeReceived(address indexed from, uint256 amount);
    event ERC20Recovered(address indexed token, address indexed to, uint256 amount);
    
    /**
     * @dev Constructor contract LINDURZ
     */
    constructor() 
        ERC20("LINDURZ", "LDRZ") 
        Ownable(msg.sender)
    {
        // Mint initial circulating supply ke deployer
        _mint(msg.sender, INITIAL_CIRCULATING_SUPPLY);
        emit TokensMinted(msg.sender, INITIAL_CIRCULATING_SUPPLY);
    }
    
    /**
     * @dev Fungsi untuk mint token tambahan (hanya owner)
     * @param to Address penerima token
     * @param amount Jumlah token yang akan di-mint
     */
    function mint(address to, uint256 amount) 
        external 
        onlyOwner 
        nonReentrant 
    {
        require(amount > 0, "LINDURZ: Amount must be greater than 0");
        require(amount <= MAX_PER_MINT, "LINDURZ: Exceeds max per mint");
        require(totalSupply() + amount <= MAX_SUPPLY, "LINDURZ: Exceeds max supply");
        
        _mint(to, amount);
        emit TokensMinted(to, amount);
    }
    
    /**
     * @dev Fungsi untuk menerima ETH native
     */
    receive() external payable {
        emit NativeReceived(msg.sender, msg.value);
    }
    
    /**
     * @dev Fallback function untuk menerima ETH
     */
    fallback() external payable {
        emit NativeReceived(msg.sender, msg.value);
    }
    
    /**
     * @dev Kirim ETH native dari contract (hanya owner)
     * @param to Address penerima
     * @param amount Jumlah ETH yang dikirim
     */
    function sendNative(address payable to, uint256 amount) 
        external 
        onlyOwner 
        nonReentrant 
    {
        require(amount <= address(this).balance, "LINDURZ: Insufficient balance");
        require(to != address(0), "LINDURZ: Invalid recipient");
        
        (bool success, ) = to.call{value: amount}("");
        require(success, "LINDURZ: Native transfer failed");
    }
    
    /**
     * @dev Kirim semua ETH native dari contract (hanya owner)
     * @param to Address penerima
     */
    function sendAllNative(address payable to) 
        external 
        onlyOwner 
        nonReentrant 
    {
        uint256 balance = address(this).balance;
        require(balance > 0, "LINDURZ: No native balance");
        require(to != address(0), "LINDURZ: Invalid recipient");
        
        (bool success, ) = to.call{value: balance}("");
        require(success, "LINDURZ: Native transfer failed");
    }
    
    /**
     * @dev Kirim token ERC20 dari contract (hanya owner)
     * @param tokenAddress Alamat token ERC20
     * @param to Address penerima
     * @param amount Jumlah token yang dikirim
     */
    function sendERC20(
        address tokenAddress, 
        address to, 
        uint256 amount
    ) 
        external 
        onlyOwner 
        nonReentrant 
    {
        require(tokenAddress != address(0), "LINDURZ: Invalid token address");
        require(to != address(0), "LINDURZ: Invalid recipient");
        require(amount > 0, "LINDURZ: Amount must be greater than 0");
        
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(amount <= balance, "LINDURZ: Insufficient token balance");
        
        token.safeTransfer(to, amount);
        emit ERC20Recovered(tokenAddress, to, amount);
    }
    
    /**
     * @dev Kirim semua token ERC20 dari contract (hanya owner)
     * @param tokenAddress Alamat token ERC20
     * @param to Address penerima
     */
    function sendAllERC20(
        address tokenAddress, 
        address to
    ) 
        external 
        onlyOwner 
        nonReentrant 
    {
        require(tokenAddress != address(0), "LINDURZ: Invalid token address");
        require(to != address(0), "LINDURZ: Invalid recipient");
        
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "LINDURZ: No token balance");
        
        token.safeTransfer(to, balance);
        emit ERC20Recovered(tokenAddress, to, balance);
    }
    
    /**
     * @dev Standard transfer function dengan ReentrancyGuard
     */
    function transfer(address to, uint256 amount) 
        public 
        override 
        nonReentrant 
        returns (bool) 
    {
        return super.transfer(to, amount);
    }
    
    /**
     * @dev Standard transferFrom function dengan ReentrancyGuard
     */
    function transferFrom(address from, address to, uint256 amount) 
        public 
        override 
        nonReentrant 
        returns (bool) 
    {
        return super.transferFrom(from, to, amount);
    }
    
    /**
     * @dev Standard approve function dengan ReentrancyGuard
     */
    function approve(address spender, uint256 amount) 
        public 
        override 
        nonReentrant 
        returns (bool) 
    {
        return super.approve(spender, amount);
    }
    
    /**
     * @dev Fungsi untuk mendapatkan informasi token
     */
    function getTokenInfo() external pure returns (
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 maxSupply,
        uint256 maxPerMint
    ) {
        return (
            "LINDURZ",
            "LDRZ",
            18,
            MAX_SUPPLY,
            MAX_PER_MINT
        );
    }
    
    /**
     * @dev Fungsi untuk mengecek remaining supply yang bisa di-mint
     */
    function getRemainingMintableSupply() external view returns (uint256) {
        return MAX_SUPPLY - totalSupply();
    }
    
    /**
     * @dev Fungsi untuk melihat balance ETH native di contract
     */
    function getNativeBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    /**
     * @dev Fungsi untuk melihat balance ERC20 di contract
     */
    function getERC20Balance(address tokenAddress) external view returns (uint256) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }
}