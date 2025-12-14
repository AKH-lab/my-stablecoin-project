'EOF'
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("StableCoin Contract", function () {
  let StableCoin;
  let stablecoin;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();
    StableCoin = await ethers.getContractFactory("StableCoin");
    stablecoin = await StableCoin.deploy("MyStableCoin", "MSC");
  });

  describe("Deployment", function () {
    it("Should set the right name", async function () {
      expect(await stablecoin.name()).to.equal("MyStableCoin");
    });

    it("Should set the right symbol", async function () {
      expect(await stablecoin.symbol()).to.equal("MSC");
    });

    it("Should assign the total supply of tokens to the owner", async function () {
      const ownerBalance = await stablecoin.balanceOf(owner.address);
      expect(ownerBalance).to.equal(1000000n * (10n ** 18n));
    });
  });

  describe("Transactions", function () {
    it("Should transfer tokens between accounts", async function () {
      await stablecoin.transfer(addr1.address, 100);
      const addr1Balance = await stablecoin.balanceOf(addr1.address);
      expect(addr1Balance).to.equal(100);

      await stablecoin.connect(addr1).transfer(addr2.address, 50);
      const addr2Balance = await stablecoin.balanceOf(addr2.address);
      expect(addr2Balance).to.equal(50);
    });

    it("Should fail if sender doesn't have enough tokens", async function () {
      const initialOwnerBalance = await stablecoin.balanceOf(owner.address);
      
      await expect(
        stablecoin.connect(addr1).transfer(owner.address, 1)
      ).to.be.reverted;

      expect(await stablecoin.balanceOf(owner.address)).to.equal(initialOwnerBalance);
    });
  });
});
