pragma solidity 0.5.3;
pragma experimental ABIEncoderV2;

/// @notice these commented segments will differ based on where you're deploying these contracts. If you're deploying
/// on remix, feel free to uncomment the github imports, otherwise, use the uncommented imports

// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/solc-0.6/contracts/token/ERC20/IERC20.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/solc-0.6/contracts/math/SafeMath.sol";
import '../contracts/libraries/token/ERC20/ERC20.sol';
import '../contracts/libraries/math/SafeMath.sol';
import "./IExc.sol";
import "./Heap.sol";

contract Exc is IExc{
    /// @notice simply notes that we are using SafeMath for uint, since Solidity's math is unsafe. For all the math
    /// you do, you must use the methods specified in SafeMath (found at the github link above), instead of Solidity's
    /// built-in operators.
    using SafeMath for uint;
    using Heap for Heap.Data;
    
    /// @notice these declarations are incomplete. You will still need a way to store the orderbook, the balances
    /// of the traders, and the IDs of the next trades and orders. Reference the NewTrade event and the IExc
    /// interface for more details about orders and sides.
    
    mapping(bytes32 => Heap.Data) public allSellBooks;

    mapping(bytes32 => Heap.Data) public allBuyBooks;
    
    mapping(bytes32 => Token) public tokens;
    bytes32[] public tokenList;
    mapping(bytes32 => bool) public contains_token;
    bytes32 constant PIN = bytes32('PIN');
    

    /// @notice, this is the more standardized form of the main wallet data structure, if you're using something a bit
    /// different, implementing a function that just takes in the address of the trader and then the ticker of a
    /// token instead would suffice
    mapping(address => mapping(bytes32 => uint)) public traderBalances;
    
    uint public id_ticker;
    uint public trade_ticker;
    uint public market_order_ticker;
    
    
    mapping(uint => Order) public orders;
    uint[] public allOrders;
     
    
    /// @notice an event representing all the needed info regarding a new trade on the exchange
    event NewTrade(
        uint tradeId,
        uint orderId,
        bytes32 indexed ticker,
        address indexed trader1,
        address indexed trader2,
        uint amount,
        uint price,
        uint date
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
        Order[] memory order_list = new Order[](allOrders.length);
        
        for (i = 0; i < allOrders.length; i++) {  
        if (allOrders[i] != 0){
            order_list[j] = orders[allOrders[i]];
            j++;
        }
        i++;
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
        if (!contains_token[ticker]){
            Token memory newToken = Token(ticker, tokenAddress);
        tokens[ticker] = newToken;
        tokenList.length++;
        tokenList.push(ticker);
        contains_token[ticker] = true;
        }
    }
    
    // todo: implement deposit, which should deposit a certain amount of tokens from a trader to their on-exchange wallet,
    // based on the wallet data structure you create and the IERC20 interface methods. Namely, you should transfer
    // tokens from the account of the trader on that token to this smart contract, and credit them appropriately
    function deposit(
        uint amount,
        bytes32 ticker)
        external {
            IERC20(tokens[ticker].tokenAddress).transferFrom(msg.sender, address(this), amount); 
            ///how to find address of exchange?
            
            traderBalances[msg.sender][ticker] += amount; 
    }
    
    // todo: implement withdraw, which should do the opposite of deposit. The trader should not be able to withdraw more than
    // they have in the exchange.
    function withdraw(
        uint amount,
        bytes32 ticker)
        external {
                        if (traderBalances[msg.sender][ticker] >= amount){
            if (IERC20(tokens[ticker].tokenAddress).approve(address(this), amount)){
            IERC20(tokens[ticker].tokenAddress).transfer(msg.sender, amount);
            }
            traderBalances[msg.sender][ticker] -= amount;
            }
    }
    
    // todo: implement makeLimitOrder, which creates a limit order based on the parameters provided. This method should only be
    // used when the token desired exists and is not pine. This method should not execute if the trader's token or pine balances
    // are too low, depending on side. This order should be saved in the orderBook
    
    // todo: implement a sorting algorithm for limit orders, based on best prices for market orders having the highest priority.
    // i.e., a limit buy order with a high price should have a higher priority in the orderbook.
    function makeLimitOrder(
        bytes32 ticker,
        uint amount,
        uint price,
        Side side)
        external {
            
        require(ticker != PIN && contains_token[ticker] && traderBalances[msg.sender][ticker] >= amount);    
            
        uint order_id = id_ticker;
        Order memory newOrder = Order(order_id, msg.sender,side, ticker, amount, 0, price, now );
        id_ticker ++;
        uint i;
        
        if (side == IExc.Side.SELL){
            ///negative input price for a Min priority heap
       allSellBooks[ticker].insert(-(price), id_ticker);
       
        } else if (side == IExc.Side.BUY){
        allBuyBooks[ticker].insert(price, order_id);
        }
        
        orders[order_id] = newOrder; 
        allOrders.length++;
        allOrders[newOrder.id]= newOrder.id;
    }
    
    // todo: implement deleteLimitOrder, which will delete a limit order from the orderBook as long as the same trader is deleting
    // it.
        function deleteLimitOrder(
        uint id,
        bytes32 ticker,
        Side side) external returns (bool) {
            
            Order memory o = orders[id];
            if (msg.sender == o.trader){
                Heap.Node memory removed;
             if (o.side == IExc.Side.BUY){
                 //if cancel buy order, get refunded Pine?
                removed = allBuyBooks[ticker].extractById(id);
             }
            else if (o.side == IExc.Side.SELL){
                //if cancel sell order, get refunded TOken 1
                //orders[id] = 0;
                removed = allSellBooks[ticker].extractById(id);
                ///delete from order book
                }
                
            if (removed.id == 0 && removed.priority == 0){
                return false;
            }
            
            delete(orders[id]);
            allOrders[id] = 0;
            return true;
            
            }
            return false;
    }
    
    // todo: implement makeMarketOrder, which will execute a market order on the current orderbook. The market order need not be
    // added to the book explicitly, since it should execute against a limit order immediately. Make sure you are getting rid of
    // completely filled limit orders!
    function makeMarketOrder(
        bytes32 ticker,
        uint amount,
        Side side)
        external {
            ///what does side indicate in the inputs?
            //msg sender wants to buy an item
            //msg sender wants to interract with the buy side (thus sell)
             if (side == IExc.Side.BUY){
                 uint id = allSellBooks[ticker].getMax().id;
                 uint new_amount = amount;
                 
                  while ((orders[id].amount - orders[id].filled) <= new_amount){
                  Heap.Node memory removedMax = allSellBooks[ticker].extractMax();
                  uint new_amount = amount - (orders[id].amount - orders[id].filled);
                  
                  emit NewTrade(trade_ticker, 
                            id,
                            orders[id].ticker,
                            orders[id].trader,
                            msg.sender,
                            orders[id].amount - orders[id].filled,
                            orders[id].price,
                            now);
                            
                //update balances- Buyer
                traderBalances[msg.sender][ticker] += new_amount;
                traderBalances[msg.sender][PIN] -= new_amount;
                
                //update balances- Seller
                traderBalances[orders[id].trader][ticker] -= new_amount;
                traderBalances[orders[id].trader][PIN] += new_amount;
                
                   //update information     
                  trade_ticker++;          
                  delete(orders[id]); 
                  allOrders[id]= 0;
                  id = allSellBooks[ticker].getMax().id;
                  
                  }
                  orders[id].filled += new_amount;
                  
                  emit NewTrade(trade_ticker, 
                            id,
                            ticker,
                            orders[id].trader,
                            msg.sender,
                            new_amount,
                            orders[id].price,
                            now);
                            
                trade_ticker++;    
               // market_order_ticker++; 
                 
              //record event
             } else if (side == IExc.Side.SELL){
               uint id = allBuyBooks[ticker].getMax().id;
                 uint new_amount = amount;
                 
                  while ((orders[id].amount - orders[id].filled) <= new_amount){
                  Heap.Node memory removedMax = allBuyBooks[ticker].extractMax();
                  new_amount = amount - (orders[id].amount - orders[id].filled);
                  
                   emit NewTrade(trade_ticker, 
                            id,
                            orders[id].ticker,
                            orders[id].trader,
                            msg.sender,
                            orders[id].amount - orders[id].filled,
                            orders[id].price,
                            now);
                  trade_ticker++; 
                  
                  //update balances- Seller
                traderBalances[msg.sender][ticker] -= new_amount;
                traderBalances[msg.sender][PIN] += new_amount;
                
                //update balances- Buyer
                traderBalances[orders[id].trader][ticker] += new_amount;
                traderBalances[orders[id].trader][PIN] -= new_amount;
                 
                 //update information 
                  delete(orders[id]);
                  allOrders[id] = 0;
                  id = allBuyBooks[ticker].getMax().id;
                  
                  
                  }
                  orders[id].filled += new_amount;
                  
                  ///should I emit trade for market order itself or is that repetitive
                   emit NewTrade(trade_ticker, 
                            id,
                            ticker,
                            orders[id].trader,
                            msg.sender,
                            new_amount,
                            orders[id].price,
                            now);
                            
                trade_ticker++; 
             }   
    }
    
    //todo: add modifiers for methods as detailed in handout
    
      function getNextID() external returns (uint){
        return id_ticker;
    }

}

