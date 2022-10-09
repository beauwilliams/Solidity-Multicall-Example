// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Multicall {
    error MulticallError();

    struct call {
        address target;
        bytes _calldata;
    }

    struct result {
        bool success;
        bytes returndata;
    }

    function aggregate(call[] calldata calls)
        public
        returns (uint256 blocknumber, bytes[] memory returndata)
    {
        blocknumber = block.number;
        returndata = new bytes[](calls.length);
        for (uint256 i = 0; i < calls.length; i++) {
            (bool success, bytes memory ret) = calls[i].target.call(
                calls[i]._calldata
            );
            if (!success) {
                revert MulticallError();
            }
            returndata[i] = ret;
        }
    }

    function tryaggregate(bool requiresuccess, call[] calldata calls)
        public
        returns (result[] memory returndata)
    {
        returndata = new result[](calls.length);
        for (uint256 i = 0; i < calls.length; i++) {
            (bool success, bytes memory ret) = calls[i].target.call(
                calls[i]._calldata
            );

            if (requiresuccess) {
                if (!success) {
                    revert MulticallError();
                }
            }

            returndata[i] = result(success, ret);
        }
    }

    function tryblockandaggregate(bool requiresuccess, call[] calldata calls)
        public
        returns (
            uint256 blocknumber,
            bytes32 _blockhash,
            result[] memory returndata
        )
    {
        blocknumber = block.number;
        _blockhash = blockhash(block.number);
        returndata = tryaggregate(requiresuccess, calls);
    }

    function blockandaggregate(call[] calldata calls)
        public
        returns (
            uint256 blocknumber,
            bytes32 _blockhash,
            result[] memory returndata
        )
    {
        (blocknumber, _blockhash, returndata) = tryblockandaggregate(
            true,
            calls
        );
    }

    function getblockhash(uint256 blocknumber)
        public
        view
        returns (bytes32 _blockhash)
    {
        _blockhash = blockhash(blocknumber);
    }

    function getblocknumber() public view returns (uint256 blocknumber) {
        blocknumber = block.number;
    }

    function getcurrentblockcoinbase() public view returns (address coinbase) {
        coinbase = block.coinbase;
    }

    function getcurrentblockdifficulty()
        public
        view
        returns (uint256 difficulty)
    {
        difficulty = block.difficulty;
    }

    function getcurrentblockgaslimit() public view returns (uint256 gaslimit) {
        gaslimit = block.gaslimit;
    }

    function getcurrentblocktimestamp()
        public
        view
        returns (uint256 timestamp)
    {
        timestamp = block.timestamp;
    }

    function getethbalance(address addr) public view returns (uint256 balance) {
        balance = addr.balance;
    }

    function getlastblockhash() public view returns (bytes32 _blockhash) {
        _blockhash = blockhash(block.number - 1);
    }
}
