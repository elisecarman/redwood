pragma solidity 0.5.3;

import './Pool.sol';

contract Factory {
    //what 
    
    
    
    // @notice some structures to keep track of what pairs have been created
    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;
    
    /// it seems original all Pairs may be inefficient
     mapping(address => bool)  public allPairs2;
    
    // @notice an event indicating when a pair has been created
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    
    function createPair(
        address tokenA,
        address tokenB,
        address quoting, address dex,  //decentralized exchange
        bytes32 tickerQ,
        bytes32 tickerT) external returns (address pair) {
        require(tickerQ == "PIN", 'First token in pair is not quote token');
        require(tokenA != tokenB, 'Identical addresses');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        uint whichP = tokenA < tokenB ? 1 : 2; ///if A is smaller, get 1?
        require(tokenB != address(0) && tokenA != address(0), 'Zero address error');
        require(getPair[tokenA][tokenB] == address(0) , 'Pair already exists');
        
        // todo: fill in the rest of the createPair method. To do this, you will need to deploy a smart contract using
        // a create2 opcode in assembly. This is probably beyond the scope of this project, so exact details will be
        // released on Piazza a few days after project release. Before that, you are encouraged to try your hand at
        // making the code yourself. You will also want to initialize the pool properly, and record the pair created 
        // properly in this contract.
        bytes memory bytecode = type(Pool).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        Pool(pair).initialize(token0, token1, dex, whichP, tickerQ, tickerT);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair;
        allPairs.push(pair);
        //allPairs2[pair] = true;
        emit PairCreated(token0, token1, pair, allPairs.length);
    }
    
}