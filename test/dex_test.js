const { expectRevert } = require('@openzeppelin/test-helpers');
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

assert.equal(token_count, 1, 'token added');
await exc.addToken (ZRX, zrx.address);

const tokens2 = await exc.getTokens();
const token_count2 = tokens2.length;
assert.equal(token_count2, 2, 'token added');

await exc.deposit(10, PIN, {from: trader1});
assert.equal(await exc.traderBalances(trader1, PIN), 10, 'deposit executed');

await exc.withdraw(5, PIN, {from: trader1});
assert.equal(await exc.traderBalances(trader1, PIN), 5 , "withdraw executed");
});



it('should add a token', async () => {
await pin.mint(trader1, 1000);
await pin.approve(exc.address,10, {from: trader1});
await exc.addToken (PIN, pin.address);
const tokens = await exc.getTokens();
const token_count = tokens.length;
assert.equal(token_count, 1, 'token added');
await exc.addToken (ZRX, zrx.address);
const tokens2 = await exc.getTokens();
const token_count2 = tokens2.length;
assert.equal(token_count2, 2, 'token added');
});


it('should create a limit order', async () => {
await zrx.mint(trader1, 1000);
await exc.addToken (ZRX, zrx.address);
await exc.addToken (PIN, pin.address);

await zrx.approve(exc.address,10, {from: trader1});
await exc.deposit(10, ZRX, {from: trader1});
await exc.makeLimitOrder(ZRX, 5, 1, SIDE.SELL, {from: trader1});
const orders = await exc.getOrders(ZRX, SIDE.SELL);
const length = orders.length;

assert.equal(length, 1, 'order added');

});

it('should create and delete a limit order', async () => {
await zrx.mint(trader1, 1000);
await exc.addToken (ZRX, zrx.address);
await exc.addToken (PIN, pin.address);

await zrx.approve(exc.address,10, {from: trader1});
await exc.deposit(10, ZRX, {from: trader1});
await exc.makeLimitOrder(ZRX, 5, 1, SIDE.SELL, {from: trader1});
const orders = await exc.getOrders(ZRX, SIDE.SELL);
const length = orders.length;

assert.equal(length, 1, 'order added');

await exc.deleteLimitOrder(0, ZRX, SIDE.SELL, {from: trader1});

const orders2 = await exc.getOrders(ZRX, SIDE.SELL);
const length2 = orders2.length;

assert.equal(length2, 0, 'order removed');
});

it('should create a market order and partially fill the first limit order', async () => {
await exc.addToken (ZRX, zrx.address);
await exc.addToken (PIN, pin.address);

await zrx.mint(trader1, 1000);
await zrx.approve(exc.address,10, {from: trader1});
await exc.deposit(10, ZRX, {from: trader1});

await pin.mint(trader2, 1000);
await pin.approve(exc.address,100, {from: trader2});
await exc.deposit(100, PIN, {from: trader2});

await exc.makeLimitOrder(ZRX, 5, 1, SIDE.SELL, {from: trader1});
const orders = await exc.getOrders(ZRX, SIDE.SELL);
const length = orders.length;

assert.equal(length, 1, 'order added');

await exc.makeMarketOrder(ZRX,1,SIDE.BUY, {from: trader2});
const order = await exc.getOrders(ZRX, SIDE.SELL);
const filled = await order[0].filled;


assert.equal(filled, 1, 'market order fulfilled');

});


it('should completely fill the market order', async () => {
await exc.addToken (ZRX, zrx.address);
await exc.addToken (PIN, pin.address);

await zrx.mint(trader1, 1000);
await zrx.approve(exc.address,10, {from: trader1});
await exc.deposit(10, ZRX, {from: trader1});

await pin.mint(trader2, 1000);
await pin.approve(exc.address,100, {from: trader2});
await exc.deposit(100, PIN, {from: trader2});

await exc.makeLimitOrder(ZRX, 5, 1, SIDE.SELL, {from: trader1});
const orders = await exc.getOrders(ZRX, SIDE.SELL);
const length = orders.length;

assert.equal(length, 1, 'order added');

await exc.makeMarketOrder(ZRX,5,SIDE.BUY, {from: trader2});
const order = await exc.getOrders(ZRX, SIDE.SELL);
const order_length = await order.length;


assert.equal(order_length, 0, 'limit order fulfilled');
});

});
