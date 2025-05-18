// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Proxy} from "../src/Proxy.sol";
import {LogicV1} from "../src/LogicV1.sol";
import {LogicV2} from "../src/LogicV2.sol";

contract ProxyTest is Test {
    Proxy public proxy;
    LogicV1 public logicV1;
    LogicV2 public logicV2;
    address public admin;
    address public user;

    function setUp() public {
        // Set up accounts
        admin = makeAddr("admin");
        user = makeAddr("user");
        
        // Deploy implementation contracts
        logicV1 = new LogicV1();
        logicV2 = new LogicV2();
        
        // Deploy proxy with LogicV1 as initial implementation
        vm.prank(admin);
        proxy = new Proxy(address(logicV1), admin);
    }

    function test_ProxyInitialization() public {
        // Check that the implementation and admin are set correctly
        assertEq(proxy.getImplementation(), address(logicV1));
        assertEq(proxy.getAdmin(), admin);
    }

    function test_ProxyDelegation() public {
        // Cast proxy to LogicV1 interface
        LogicV1 proxiedLogic = LogicV1(address(proxy));
        
        // Initialize the logic through the proxy
        proxiedLogic.initialize(42);
        
        // Check that the counter is set correctly
        assertEq(proxiedLogic.getCounter(), 42);
        
        // Increment the counter
        proxiedLogic.increment();
        
        // Check that the counter was incremented
        assertEq(proxiedLogic.getCounter(), 43);
    }

    function test_UpgradeToV2() public {
        // Initialize V1 first
        LogicV1(address(proxy)).initialize(100);
        
        // Upgrade to V2
        vm.prank(admin);
        proxy.upgrade(address(logicV2));
        
        // Check that the implementation is updated
        assertEq(proxy.getImplementation(), address(logicV2));
        
        // Cast proxy to LogicV2 interface
        LogicV2 proxiedLogicV2 = LogicV2(address(proxy));
        
        // Check that the state is preserved (counter value)
        assertEq(proxiedLogicV2.getCounter(), 100);
        
        // Test new functionality in V2
        proxiedLogicV2.increment();
        assertEq(proxiedLogicV2.getCounter(), 101);
        
        proxiedLogicV2.decrement();
        assertEq(proxiedLogicV2.getCounter(), 100);
    }

    function test_OnlyAdminCanUpgrade() public {
        // Try to upgrade from non-admin account
        vm.prank(user);
        vm.expectRevert("Not admin");
        proxy.upgrade(address(logicV2));
        
        // Verify implementation didn't change
        assertEq(proxy.getImplementation(), address(logicV1));
        
        // Now upgrade as admin
        vm.prank(admin);
        proxy.upgrade(address(logicV2));
        
        // Verify implementation changed
        assertEq(proxy.getImplementation(), address(logicV2));
    }

    function test_CannotReinitialize() public {
        // Initialize first time
        LogicV1(address(proxy)).initialize(100);
        
        // Try to initialize again
        vm.expectRevert("Already initialized");
        LogicV1(address(proxy)).initialize(200);
        
        // Verify counter is still the original value
        assertEq(LogicV1(address(proxy)).getCounter(), 100);
    }
}
