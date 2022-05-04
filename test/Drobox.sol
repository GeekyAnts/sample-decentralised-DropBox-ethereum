// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4.25 <0.9.0;

import "../contracts/Dropbox.sol";
import "../contracts/Types.sol";
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

contract DropboxTest {
    function addFolder() public {
        Dropbox dropboxToTest = Dropbox(DeployedAddresses.Dropbox());
        dropboxToTest.addRemoveFolder(
            "0xee3ff2c59989597D3a823771Fe5f8F7BfF3Ee79b",
            Types.Folder({
                name: "test",
                id: "fd_0xee3ff2c59989597D3a823771Fe5f8F7BfF3Ee79b_test",
                createdBy: address(msg.sender),
                createdOn: uint256(1651643762)
            }),
            true
        );

        (, string[] memory data_) = dropboxToTest.getData(
            1,
            "0xee3ff2c59989597D3a823771Fe5f8F7BfF3Ee79b"
        );
        Assert.equal(
            data_[0],
            "fd_0xee3ff2c59989597D3a823771Fe5f8F7BfF3Ee79b_test",
            "Folder isn't existing"
        );
    }

    function addSingleFile() public {
        Dropbox dropboxToTest = Dropbox(DeployedAddresses.Dropbox());
        Types.File[] memory file_ = new Types.File[](2);
        file_[0] = Types.File({
            name: "file1.png",
            fileType: Types.FileType.Image,
            uploadedOn: uint256(1651643792),
            uploadedBY: address(msg.sender),
            fileExtension: "png",
            dataHash: "asdfghjksdfguytrdn",
            path: "0xee3ff2c59989597D3a823771Fe5f8F7BfF3Ee79b/file1.png",
            canPublicAccess: false,
            id: "fl_0xee3ff2c59989597D3a823771Fe5f8F7BfF3Ee79b_file1_asdfghjksdfguytrdn",
            fileSize: uint256(0.5) // in MB
        });

        dropboxToTest.addFiles(
            "0xee3ff2c59989597D3a823771Fe5f8F7BfF3Ee79b",
            file_
        );

        (uint256 totalPages, string[] memory data_) = dropboxToTest.getData(
            1,
            "0xee3ff2c59989597D3a823771Fe5f8F7BfF3Ee79b"
        );
        Assert.equal(totalPages, 1, "Total pages shouldn't be more than one");
        Assert.equal(
            data_[0],
            "fd_0xee3ff2c59989597D3a823771Fe5f8F7BfF3Ee79b_test",
            "Folder isn't existing"
        );
    }

    function addMultipleFiles() public {
        Dropbox dropboxToTest = Dropbox(DeployedAddresses.Dropbox());
        Types.File[] memory files_ = new Types.File[](2);
        files_[0] = Types.File({
            name: "file2.jpg",
            fileType: Types.FileType.Image,
            uploadedOn: uint256(1651643999),
            uploadedBY: address(msg.sender),
            fileExtension: "jpg",
            dataHash: "hjksdsdfbnmkjhgffguytrdn",
            path: "0xee3ff2c59989597D3a823771Fe5f8F7BfF3Ee79b/test/file2.jpg",
            canPublicAccess: false,
            id: "fl_0xee3ff2c59989597D3a823771Fe5f8F7BfF3Ee79b_file2_hjksdsdfbnmkjhgffguytrdn",
            fileSize: uint256(0.2) // in MB
        });
        files_[1] = Types.File({
            name: "file3.png",
            fileType: Types.FileType.Image,
            uploadedOn: uint256(1651643992),
            uploadedBY: address(msg.sender),
            fileExtension: "png",
            dataHash: "dfaghsjkdlmf",
            path: "0xee3ff2c59989597D3a823771Fe5f8F7BfF3Ee79b/test/file3.png",
            canPublicAccess: false,
            id: "fl_0xee3ff2c59989597D3a823771Fe5f8F7BfF3Ee79b_file3_dfaghsjkdlmf",
            fileSize: uint256(1.5) // in MB
        });

        dropboxToTest.addFiles(
            "0xee3ff2c59989597D3a823771Fe5f8F7BfF3Ee79b/test",
            files_
        );

        (, string[] memory data_) = dropboxToTest.getData(
            1,
            "0xee3ff2c59989597D3a823771Fe5f8F7BfF3Ee79b/test"
        );
        Assert.equal(
            data_[0],
            "fl_0xee3ff2c59989597D3a823771Fe5f8F7BfF3Ee79b_file2_hjksdsdfbnmkjhgffguytrdn",
            "File isn't existing"
        );
    }
}
