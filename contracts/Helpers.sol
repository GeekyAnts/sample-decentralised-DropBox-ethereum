// SPDX-License-Identifier: GPL-3.0
pragma experimental ABIEncoderV2;
pragma solidity >=0.4.25 <0.9.0;

import "./Strings.sol";

/**
 * @title Helpers
 * @author Suresh Konakanchi
 * @dev Library for managing all the helper functions
 */
library Helpers {
    using Strings for *;

    /**
     * @dev List of folders / files, whowhich are added by the current user. Data will be sent in pages to avoid the more gas fee
     * @param pageNumber page number for which data is needed (1..2..3....n)
     * @param data_ File / Folder Id's which are added by current user
     * @return pages Total pages available
     * @return pageLength_ Length of the current page
     * @return startIndex_ Starting index of the current page
     * @return endIndex_ Ending index of the current page
     */
    function getIndexes(uint256 pageNumber, string[] memory data_)
        internal
        pure
        returns (
            uint256 pages,
            uint256 pageLength_,
            uint256 startIndex_,
            uint256 endIndex_
        )
    {
        uint256 reminder_ = data_.length % 25;
        pages = data_.length / 25;
        if (reminder_ > 0) pages++;

        pageLength_ = 25;
        startIndex_ = 25 * (pageNumber - 1);
        endIndex_ = 25 * pageNumber;

        if (pageNumber > pages) {
            // Page requested is not existing
            pageLength_ = 0;
            endIndex_ = 0;
        } else if (pageNumber == pages && reminder_ > 0) {
            // Last page where we don't had 25 records
            pageLength_ = reminder_;
            endIndex_ = data_.length;
        }
    }

    /**
     * @notice Internal function which doesn't alter any stage or read any data
     * Used to compare the string operations. Little costly in terms of gas fee
     * @param a string-1 that is to be compared
     * @param b string-2 that is to be compared
     * @return boolean value to say if both strings matched or not
     */
    function compareStrings(string memory a, string memory b)
        internal
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }

    /**
     * @notice Internal function to remove element from a string array
     * Having element at the provided index
     * @param data string array in which we have to iterate
     * @param index index where the element is present
     * @return string array after removing the element
     */
    function removeElement(string[] memory data, int256 index)
        internal
        pure
        returns (string[] memory)
    {
        // string[] memory updatedData_ = new string[](data.length - 1);
        require(uint256(index) < data.length, "Index out of bound");
        for (uint256 i = uint256(index); i < data.length - 1; i++) {
            data[i] = data[i + 1];
        }
        delete data[data.length - 1];
        if (data.length > 0) {
            // Make sure this assembly code never runs when list.length == 0 (don't allow the array length to underflow)
            // Don't try to use this to increase the size of an array (by replacing sub with add)
            // Only use it on variables with a type like ...[] memory (for example, don't use it on a address[10] memory or address)

            // To reduce the length of array by one
            assembly {
                mstore(data, sub(mload(data), 1))
            }
        } else delete data;

        return data;
    }

    /**
     * @notice Internal function used to split string using any delimiter
     * @param str string value that need to be splitted
     * @param delimiter delimiter
     * @return array of strings after splitting
     */
    function substring(string memory str, string memory delimiter)
        internal
        pure
        returns (string[] memory)
    {
        Strings.slice memory s = str.toSlice();
        Strings.slice memory delim = delimiter.toSlice();
        string[] memory parts = new string[](s.count(delim));
        for (uint256 i = 0; i < parts.length; i++) {
            parts[i] = s.split(delim).toString();
        }

        return parts;
    }
}
