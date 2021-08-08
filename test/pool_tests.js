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

contract('Pool', (accounts) => {
    let pin, zrx, exc, pool;
    const [trader1, trader2] = [accounts[1], accounts[2]];
    const [PIN, ZRX] = ['PIN', 'ZRX']
        .map(ticker => web3.utils.fromAscii(ticker));

    beforeEach(async() => {
        ([pin, zrx] = await Promise.all([
            Pin.new(),
            Zrx.new()
        ]));
        exc = await Exc.new();
        fac = await Fac.new();

       // pool = await Pool.new();
    });

    it('should deposit/ withdraw tokens in pool', async () => {
    await exc.addToken (ZRX, zrx.address);
    await exc.addToken (PIN, pin.address);

     let event = await fac.createPair(
                            pin.address,
                            zrx.address,
                            pin.address,
                            exc.address,
                            PIN,
                            ZRX
                        );
            let log = event.logs[0];
            let poolAd = log.args.pair;
             pool = await Pool.at(poolAd);

    await zrx.mint(trader1, 1000);
    await pin.mint(trader1, 1000);
await zrx.approve(poolAd,10, {from: trader1});
await pin.approve(poolAd,10, {from: trader1});

await pool.deposit(10, 10, {from: trader1});
    const wallet = await pool.get_balance(trader1, ZRX);
    const wallet2 = await pool.get_balance(trader1, PIN);
    assert.equal(wallet2, 10, 'deposit executed');
    assert.equal(wallet, 10, 'deposit executed');
    });

 it('withdraw/deposit - should revert for various reasons', async () => {
    expectRevert.unspecified(pool.withdraw(100,100, { from: trader1 }),
    "Should not allow withdraw more than deposited.");

     expectRevert.unspecified(pool.deposit(100,100, { from: trader1 }),
        "Should not allow withdraw more than deposited.");

    });

    it('should withdraw', async () => {
        await exc.addToken (ZRX, zrx.address);
        await exc.addToken (PIN, pin.address);

         let event = await fac.createPair(
                                pin.address,
                                zrx.address,
                                pin.address,
                                exc.address,
                                PIN,
                                ZRX
                            );
                let log = event.logs[0];
                let poolAd = log.args.pair;
                 pool = await Pool.at(poolAd);

        await zrx.mint(trader1, 1000);
        await pin.mint(trader1, 1000);
    await zrx.approve(poolAd,10, {from: trader1});
    await pin.approve(poolAd,10, {from: trader1});

    await pool.deposit(10, 10, {from: trader1});
        //const wallet = await pool.wallet1[trader1];
        const wallet = await pool.get_balance(trader1, ZRX);
        const wallet2 = await pool.get_balance(trader1, PIN);
        assert.equal(wallet2, 10, 'deposit executed');
        assert.equal(wallet, 10, 'deposit executed');

        await pool.withdraw(5, 5, {from: trader1});
        const wallet3 = await pool.get_balance(trader1, ZRX);
        const wallet4 = await pool.get_balance(trader1, PIN);
          assert.equal(wallet3, 5, 'deposit executed');
          assert.equal(wallet4, 5, 'deposit executed');
        });


it("deposit 100 PIN and ZRX into Pool, market order fills all on one side", async () => {
 let event = await fac.createPair(pin.address, zrx.address, pin.address, exc.address, PIN, ZRX);
 poolAd = event.logs[0].args.pair;
 pool = await Pool.at(poolAd);

 let eventAddPIN = await exc.addToken(PIN, pin.address);
 let eventAddZRX = await exc.addToken(ZRX, zrx.address);
 let tokens = await exc.getTokens();

 // create pin and zrx tokens for traders 1 and 2, and increase allowance
 let pinMintTrader1 = await pin.mint(trader1, 1000000000);
 let zrxMintTrader1 = await zrx.mint(trader1, 1000000000);
 let pinAllowPool = await pin.approve(poolAd, 500000000, { from: trader1 });
 let zrxAllowPool = await zrx.approve(poolAd, 500000000, { from: trader1 });
 let pinMintTrader2 = await pin.mint(trader2, 1000000000);
 let zrxMintTrader2 = await zrx.mint(trader2, 1000000000);
 pinAllowPool = await pin.approve(poolAd, 500000000, { from: trader2 });
 zrxAllowPool = await zrx.approve(poolAd, 500000000, { from: trader2 });

 let pinAllowExc = await pin.approve(exc.address, 500000000, { from: trader1 });
 let zrxAllowExc = await zrx.approve(exc.address, 500000000, { from: trader1 });
 pinAllowExc = await pin.approve(exc.address, 500000000, { from: trader2 });
 zrxAllowExc = await zrx.approve(exc.address, 500000000, { from: trader2 });

 let depositIntoPool = await pool.deposit(100, 100, { from: trader1 });
 let trader2DepositIntoExc = await exc.deposit(100, ZRX, { from: trader2 });
 let makeMarketOrder = await exc.makeMarketOrder(ZRX, 100, SIDE.SELL, { from: trader2 });
 // check order still exists, and filled and accounts are updated
 let orders = await exc.getOrders(ZRX, SIDE.BUY, { from: poolAd });
 assert.equal(orders.length, 0, "order should be completely filled!");

 let poolZRXBalance = await exc.getBalance(ZRX, { from: poolAd });
 let poolPINBalance = await exc.getBalance(PIN, { from: poolAd });
 let trader2ZRXBalance = await exc.getBalance(ZRX, { from: trader2 });
 let trader2PINBalance = await exc.getBalance(PIN, { from: trader2 });
 assert.equal(poolPINBalance.toString(), 0, "did not successfully transfer PIN from pool!");
 assert.equal(poolZRXBalance.toString(), 200, "did not successfully transfer ZRX to pool!");
 assert.equal(trader2PINBalance.toString(), 100, "did not successfully transfer PIN to trader2!");
 assert.equal(trader2ZRXBalance.toString(), 0, "did not successfully transfer ZRX from trader2!");
 });

it("deposit 100 PIN and ZRX into Pool, then market order fills half on one side", async () => {
 let event = await fac.createPair(pin.address, zrx.address, pin.address, exc.address, PIN, ZRX);
 poolAd = event.logs[0].args.pair;
 pool = await Pool.at(poolAd);

 let eventAddPIN = await exc.addToken(PIN, pin.address);
 let eventAddZRX = await exc.addToken(ZRX, zrx.address);
 let tokens = await exc.getTokens();

 // create pin and zrx tokens for traders 1 and 2, and increase allowance
 let pinMintTrader1 = await pin.mint(trader1, 1000000000);
 let zrxMintTrader1 = await zrx.mint(trader1, 1000000000);
 let pinAllowPool = await pin.approve(poolAd, 500000000, { from: trader1 });
 let zrxAllowPool = await zrx.approve(poolAd, 500000000, { from: trader1 });
 let pinMintTrader2 = await pin.mint(trader2, 1000000000);
 let zrxMintTrader2 = await zrx.mint(trader2, 1000000000);
 pinAllowPool = await pin.approve(poolAd, 500000000, { from: trader2 });
 zrxAllowPool = await zrx.approve(poolAd, 500000000, { from: trader2 });

 let pinAllowExc = await pin.approve(exc.address, 500000000, { from: trader1 });
 let zrxAllowExc = await zrx.approve(exc.address, 500000000, { from: trader1 });
 pinAllowExc = await pin.approve(exc.address, 500000000, { from: trader2 });
 zrxAllowExc = await zrx.approve(exc.address, 500000000, { from: trader2 });


 let depositIntoPool = await pool.deposit(100, 100, { from: trader1 });
 let trader2DepositIntoExc = await exc.deposit(100, ZRX, { from: trader2 });
 let makeMarketOrder = await exc.makeMarketOrder(ZRX, 50, SIDE.SELL, { from: trader2 });
 // check order still exists, and filled and accounts are updated
 let orders = await exc.getOrders(ZRX, SIDE.BUY, { from: poolAd });
 assert.equal(orders.length, 1, "order should only be partially filled!");
 assert.equal(orders[0].filled, 50, "filled amount incorrect!");

 let poolZRXBalance = await exc.getBalance(ZRX, { from: poolAd });
 let poolPINBalance = await exc.getBalance(PIN, { from: poolAd });
 let trader2ZRXBalance = await exc.getBalance(ZRX, { from: trader2 });
 let trader2PINBalance = await exc.getBalance(PIN, { from: trader2 });
 assert.equal(poolPINBalance.toString(), 50, "did not successfully transfer PIN from pool!");
 assert.equal(poolZRXBalance.toString(), 150, "did not successfully transfer ZRX to pool!");
 assert.equal(trader2PINBalance.toString(), 50, "did not successfully transfer PIN to trader2!");
 assert.equal(trader2ZRXBalance.toString(), 50, "did not successfully transfer ZRX from trader2!");
 });


    });


