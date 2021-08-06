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
    uint private idSell = 0;
    uint private idBuy = 0;
    
    // todo: create wallet data structures
    mapping(address => uint) public walletP;
    mapping(address => uint) public wallet1;
    
   
    

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
        
        idSell = 0;
        idBuy = 0;
    }
    
    // todo: implement wallet functionality and trading functionality

    // todo: implement withdraw and deposit functions so that a single deposit and a single withdraw can unstake
    // both tokens at the same time
    function deposit(uint tokenAmount, uint pineAmount) 
    //payable
    external {
    
      
    IERC20(tokenP).transferFrom(msg.sender, address(this), pineAmount);
    IERC20(token1).transferFrom(msg.sender, address(this), tokenAmount);
       
        walletP[msg.sender] = SafeMath.add(walletP[msg.sender], pineAmount);
        amountTokenP = SafeMath.add(amountTokenP, pineAmount);
       
        wallet1[msg.sender] = SafeMath.add(wallet1[msg.sender], tokenAmount);
        amountToken1 = SafeMath.add(wallet1[msg.sender], tokenAmount);
        
        
        IERC20(token1).approve(address(this), tokenAmount); //dex
        IERC20(tokenP).approve(address(this), pineAmount); //dex
        
       IExc(dex).deposit(tokenAmount, token1T);
       IExc(dex).deposit(pineAmount, tokenPT);
        
        
        updateOrders(amountToken1);

   }

    function withdraw(uint tokenAmount, uint pineAmount) 
    //payable
    external {
     
    require(walletP[msg.sender] >= pineAmount);
    require(wallet1[msg.sender] >= tokenAmount);
        
    walletP[msg.sender] = SafeMath.sub(walletP[msg.sender], pineAmount);   
        
        IExc(dex).withdraw(tokenAmount, token1T);
        IExc(dex).withdraw(pineAmount, tokenPT);
        
                IERC20(tokenP).transfer(msg.sender, pineAmount);
                IERC20(token1).transfer(msg.sender, tokenAmount);
                
        // IERC20(token1).approve(msg.sender, tokenAmount);
        // IERC20(tokenP).approve(msg.sender, pineAmount);
        
       
                
        amountTokenP = SafeMath.sub(walletP[msg.sender], pineAmount);
        wallet1[msg.sender] = SafeMath.sub(wallet1[msg.sender], tokenAmount);
        amountToken1= SafeMath.sub(wallet1[msg.sender], tokenAmount);
            
            
       updateOrders(amountToken1);
           // }
        
            
    }
    
    
     function newPrice() private returns (uint) {
        uint new_price = SafeMath.div(amountTokenP, amountToken1);
        price = new_price;
    }
    
    function updateOrders(uint amount) private {
        
         newPrice();
         
         if (idBuy != 0 && idSell != 0 ){
            
            IExc(dex).deleteLimitOrder(
                idSell,
                token1T,
                IExc.Side.SELL);
                
            IExc(dex).deleteLimitOrder(
                idBuy,
                token1T,
                IExc.Side.BUY); 
         }
        
        idBuy = uint256(IExc(dex).getNextID());
        
            IExc(dex).makeLimitOrder(
                token1T,
                amount,  
                newPrice(),
                IExc.Side.BUY);
                
        idSell = uint256(IExc(dex).getNextID()); 
        
            IExc(dex).makeLimitOrder(
                token1T,
                amount,    
                newPrice(),
                IExc.Side.SELL);
        
    }

    function testing(uint testMe) public view returns (uint) {
        if (testMe == 1) {
            return 5;
        } else {
            return 3;
        }
    }
    

}