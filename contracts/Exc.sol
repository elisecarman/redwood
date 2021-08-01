pragma solidity 0.5.3;
pragma experimental ABIEncoderV2;

/// @notice these commented segments will differ based on where you're deploying these contracts. If you're deploying
/// on remix, feel free to uncomment the github imports, otherwise, use the uncommented imports

//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/solc-0.6/contracts/token/ERC20/IERC20.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/solc-0.6/contracts/math/SafeMath.sol";
import '../contracts/libraries/token/ERC20/ERC20.sol';
import '../contracts/libraries/math/SafeMath.sol';
import "./IExc.sol";

///what are sides? buy vs sell

///how to use ERC 20 token functions?


contract Exc is IExc{
    /// @notice simply notes that we are using SafeMath for uint, since Solidity's math is unsafe. For all the math
    /// you do, you must use the methods specified in SafeMath (found at the github link above), instead of Solidity's
    /// built-in operators.
    using SafeMath for uint;
    
    /// @notice these declarations are incomplete. You will still need a way to store 
    
    //the orderbook,
    //transition to heap if time heap?
    Order[] public sell_order_book;
    Order[] public buy_order_book;
    
    //the balances of the traders
    //trader => token => amount
    mapping(address => mapping(bytes32 => uint)) private balances;

    ///id ticker
    uint public id_ticker;
    
    //and the IDs of the next trades and orders. ///
    mapping(uint => Order) public orders;
    
    //Reference the NewTrade event and the IExc
    /// interface for more details about orders and sides.
    mapping(bytes32 => Token) public tokens;
    bytes32[] public tokenList;
    bytes32 constant PIN = bytes32('PIN');
    
    /// @notice an event representing all the needed info regarding a new trade on the exchange
    event NewTrade(
        uint tradeId, // --> documents exchange  ///when an order is fulfilled create trad and trade id
        uint orderId, //original order
        bytes32 indexed ticker,
        address indexed trader1,
        address indexed trader2,
        uint amount,
        uint price,
        uint date  //now
    );
    
    // todo: implement getOrders, which simply returns the orders for a specific token on a specific side
    function getOrders(
      bytes32 ticker, 
      Side side) 
      external 
      view
      returns(Order[] memory) {
          uint i;
          uint j;
        
        //memory vs storage: can modify storage
          if (side == IExc.Side.BUY){
             uint newSize = buy_order_book.length;
             Order[] memory order_list = new Order[](newSize);
         for (i = 0; i < buy_order_book.length; i++) {
             
         if (buy_order_book[i].ticker == ticker){
             order_list[j] = buy_order_book[i];
             j++;
         }
         }
          return order_list;
    }else if (side == IExc.Side.SELL){
        
        uint newSize = sell_order_book.length;
        Order[] memory order_list = new Order[](newSize);
        
      for (i = 0; i < sell_order_book.length; i++) {
         if (sell_order_book[i].ticker == ticker){
             //order_list.push(sell_order_book[i]);
             order_list[j] = sell_order_book[i];
             j++;
         }
         }
             return order_list;
    }
}

    // todo: implement getTokens, which simply returns an array of the tokens currently traded on in the exchange
    function getTokens() 
      external 
      view 
      returns(Token[] memory) {
         uint i;
        Token[] memory tok_list = new Token[](tokenList.length);
          for (i = 0; i < tokenList.length; i++) {
         tok_list[i]= tokens[tokenList[i]];
          }
          return tok_list;
    }
    
    // todo: implement addToken, which should add the token desired to the exchange by interacting with tokenList and tokens
    function addToken(
        bytes32 ticker,
        address tokenAddress)
        external {
       Token memory newToken = Token(ticker, tokenAddress);
       tokens[ticker] = newToken;
       tokenList.push(ticker);
    }
    
    // todo: implement deposit, which should deposit a certain amount of tokens from a trader to their on-exchange wallet,
    // based on the wallet data structure you create and the IERC20 interface methods. Namely, you should transfer
    // tokens from the account of the trader on that token to this smart contract, and credit them appropriately
    function deposit(
        uint amount,
        bytes32 ticker)
        external {
            //use ERC 20 functions
           
           
            IERC20(tokens[ticker].tokenAddress).transferFrom(msg.sender, address(this), amount); 
            ///how to find address of exchange?
            
            balances[msg.sender][ticker] += amount; 
            
    }
    
    // todo: implement withdraw, which should do the opposite of deposit. The trader should not be able to withdraw more than
    // they have in the exchange.
    function withdraw(
        uint amount,
        bytes32 ticker)
        external {  
            if (IERC20(tokens[ticker].tokenAddress).appove(address(this), amount)){
            //IERC20.transferFrom(address(self), msg.sender, amount);
}
            balances[msg.sender][ticker] -= amount;
    }
    
    // todo: implement makeLimitOrder, which creates a limit order based on the parameters provided. This method should only be
    // used when the token desired exists and is not pine. This method should not execute if the trader's token or pine balances
    // are too low, depending on side. This order should be saved in the orderBook
    
    // todo: implement a sorting algorithm for limit orders, based on best prices for market orders having the highest priority.
    // i.e., a limit buy order with a high price should have a higher priority in the orderbook.
    
    ///should make LimitOrder involve placing it in the orderbook?
    
    //Can we return an id?
    function makeLimitOrder(
        bytes32 ticker,
        uint amount,
        uint price,
        Side side)
        external {
        Order memory newOrder = Order(id_ticker, msg.sender,side, ticker, amount, 0, price, now );
        id_ticker ++;
        uint i;
        if (side == IExc.Side.BUY){
            for (i = 0; i < buy_order_book.length; i++){
               if (buy_order_book[i].price > price) {
                  // buy_order_book.push(newOrder, i);
               } 
            }
        }
            
    }
    
    // todo: implement deleteLimitOrder, which will delete a limit order from the orderBook as long as the same trader is deleting
    // it.
        function deleteLimitOrder(
        uint id,
        bytes32 ticker,
        Side side) external returns (bool) {
            Order memory o = orders[id];
            // if (o == Order(0)){
            //     return;
            // }
            //retreive order from structure
            //compare address of sender and stored address
            if (msg.sender == o.trader ){
                //orders[id] = 0;
                
                ///delete from order book
            }
    }
    
    // todo: implement makeMarketOrder, which will execute a market order on the current orderbook. The market order need not be
    // added to the book explicitly, since it should execute against a limit order immediately. Make sure you are getting rid of
    // completely filled limit orders!
    function makeMarketOrder(
        bytes32 ticker,
        uint amount,
        Side side)
        external {
       
    }
    
    function getNextID() external returns (uint){
        return id_ticker;
    }
    
    //todo: add modifiers for methods as detailed in handout

}