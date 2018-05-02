/**
 * Created by Jimmy on 2018/3/16.
 */

var cmcontract = artifacts.require("./CMContract.sol");

module.exports = function(deployer) {
  deployer.deploy(cmcontract);
};

