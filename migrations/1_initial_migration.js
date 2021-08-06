const Migrations = artifacts.require("Migrations");
const Exchange = artifacts.require("Exc");
const Factory = artifacts.require("Factory");

module.exports = function (deployer) {//, _ network, accounts
  deployer.deploy(Migrations);//, account[0]
  deployer.deploy(Exchange);//, account[1]
  deployer.deploy(Factory);//, account[3]
};
