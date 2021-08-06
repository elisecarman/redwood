const Pin = artifacts.require('dummy/Pin.sol');
const Zrx = artifacts.require('dummy/Zrx.sol');
const Exc = artifacts.require('Exc.sol');
const Fac = artifacts.require('Factory.sol')
const Pool = artifacts.require('Pool.sol')

const SIDE = {
    BUY: 0,
    SELL: 1
};

contract('Exc', (accounts) => {
let pin, zrx, exc, fac;
const [trader1, trader2] = [accounts[1], accounts[2]];
const [PIN, ZRX] = ['PIN', 'ZRX']
.map(ticker => web3.utils.fromAscii(ticker));

beforeEach(async() => {
([pin, zrx] = await Promise.all([
    Pin.new(),
    Zrx.new()
]));
exc = await Exc.new();
pool = await Pool.new();

});


it('should deposit/ withdraw tokens', async () => {
await pin.mint(trader1, 1000);
await pin.approve(exc.address,10, {from: trader1});
await exc.addToken (PIN, pin.address);


const tokens = await exc.getTokens();
const token_count = tokens.length;
console.log(token_count);

assert.equal(token_count, 1, 'token added');

await exc.addToken (ZRX, zrx.address);



const tokens2 = await exc.getTokens();
const token_count2 = tokens2.length;
console.log(token_count2);
assert.equal(token_count2, 2, 'token added');


await exc.deposit(10, PIN, {from: trader1});
assert.equal(await exc.traderBalances(trader1, PIN), 10, 'deposit executed');

await exc.withdraw(5, PIN, {from: trader1});
assert.equal(await exc.traderBalances(trader1, PIN), 5 , "withdraw executed");
});

//it('should create one limit order', async () => {
//await zrx.mint(trader1, 1000);
//await zrx.approve(exc.address,10, {from: trader1});
//await exc.addToken (ZRX, zrx.address);
//await exc.deposit(10, ZRX, {from: trader1});
//
//await exc.makeLimitOrder(ZRX, 10, 1, SIDE.BUY, {from: trader1});
//const orders = await exc.AllBuyBooks2[ZRX].length;
//assert.equal(orders, 10, 'deposit executed');
//
//
//});



it('test insert', async () => {
await zrx.mint(trader1, 1000);
await zrx.approve(exc.address,10, {from: trader1});
await exc.addToken (ZRX, zrx.address);

//Buy: highest price first
const order1 = await exc.make_Order(0, trader1, SIDE.BUY, ZRX, 1, 0, 1 );
const order2 = await exc.make_Order(0, trader1, SIDE.BUY, ZRX, 1, 0, 2 );
const order3 = await exc.make_Order(0, trader1, SIDE.BUY, ZRX, 1, 0, 3 );
const order4 = await exc.make_Order(0, trader1, SIDE.BUY, ZRX, 1, 0, 4 );

console.log(order1);
console.log(order2);
console.log(order3);
console.log(order4);

//        id,
//        trader,
//        side,
//        ticker,
//        amount,
//        filled,
//        price,
//        date);


await exc.insert(order1, 0, ZRX);//SIDE.BUY

const buy_book = await exc.getOrders(ZRX, SIDE.BUY);
//console.log(buy_book.length);
//console.log(tokenList);
const order_book = buy_book[0];
assert.equal(order_book.id, order1.id, 'order added');


//
//let orders = await exc.getOrders(ZRX, SIDE.BUY, {from: trader1 });
//console.log(orders)

});

});
