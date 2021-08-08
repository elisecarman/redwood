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




    });


