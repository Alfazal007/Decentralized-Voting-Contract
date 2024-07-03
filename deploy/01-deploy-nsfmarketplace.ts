const { network } = require("hardhat");
const { verify } = require("../scripts/verify");
import { developmentChains } from "../helper-hardhat-config";

module.exports = async ({
    getNamedAccounts,
    deployments,
}: {
    getNamedAccounts: any;
    deployments: any;
}) => {
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();
    let args: any = [];
    log("----------------------------------------------------");
    const voting = await deploy("Decentralized-Voting", {
        from: deployer,
        log: true,
        args: args,
        waitConfirmations: network.config.blockConfirmations,
    });
    if (
        !developmentChains.includes(network.name) &&
        process.env.ETHERSCANAPIKEY
    ) {
        log("Verifying the contract....");
        await verify(voting.address, args);
        log("Verification completed...");
    }
};

module.exports.tags = ["all", "NftMarketPlace"];
