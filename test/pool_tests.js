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
        const pool = await Pool.at(poolAd);
       // pool = await Pool.new();
    });

    it('should deposit/ withdraw tokens in pool', async () => {
    await pin.mint(trader1, 1000);
    await pin.approve(pool.address,10, {from: trader1});
    //await exc.addToken (PIN, pin.address);


            const checkMe = await pool.testing(1);
            assert(checkMe, 5);

    await pool.initialize(trx.address);

    await pool.deposit(10, 0, {from: trader1});
    assert.equal(await pool.wallet1(trader1), 10, 'deposit executed');

    await exc.withdraw(5, 0, {from: trader1});
    assert.equal(await pool.wallet1(trader1), 5 , "withdraw executed");
    });
    });


