const Strings = artifacts.require("Strings");
const Types = artifacts.require("Types");
const Helpers = artifacts.require("Helpers");
const Dropbox = artifacts.require("Dropbox");

module.exports = function (deployer, network, accounts) {
  console.log(accounts);

  if (network == "development") {
    deployer.deploy(Strings);
    deployer.deploy(Types);
    deployer.link(Strings, Helpers);
    deployer.deploy(Helpers);
    deployer.link(Types, Dropbox);
    deployer.link(Helpers, Dropbox);
    deployer.deploy(Dropbox);
  } else {
    // For live & test networks

    deployer.deploy(Strings);
    deployer.deploy(Types);
    deployer.link(Strings, Helpers);
    deployer.deploy(Helpers);
    deployer.link(Types, Dropbox);
    deployer.link(Helpers, Dropbox);
    deployer.deploy(Dropbox);
  }
};
