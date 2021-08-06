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

it('tests insert function', async () => {
const simpleEx = await Exchange.deployed();

});

it('should deposit/ withdraw tokens', async () => {
await pin.mint(trader1, 1000);
await pin.approve(exc.address,10, {from: trader1});
await exc.addToken (PIN, pin.address);

await exc.deposit(10, PIN, {from: trader1});
assert.equal(await exc.traderBalances(trader1, PIN), 10, 'deposit executed');

await exc.withdraw(5, PIN, {from: trader1});
assert.equal(await exc.traderBalances(trader1, PIN), 5 , "withdraw executed");
});

it('should create one limit order', async () => {
await zrx.mint(trader1, 1000);
await zrx.approve(exc.address,10, {from: trader1});
await exc.addToken (ZRX, zrx.address);
await exc.deposit(10, ZRX, {from: trader1});

await exc.makeLimitOrder(ZRX, 10, 1, SIDE.BUY, {from: trader1});
const orders = await exc.AllBuyBooks2[ZRX].length;
assert.equal(orders, 10, 'deposit executed');


});

});