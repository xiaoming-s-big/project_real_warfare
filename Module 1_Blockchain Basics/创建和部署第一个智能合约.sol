/*Description:
该挑战用来理解账号与 Gas，以及编写、编译、部署合约的全过程。
同时掌握Remix 、钱包、区块链浏览器简单使用
实战 4：创建和部署第一个智能合约，通过这个挑战熟悉编写、编译、部署合约的全过程，同时掌握Remix 、钱包、区块链浏览器简单使用
*/

/*Counter 合约具有

一个状态变量 counter
get()方法: 获取 counter 的值
add(x) 方法: 给变量加上 x 。*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Counter {
    uint256 private counter;

    // 获取 counter 的值
    function get() public view returns (uint256) {
        return counter;
    }

    // 给变量加上 x
    function add(uint256 x) public {
        counter += x;
    }
}