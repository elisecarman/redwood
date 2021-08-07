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
    
   // mapping(bytes32 => Heap.Data) public allSellBooks;
//    mapping(bytes32 => Heap.Data) public allBuyBooks;
    
    mapping(bytes32 => Order[]) public allSellBooks2;
    mapping(bytes32 => Order[]) public allBuyBooks2;
    
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
   // uint public market_order_ticker;
    
    
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
        
       if (side == IExc.Side.BUY){
           return allBuyBooks2[ticker];
       } else if  (side == IExc.Side.SELL){
           return allSellBooks2[ticker];
       }
        
   
         //return allOrders;
    }
    
  

    // todo: implement getTokens, which simply returns an array of the tokens currently traded on in the exchange
    function getTokens() 
      external 
      view 
      returns(Token[] memory) {
        uint i;
        Token[] memory tok_list = new Token[](tokenList.length);
        
          for (i = 0; i < tokenList.length; i++) {
              if ( tokens[tokenList[i]].tokenAddress != address(0)){
         tok_list[i]= tokens[tokenList[i]];
              }
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
            require (contains_token[ticker]);
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
            require(contains_token[ticker] && traderBalances[msg.sender][ticker] >= amount);
            //IERC20(tokens[ticker].tokenAddress).approve(address(this), amount);
            IERC20(tokens[ticker].tokenAddress).transfer(msg.sender, amount);
            
            traderBalances[msg.sender][ticker] -= amount;
            
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
            
        
         if (side == IExc.Side.SELL){
          require(ticker != PIN && contains_token[ticker] && traderBalances[msg.sender][ticker] >= amount);
             
         } else if (side == IExc.Side.BUY){
              require(ticker != PIN && contains_token[ticker] && traderBalances[msg.sender][PIN] >= SafeMath.mul(amount, price));
         }
         
       
            
        uint order_id = id_ticker;
        Order memory newOrder = Order(order_id, msg.sender,side, ticker, amount, 0, price, now );
        id_ticker = SafeMath.add(id_ticker, 1);
        
        insert(newOrder, side, ticker);
        
        //   uint id;
        // address trader;
        // Side side;
        // bytes32 ticker;
        // uint amount;
        // uint filled;
        // uint price;
        // uint date;
        
    }
    

        
    function make_Order(uint id, 
    address trader, 
    Side side, 
    bytes32 ticker, 
    uint amount, 
    uint filled, 
    uint price)public returns (Order memory) {
       Order memory order = IExc.Order(id,
        trader, 
        side, 
        ticker, 
        amount, 
        filled, 
        price, 
        now);
        
        return order;
    }
    
    function insert2(Order memory order, Side side, bytes32 ticker) public{
        if (side == IExc.Side.SELL){ //-> priority: LOWEST PRICE
            //allSellBooks2.length++;
            uint i;
            Order memory swap_item = order;
            if (allSellBooks2[ticker].length == 0){
                allSellBooks2[ticker].push(order);
            } else {
            
           for (i = 0; i < allSellBooks2[ticker].length; i++) { 
             if (swap_item.price > allSellBooks2[ticker][i].price){  ///old sign <
                Order memory holder = allSellBooks2[ticker][i];
                allSellBooks2[ticker][i] = swap_item;
                swap_item = holder;
           }
           //see if last element gets included-- depends oif the length was updated
           //or just don't update, push last item
        }
        allSellBooks2[ticker].push(swap_item);
        }
            
        } else if( side == IExc.Side.BUY){ //-. PRIORITY: HIGHEST PRICE
        
            uint i;
            Order memory swap_item = order;
            
            if (allBuyBooks2[ticker].length == 0){
                allBuyBooks2[ticker].push(order);
            }
            
           for (i = 0; i < allBuyBooks2[ticker].length; i++) { 
             if (swap_item.price < allBuyBooks2[ticker][i].price){  ///>
                Order memory holder = allBuyBooks2[ticker][i];
                allBuyBooks2[ticker][i] = swap_item;
                swap_item = holder;
           }
           //see if last element gets included-- depends oif the length was updated
           //or just don't update, push last item
        }
        allBuyBooks2[ticker].push(swap_item); 
        }
    }
    
    
    function delete_element2(uint id, Side side, bytes32 ticker) internal returns (bool){
         if (side == IExc.Side.SELL){
             uint i;
             uint swap_item = id;
             
             for (i = 0; i < allSellBooks2[ticker].length; i++) {
                 
             if (allSellBooks2[ticker][i].id == swap_item){
                 if (i == allSellBooks2[ticker].length - 1){
               delete allSellBooks2[ticker][i];
               allSellBooks2[ticker].pop();
               return true;
                 }
                 
                 swap_item = allSellBooks2[ticker][i+1].id;
                 Order memory holder = allSellBooks2[ticker][i+1];
                allSellBooks2[ticker][i] = holder;
             }
                 
             }
             return false;
             
         } else if (side == IExc.Side.BUY){
            uint i;
             uint swap_item = id;
             for (i = 0; i < allBuyBooks2[ticker].length; i++) {
                 
             if (allBuyBooks2[ticker][i].id == swap_item){
                 if (i == allBuyBooks2[ticker].length - 1){
               delete allBuyBooks2[ticker][i];
               allBuyBooks2[ticker].pop();
               return true;
                 }
                 swap_item = allBuyBooks2[ticker][i+1].id;
                 Order memory holder = allBuyBooks2[ticker][i+1];
                allBuyBooks2[ticker][i] = holder;
             }
                 
             }
             return false;
         }
    }
    
    // todo: implement deleteLimitOrder, which will delete a limit order from the orderBook as long as the same trader is deleting
    // it.
        function deleteLimitOrder(
        uint id,
        bytes32 ticker,
        Side side) external returns (bool) {
            require (contains_token[ticker] && ticker != PIN);
        
            
            bool  deleted = delete_element(id, side, ticker);
            return deleted;
            
    }
    
    function remove_max(Side side, bytes32 ticker) internal{
        if (side == IExc.Side.SELL){
     
        uint last = SafeMath.sub(allSellBooks2[ticker].length, 1);
        delete allSellBooks2[ticker][last];
        allSellBooks2[ticker].pop();
        
        
    } else if (side == IExc.Side.BUY){
   
    
    uint last = SafeMath.sub(allBuyBooks2[ticker].length, 1);
        delete allBuyBooks2[ticker][last];
        allBuyBooks2[ticker].pop();
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
            ///what does side indicate in the inputs?
            //msg sender wants to buy an item
            //msg sender wants to interract with the buy side (thus sell)
            
             if (side == IExc.Side.BUY){
                 
                 require(contains_token[ticker]);
                 //require(traderBalances[msg.sender][PIN] >= SafeMath.mul(amount, price));
                 require(ticker != PIN);
                 
                 //uint id = allSellBooks[ticker].getMax().id;
                 uint last = allSellBooks2[ticker].length - 1;
                 Order memory max_order = allSellBooks2[ticker][last];
                 uint new_amount = amount;
                 
                  while ((max_order.amount - max_order.filled) <= new_amount){
                 // uint to_pay = SafeMath.mul(SafeMath.sub(max_order.amount, max_order.filled), max_order.price);
                  uint to_pay = (max_order.amount - max_order.filled) * max_order.price;
                  require(traderBalances[msg.sender][PIN] >= to_pay);
                  
                  remove_max(IExc.Side.SELL, ticker);
                  new_amount = new_amount - (max_order.amount - max_order.filled);
                  
                  emit NewTrade(trade_ticker, 
                            max_order.id,
                            ticker,
                            max_order.trader,
                            msg.sender,
                            max_order.amount - max_order.filled,
                            max_order.price,
                            now);
                            
                //update balances- Buyer
                traderBalances[msg.sender][ticker] += new_amount;
                //traderBalances[msg.sender][PIN] -= SafeMath.mul(new_amount, max_order.price) ;
                 traderBalances[msg.sender][PIN] -= (new_amount * max_order.price) ;
                
                //update balances- Seller
                traderBalances[max_order.trader][ticker] -= new_amount;
                //traderBalances[max_order.trader][PIN] += SafeMath.mul(new_amount, max_order.price);
                traderBalances[max_order.trader][PIN] += (new_amount * max_order.price);
                      
                  trade_ticker++;          
                 
                 uint last2 = allSellBooks2[ticker].length - 1;
                 max_order = allSellBooks2[ticker][last2];
                  }
                  
                  uint to_pay = SafeMath.mul(new_amount, max_order.price);
                  require(traderBalances[msg.sender][PIN] >= to_pay);
                  
                  max_order.filled += new_amount;
                  
                  emit NewTrade(trade_ticker, 
                            max_order.id,
                            ticker,
                            max_order.trader,
                            msg.sender,
                            new_amount,
                            max_order.price,
                            now);
                            
                trade_ticker++;    
               // market_order_ticker++; 
                 
              //record event
             } else if (side == IExc.Side.SELL){
                 
                  require(contains_token[ticker]);
                 require(traderBalances[msg.sender][ticker] >= amount);
                 require(ticker != PIN);
                 
                  uint last = allBuyBooks2[ticker].length - 1;
                Order memory max_order = allBuyBooks2[ticker][last];
                 uint new_amount = amount;
                 
                  while ((max_order.amount - max_order.filled) <= new_amount){
                  //Heap.Node memory removedMax = allSellBooks[ticker].extractMax();
                  remove_max(IExc.Side.BUY, ticker);
                  new_amount = new_amount - (max_order.amount - max_order.filled);
                  
                  emit NewTrade(trade_ticker, 
                            max_order.id,
                            ticker,
                            max_order.trader,
                            msg.sender,
                            max_order.amount - max_order.filled,
                            max_order.price,
                            now);
                            
                //update balances- Buyer
                traderBalances[msg.sender][ticker] += new_amount;
                //traderBalances[msg.sender][PIN] -= SafeMath.mul(new_amount, max_order.price) ;
                traderBalances[msg.sender][PIN] -= (new_amount * max_order.price) ;
                
                //update balances- Seller
                traderBalances[max_order.trader][ticker] -= new_amount;
                //traderBalances[max_order.trader][PIN] += SafeMath.mul(new_amount, max_order.price);
                traderBalances[max_order.trader][PIN] += (new_amount * max_order.price);
                   //update information     
                  trade_ticker++;          
                 // delete(orders[id]); 
                 // allOrders[id]= 0;
                 
                  uint last2 = allBuyBooks2[ticker].length - 1;
                 max_order = allBuyBooks2[ticker][last2];
                 // id = allSellBooks[ticker].getMax().id;
                  }
                  
                  max_order.filled += new_amount;
                  
                  emit NewTrade(trade_ticker, 
                            max_order.id,
                            ticker,
                            max_order.trader,
                            msg.sender,
                            new_amount,
                            max_order.price,
                            now);
                            
                trade_ticker++;    
    }
}
    
    //todo: add modifiers for methods as detailed in handout
    
      function getNextID() external returns (uint){
        return id_ticker;
    }
    
    
 function insert(Order memory order, Side side, bytes32 ticker)public returns (bool) {
         if (side == IExc.Side.SELL){ //-> priority: LOWEST PRICE
            uint i;
            if (allSellBooks2[ticker].length == 0){
                allSellBooks2[ticker].push(order);
                return true;
                
            } else {
            
          for (i = 0; i < allSellBooks2[ticker].length; i++) { 
             if (order.price >= allSellBooks2[ticker][i].price){  ///old sign <  //added an equal
              push_right(i, side, ticker);
              allSellBooks2[ticker][i] = order;
              return true;
          }
        }
        
        allSellBooks2[ticker].push(order);
        return true;
        }
            
        } else if( side == IExc.Side.BUY){ //-. PRIORITY: HIGHEST PRICE
             uint i;
            if (allBuyBooks2[ticker].length == 0){
                allBuyBooks2[ticker].push(order);
                return true;
                
            } else {
            
          for (i = 0; i < allBuyBooks2[ticker].length; i++) { 
             if (order.price <= allBuyBooks2[ticker][i].price){  ///old sign <  //added an equal
              push_right(i, side, ticker);
              allBuyBooks2[ticker][i] = order;
              return true;
          }
        }
        
        allBuyBooks2[ticker].push(order);
        return true;
        }
        
     }
     
     return false;
     }



  function push_right(uint end, Side side, bytes32 ticker) internal{
     uint i;
      if (side == IExc.Side.SELL){
          uint last = SafeMath.sub(allSellBooks2[ticker].length, 1);
          
          //duplicate end element
          Order memory repeat_last = allSellBooks2[ticker][last];
          allSellBooks2[ticker].push(repeat_last);
          
          
          //readjust elements between insertion spot and new end
             for (i = last; i > end; i--){
                 
              allSellBooks2[ticker][i]=  allSellBooks2[ticker][SafeMath.sub(i, 1)];
                 
             }
         } else if (side == IExc.Side.BUY){
             uint last = SafeMath.sub(allBuyBooks2[ticker].length, 1);
            
             allBuyBooks2[ticker].push(allBuyBooks2[ticker][last]);
          
          
          //readjust elements between insertion spot and new end
             for (i = last; i > end; i--){
                 
              allBuyBooks2[ticker][i]=  allBuyBooks2[ticker][SafeMath.sub(i, 1)];
                 
             }
            
         }
     }



 function push_left(uint start, Side side, bytes32 ticker) internal{
        uint i;
         if (side == IExc.Side.SELL){
             for (i = start; i < allSellBooks2[ticker].length; i++){
                 if (i == SafeMath.sub(allSellBooks2[ticker].length, 1)){
                     delete allSellBooks2[ticker][i];
                     allSellBooks2[ticker].pop();
                 }
              allSellBooks2[ticker][i]=  allSellBooks2[ticker][SafeMath.add(i, 1)];
                 
             }
         } else if (side == IExc.Side.BUY){
             for (i = start; i < allBuyBooks2[ticker].length; i++){
                  if (i == SafeMath.sub(allBuyBooks2[ticker].length, 1)){
                     delete allBuyBooks2[ticker][i];
                     allBuyBooks2[ticker].pop();
                 }
              allBuyBooks2[ticker][i]=  allBuyBooks2[ticker][SafeMath.add(i, 1)];
                 
             } 
         }
    }




     
     function delete_element(uint id, Side side, bytes32 ticker) internal returns (bool){
         if (side == IExc.Side.SELL){
             if (allSellBooks2[ticker].length == 0){return false;}
             uint i;
             for (i = 0; i < allSellBooks2[ticker].length; i++) {
                 
             if (allSellBooks2[ticker][i].id == id){
               push_left(i, side, ticker);
               return true;
             }
                 
             }
             return false;
             
         } else if (side == IExc.Side.BUY){
             if (allBuyBooks2[ticker].length == 0){return false;}
            uint i;
             uint swap_item = id;
             for (i = 0; i < allBuyBooks2[ticker].length; i++) {
                 
             if (allBuyBooks2[ticker][i].id == swap_item){
                push_left(i, side, ticker);
                return true;
             }
                 
             }
             return false;
         }
    }



}

