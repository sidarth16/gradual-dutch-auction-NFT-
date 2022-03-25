// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {DSTest} from "ds-test/test.sol";
import {Utilities} from "./utils/Utilities.sol";
import {console} from "./utils/Console.sol";
import {Vm} from "forge-std/Vm.sol";
import {MockDiscreteGDA} from "./mocks/MockDiscreteGDA.sol";
import {PRBMathSD59x18} from "prb-math/PRBMathSD59x18.sol";
import {Strings} from "openzeppelin/utils/Strings.sol";

contract DiscreteGDATest is DSTest {
    using PRBMathSD59x18 for int256;
    using Strings for int256;

    Vm internal immutable vm = Vm(HEVM_ADDRESS);

    Utilities internal utils;
    address payable[] internal users;
    MockDiscreteGDA internal gda;

    function setUp() public {
        utils = new Utilities();
        users = utils.createUsers(5);

        int256 priceScale = PRBMathSD59x18.fromInt(1000);
        int256 decayConstant = PRBMathSD59x18.fromInt(1).div(
            PRBMathSD59x18.fromInt(2)
        );

        gda = new MockDiscreteGDA("Token", "TKN", priceScale, decayConstant);
    }

    //todo: expand test suite
    function testPricing() public {
        //move time forward to allow for decay

        uint256 purchasePrice = gda.purchasePrice(1);
        vm.deal(address(this), purchasePrice);

        gda.purchaseTokens{value: purchasePrice}(1, address(this));

        uint256 time = block.timestamp;
        vm.warp(time + 10);

        purchasePrice = gda.purchasePrice(9);
        console.log(purchasePrice);
    }

    function testCorrectnessOne() public {
        string[] memory inputs = new string[](3);
        inputs[0] = "python3";
        inputs[1] = "analysis/compute_price.py";
        inputs[2] = "exp_discrete";
        bytes memory res = vm.ffi(inputs);
        console.logBytes(res);
        bytes memory enc = abi.encode(1000);
        console.logBytes(enc);

        // uint256 num = abi.decode(res, (uint256));
        // console.log("testNumber", num);
    }

    //make payable
    fallback() external payable {}
}
