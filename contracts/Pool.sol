pragma solidity 0.5.3;

import './Exc.sol';
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/solc-0.6/contracts/math/SafeMath.sol";
import '../contracts/libraries/math/SafeMath.sol';

contract Pool {
    
    /// @notice some parameters for the pool to function correctly, feel free to add more as needed
    address private tokenP;
    address private token1;
    address private dex;
    bytes32 private tokenPT;
    bytes32 private token1T;
    
    uint private amountTokenP;
    uint private amountToken1;
    uint private price;
    uint private idSell;
    uint private idBuy;
    
    ///this maps a user address to an int: amount of Token1 
    mapping(address => uint) walletP;
    mapping(address => uint) wallet1;
    
    // todo: create wallet data structures
    ///keeps track of the balances that traders have put into the pool.
    
    //questions: how much should limit orders output?
    
    ///deposit method
    //do we check sender has enough to deposit?
    ///should I call and ERC 20 method?
      function deposit(
        uint amount,
        bytes32 ticker)
        external {
            if (ticker == tokenPT){
                walletP[msg.sender] += amount;
                amountTokenP += amount;
            } else if (ticker == token1T){
                wallet1[msg.sender] += amount;
                amountToken1 += amount;
            }
            
          updateOrders(amount);
            
    }
    
    ///withdraw method
    // todo: implement withdraw, which should do the opposite of deposit. The trader should not be able to withdraw more than
    // they have in the exchange.
    function withdraw(
        uint amount,
        bytes32 ticker)
        external {
            if (ticker == tokenPT){
                if (walletP[msg.sender] >= amount){
                    walletP[msg.sender] += amount;
                    amountTokenP -= amount;
                }
            } else if (ticker == token1T){
                if (wallet1[msg.sender] >= amount){
                    wallet1[msg.sender] += amount;
                    amountToken1 -= amount;
                }
            }
            
            updateOrders(amount);
    }
    
    ///calculate price method
    
    function newPrice() private returns (uint) {
        uint new_price = SafeMath.div(amountTokenP, amountToken1);
        price = new_price;
    }
    
    function updateOrders(uint amount) private {
        
         newPrice();
            
            IExc(dex).deleteLimitOrder(
                idSell,
                token1T,
                IExc.Side.SELL);
                
            IExc(dex).deleteLimitOrder(
                idBuy,
                token1T,
                IExc.Side.BUY);
        
        idBuy = IExc.getNextID();
        
            IExc(dex).makeLimitOrder(
                token1T,
                amount,  //what amount??
                newPrice(),
                idBuy);
                
        idSell = IExc.getNextID;        
            IExc(dex).makeLimitOrder(
                token1T,
                amount,    //what amount??
                newPrice(),
                idSell);
        
    }
    
    ///make and send limit order?
    

    // todo: fill in the initialize method, which should simply set the parameters of the contract correctly. To be called once
    // upon deployment by the factory.
    function initialize(address _token0, address _token1, address _dex, uint whichP, bytes32 _tickerQ, bytes32 _tickerT)
    external {
        
        
        tokenPT = _tickerQ;
        token1T = _tickerT;
        dex = _dex;
        if (whichP == 1) {
           tokenP = _token0;
           token1 = _token1;
        } else {
            tokenP = _token1;
            token1 = _token0;
        }
    }
    
    // Just like the checks for the quote token in factory, your check to ensure that initialize is 
    // actually deployed by the factory can be super simple, because we don’t actually know where 
    // factory is deployed, unlike the mainnet!
    
    //do same checks as Factory? or check that initialize from Factory? and how so?
    
    //what is dex?
    
    
    
    // todo: implement wallet functionality and trading functionality

    function testing(uint testMe) public view returns (uint) {
        if (testMe == 1) {
            return 5;
        } else {
            return 3;
        }
    }
}