cat > contracts/PancakeSwapPool.sol << 'EOF'
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract PancakeSwapPool is Ownable {
    
    IERC20 public tokenA;  // استیبل کوین
    IERC20 public tokenB;  // توکن دیگر (مثلاً BUSD)
    
    struct LiquidityProvider {
        uint256 amountA;
        uint256 amountB;
        uint256 shares;
    }
    
    mapping(address => LiquidityProvider) public providers;
    uint256 public totalShares;
    
    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB, uint256 shares);
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB, uint256 shares);
    event Swapped(address indexed user, address indexed fromToken, uint256 amountIn, uint256 amountOut);
    
    constructor(address _tokenA, address _tokenB) Ownable(msg.sender) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }
    
    // اضافه کردن نقدینگی
    function addLiquidity(uint256 amountA, uint256 amountB) external {
        require(amountA > 0 && amountB > 0, "Amounts must be greater than 0");
        
        // انتقال توکن‌ها از کاربر به قرارداد
        require(tokenA.transferFrom(msg.sender, address(this), amountA), "Transfer A failed");
        require(tokenB.transferFrom(msg.sender, address(this), amountB), "Transfer B failed");
        
        // محاسبه سهام
        uint256 shares;
        if (totalShares == 0) {
            shares = sqrt(amountA * amountB);
        } else {
            shares = (amountA * totalShares) / tokenA.balanceOf(address(this));
        }
        
        providers[msg.sender].amountA += amountA;
        providers[msg.sender].amountB += amountB;
        providers[msg.sender].shares += shares;
        totalShares += shares;
        
        emit LiquidityAdded(msg.sender, amountA, amountB, shares);
    }
    
    // حذف نقدینگی
    function removeLiquidity(uint256 shares) external {
        require(shares > 0, "Shares must be greater than 0");
        require(providers[msg.sender].shares >= shares, "Insufficient shares");
        
        uint256 amountA = (shares * tokenA.balanceOf(address(this))) / totalShares;
        uint256 amountB = (shares * tokenB.balanceOf(address(this))) / totalShares;
        
        // انتقال توکن‌ها به کاربر
        require(tokenA.transfer(msg.sender, amountA), "Transfer A failed");
        require(tokenB.transfer(msg.sender, amountB), "Transfer B failed");
        
        providers[msg.sender].shares -= shares;
        totalShares -= shares;
        
        emit LiquidityRemoved(msg.sender, amountA, amountB, shares);
    }
    
    // تابع swap
    function swap(address fromToken, uint256 amountIn) external returns (uint256) {
        require(amountIn > 0, "Amount must be greater than 0");
        
        IERC20 tokenIn = (fromToken == address(tokenA)) ? tokenA : tokenB;
        IERC20 tokenOut = (fromToken == address(tokenA)) ? tokenB : tokenA;
        
        // انتقال توکن ورودی
        require(tokenIn.transferFrom(msg.sender, address(this), amountIn), "Transfer failed");
        
        // محاسبه مقدار خروجی
        uint256 reserveIn = tokenIn.balanceOf(address(this));
        uint256 reserveOut = tokenOut.balanceOf(address(this));
        
        uint256 amountOut = (amountIn * reserveOut) / (reserveIn + amountIn);
        
        // انتقال توکن خروجی
        require(tokenOut.transfer(msg.sender, amountOut), "Transfer out failed");
        
        emit Swapped(msg.sender, fromToken, amountIn, amountOut);
        return amountOut;
    }
    
    // تابع کمکی برای محاسبه جذر
    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
    
    // مشاهده موجودی استخر
    function getPoolBalance() external view returns (uint256 balanceA, uint256 balanceB) {
        balanceA = tokenA.balanceOf(address(this));
        balanceB = tokenB.balanceOf(address(this));
    }
    
    // مشاهده اطلاعات نقدینگی دهنده
    function getProviderInfo(address provider) external view returns (uint256 amountA, uint256 amountB, uint256 shares) {
        amountA = providers[provider].amountA;
        amountB = providers[provider].amountB;
        shares = providers[provider].shares;
    }
}
EOF
