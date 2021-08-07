pragma solidity 0.5.3;

// Eth Heap
// Author: Zac Mitton
// License: MIT

library Heap{ // default max-heap
  //  using IEx for Heap.Data;

  uint constant ROOT_INDEX = 1;

  struct Data{
    int128 idCount;
    Node[] nodes; // root is index 1; index 0 not used
    mapping (uint => uint) indices; // unique id => node index
  }
  
  struct Node{
    uint id; //use with another mapping to store arbitrary object types
    uint priority;
  }

  //call init before anything else
  function init(Data storage self) internal{
    if(self.nodes.length == 0) self.nodes.push(Node(0,0));
  }

  function insert(Data storage self, uint priority, uint id) internal returns(Node memory){//√
    if(self.nodes.length == 0){ init(self); }// test on-the-fly-init
    self.idCount++;
    self.nodes.length++;
    Node memory n = Node(id, priority);
    _bubbleUp(self, n, self.nodes.length-1);
    return n;
  }
  function extractMax(Data storage self) internal returns( Node memory){//√
    return _extract(self, ROOT_INDEX);
  }
  function extractById(Data storage self, uint id) internal returns(Node memory){//√
    return _extract(self, self.indices[id]);
  }

  //view
  function dump(Data storage self) internal view returns(Node[] memory){
  //note: Empty set will return `[Node(0,0)]`. uninitialized will return `[]`.
    return self.nodes;
  }
  function getById(Data storage self, uint id) internal view returns(Node memory){
    return getByIndex(self, self.indices[id]);//test that all these return the emptyNode
  }
  function getByIndex(Data storage self, uint i) internal view returns(Node memory){
    return self.nodes.length > i ? self.nodes[i] : Node(0,0);
  }
  function getMax(Data storage self) internal view returns(Node memory){
    return getByIndex(self, ROOT_INDEX);
  }
  function size(Data storage self) internal view returns(uint){
    return self.nodes.length > 0 ? self.nodes.length-1 : 0;
  }
  function isNode(Node memory n ) internal pure returns(bool ){ 
      return n.id > 0; }

  //private
  function _extract(Data storage self, uint i) private returns(Node memory){//√
    if(self.nodes.length <= i || i <= 0){ return Node(0,0); }

    Node memory extractedNode = self.nodes[i];
    delete self.indices[extractedNode.id];

    Node memory tailNode = self.nodes[self.nodes.length-1];
    self.nodes.length--;

    if(i < self.nodes.length){ // if extracted node was not tail
      _bubbleUp(self, tailNode, i);
      _bubbleDown(self, self.nodes[i], i); // then try bubbling down
    }
    return extractedNode;
  }
  function _bubbleUp(Data storage self, Node memory n, uint i) private{//√
    if(i==ROOT_INDEX || n.priority <= self.nodes[i/2].priority){
      _insert(self, n, i);
    }else{
      _insert(self, self.nodes[i/2], i);
      _bubbleUp(self, n, i/2);
    }
  }
  function _bubbleDown(Data storage self, Node memory n, uint i) private{//
    uint length = self.nodes.length;
    uint cIndex = i*2; // left child index

    if(length <= cIndex){
      _insert(self, n, i);
    }else{
      Node memory largestChild = self.nodes[cIndex];

      if(length > cIndex+1 && self.nodes[cIndex+1].priority > largestChild.priority ){
        largestChild = self.nodes[++cIndex];// TEST ++ gets executed first here
      }

      if(largestChild.priority <= n.priority){ //TEST: priority 0 is valid! negative ints work
        _insert(self, n, i);
      }else{
        _insert(self, largestChild, i);
        _bubbleDown(self, n, cIndex);
      }
    }
  }

  function _insert(Data storage self, Node memory n, uint i) private{//√
    self.nodes[i] = n;
    self.indices[n.id] = i;
  }
}

//////////////BANK


//  function insert3(Order memory order, Side side, bytes32 ticker)public returns (bool) {
//          if (side == IExc.Side.SELL){ //-> priority: LOWEST PRICE
//             uint i;
//             if (allSellBooks2[ticker].length == 0){
//                 allSellBooks2[ticker].push(order);
//             } else {
            
//           for (i = 0; i < allSellBooks2[ticker].length; i++) { 
//              if (order.price >= allSellBooks2[ticker][i].price){  ///old sign <  //added an equal
//               push_right(i, side, ticker);
//               allSellBooks2[ticker][i] = order;
//               return true;
//           }
//         }
        
//         allSellBooks2[ticker].push(order);
//         return true;
//         }
            
//         } else if( side == IExc.Side.BUY){ //-. PRIORITY: HIGHEST PRICE
//              uint i;
//             if (allBuyBooks2[ticker].length == 0){
//                 allBuyBooks2[ticker].push(order);
//             } else {
            
//           for (i = 0; i < allBuyBooks2[ticker].length; i++) { 
//              if (order.price <= allBuyBooks2[ticker][i].price){  ///old sign <  //added an equal
//               push_right(i, side, ticker);
//               allBuyBooks2[ticker][i] = order;
//               return true;
//           }
//         }
        
//         allSellBooks2[ticker].push(order);
//         return true;
//         }
        
//      }
     
//      return false;
//      }






//  function push_left(uint start, Side side, bytes32 ticker) internal{
//         uint i;
//          if (side == IExc.Side.SELL){
//              for (i = start; i < allSellBooks2[ticker].length; i++){
//                  if (i == SafeMath.sub(allSellBooks2[ticker].length, 1)){
//                      delete allSellBooks2[ticker][i];
//                      allSellBooks2[ticker].pop();
//                  }
//               allSellBooks2[ticker][i]=  allSellBooks2[ticker][SafeMath.add(i, 1)];
                 
//              }
//          } else if (side == IExc.Side.BUY){
//              for (i = start; i < allBuyBooks2[ticker].length; i++){
//                   if (i == SafeMath.sub(allBuyBooks2[ticker].length, 1)){
//                      delete allBuyBooks2[ticker][i];
//                      allBuyBooks2[ticker].pop();
//                  }
//               allBuyBooks2[ticker][i]=  allBuyBooks2[ticker][SafeMath.add(i, 1)];
                 
//              } 
//          }
//     }




//   function push_right(uint end, Side side, bytes32 ticker) internal{
//      uint i;
//       if (side == IExc.Side.SELL){
//           uint last = SafeMath.sub(allSellBooks2[ticker].length, 1);
          
//           //duplicate end element
//           allSellBooks2[ticker].push(allSellBooks2[ticker][last]);
          
          
//           //readjust elements between insertion spot and new end
//              for (i = last; i > end; i--){
                 
//               allSellBooks2[ticker][i]=  allSellBooks2[ticker][SafeMath.sub(i, 1)];
                 
//              }
//          } else if (side == IExc.Side.BUY){
//              uint last = SafeMath.sub(allBuyBooks2[ticker].length, 1);
            
//              allBuyBooks2[ticker].push(allBuyBooks2[ticker][last]);
          
          
//           //readjust elements between insertion spot and new end
//              for (i = last; i > end; i--){
                 
//               allBuyBooks2[ticker][i]=  allBuyBooks2[ticker][SafeMath.sub(i, 1)];
                 
//              }
            
//          }
//      }


     
