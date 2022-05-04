// SPDX-License-Identifier: GPL-3.0
pragma experimental ABIEncoderV2;
pragma solidity >=0.4.25 <0.9.0;

import "./Types.sol";
import "./Helpers.sol";

// fd = folder
// fl = file

/**
 * @title Dropbox
 * @author Suresh Konakanchi
 * @dev Library for managing user stoarge. Dropbox in de-centralised system
 */
contract Dropbox {
    address admin;
    mapping(string => Types.Folder) folders;
    mapping(string => Types.File) files;
    mapping(address => Types.User) users; // User object which will have the limit of storage, current plan etc.
    mapping(address => string[]) sharedFiles; // All files that were shared with an user
    mapping(string => string[]) userData; // All files & folders that an user has uploaded

    event FolderAdded(address addedBy, string path, string folderId);
    event FolderRemoved(address removedBy, string path, string folderId);
    event FileUploaded(address addedBy, string path, string fileId);
    event FileUploadFailed(address addedBy, string path, string fileId);
    event FileRemoved(address removedBy, string path, string fileId);
    event FilePermissionAdded(address addedTo, string path, string fileId);
    event FilePermissionRemoved(address removedTo, string path, string fileId);

    /**
     * @notice Set admin to one who deploy this contract
     */
    constructor() {
        admin = msg.sender;
    }

    // Contract Functions

    /**
     * @notice To fetch all the avilable files / folders in the respective user dropbox
     * UnderScore (_) won't be allowed in the name of the folder
     * @dev Send the path where user want to fetch data
     * @param pageNumber page number for which data is needed (1..2..3....n)
     * @param path_ Folder Path where user need data
     * @return totalPages Total pages available
     * @return List of file / folder Id's
     */
    function getData(uint256 pageNumber, string memory path_)
        public
        view
        returns (uint256 totalPages, string[] memory)
    {
        require(pageNumber > 0, "PN should be > 0");
        string[] memory data_ = userData[path_];
        (
            uint256 pages,
            uint256 pageLength_,
            uint256 startIndex_,
            uint256 endIndex_
        ) = Helpers.getIndexes(pageNumber, data_);

        string[] memory userData_ = new string[](pageLength_);
        for (uint256 i = startIndex_; i < endIndex_; i++)
            userData_[i] = data_[i];
        return (pages, userData_);
    }

    /**
     * @notice To fetch all the shared files in the respective user dropbox
     * @param pageNumber page number for which data is needed (1..2..3....n)
     * @return totalPages Total pages available
     * @return List of file Id's
     */
    function getSharedData(uint256 pageNumber)
        public
        view
        returns (uint256 totalPages, string[] memory)
    {
        require(pageNumber > 0, "PN should be > 0");
        string[] memory data_ = sharedFiles[msg.sender];
        (
            uint256 pages,
            uint256 pageLength_,
            uint256 startIndex_,
            uint256 endIndex_
        ) = Helpers.getIndexes(pageNumber, data_);

        string[] memory sData_ = new string[](pageLength_);
        for (uint256 i = startIndex_; i < endIndex_; i++) sData_[i] = data_[i];
        return (pages, sData_);
    }

    /**
     * @notice To fetch single file details
     * @dev Send the file ID
     * @param fileId_ Id of the file
     * @return File object
     */
    function getSingleFile(string memory fileId_)
        public
        view
        returns (Types.File memory)
    {
        assert(isValid(fileId_, "fl"));
        return files[fileId_];
    }

    /**
     * @notice To fetch the current logged-in user's profile
     * @dev User's metamask Id will be automatically sent in "msg" object
     * @return User's object
     */
    function getUserProfile() public view returns (Types.User memory) {
        require(msg.sender != address(0), "Address is empty");
        return users[msg.sender];
    }

    /**
     * @notice To add a new user to the system
     * @dev Send user's email & name, Default stroage limits will be added
     * @param name_ Name of the user
     * @param email_ Email of the user
     */
    function addUser(string memory name_, string memory email_) public {
        require(msg.sender != address(0), "Address is empty");
        users[msg.sender] = Types.User({
            name: name_,
            email: email_,
            id_: msg.sender,
            storageAllocated: uint256(2000), // 2GB in MB's
            storageUsed: 0, // In MB's
            storageFree: uint256(2000) // In MB's
        });
    }

    /**
     * @notice To add / remove a folder in the respective user dropbox
     * UnderScore (_) won't be allowed in the name of the folder
     * @dev Take the path where user is adding / removing the folder
     * It will be user's metamask address if adding / removing at root level
     * @param path_ Path where user is adding / removing folder
     * @param folder_ Folder object
     * @param isToAdd_ Is the call for adding new folder or to remove existing folder
     */
    function addRemoveFolder(
        string memory path_,
        Types.Folder memory folder_,
        bool isToAdd_
    ) public {
        assert(isValid(folder_.id, "fd"));
        string[] memory data_ = userData[path_];
        int256 matchIndex_ = getMatchIndex(data_, folder_.id);

        if (isToAdd_) {
            require(matchIndex_ == -1, "Already existing");
            userData[path_].push(folder_.id);
            folders[folder_.id] = folder_;
            emit FolderAdded(msg.sender, path_, folder_.id);
        } else {
            require(matchIndex_ != -1, "Not existing");
            require(
                folders[data_[uint256(matchIndex_)]].createdBy == msg.sender,
                "Only owner can delete"
            );
            userData[path_] = Helpers.removeElement(data_, matchIndex_);
            string memory pathName_ = string(
                abi.encodePacked(path_, "/", folder_.id)
            );
            delete userData[pathName_];
            delete folders[folder_.id];
            emit FolderRemoved(msg.sender, path_, folder_.id);
        }
    }

    /**
     * @notice To add a new file in the respective user dropbox
     * UnderScore (_) won't be allowed in the name of the file
     * @dev Take the path where user is adding the new file
     * It will be user's metamask address if adding at root level
     * @param path_ Path where user is adding the file
     * @param files_ Array of File objects that need to be added
     */
    function addFiles(string memory path_, Types.File[] memory files_) public {
        uint256 failureCount_ = 0;
        for (uint256 i = 0; i < files_.length; i++) {
            Types.File memory file_ = files_[i];
            Types.User memory user_ = users[msg.sender];
            require(user_.storageFree >= file_.fileSize);

            if (isValid(file_.id, "fl")) {
                string[] memory data_ = userData[path_];
                int256 matchIndex_ = getMatchIndex(data_, file_.id);
                require(matchIndex_ == -1, "Already existing");
                userData[path_].push(file_.id);
                files[file_.id] = file_;
                emit FileUploaded(msg.sender, path_, file_.id);

                // Updating the storage availabilities
                users[msg.sender].storageUsed = (user_.storageUsed +
                    file_.fileSize);
                users[msg.sender].storageFree = (user_.storageFree -
                    file_.fileSize);
            } else {
                failureCount_++;
                emit FileUploadFailed(msg.sender, path_, file_.id);
            }
        }

        if (failureCount_ == files_.length) revert("Wrong file, format");
    }

    /**
     * @notice To remove an existing file in the respective user dropbox
     * UnderScore (_) won't be allowed in the name of the file
     * @dev Take the path where user wish to remove the file
     * It will be user's metamask address if removing at root level
     * @param path_ Path where user is trying to remove the file
     * @param fileId_ Id of the File that need to be removed
     */
    function removeFile(string memory path_, string memory fileId_) public {
        Types.File memory fileObj_ = files[fileId_];
        string[] memory data_ = userData[path_];

        (bool exists_, int256 matchIndex_) = isFileExists(data_, fileId_);
        require(exists_, "File not found");
        userData[path_] = Helpers.removeElement(data_, matchIndex_);
        delete files[fileId_];
        emit FileRemoved(msg.sender, path_, fileId_);

        // Updating the storage availabilities
        Types.User memory user_ = users[msg.sender];
        users[msg.sender].storageUsed = (user_.storageUsed - fileObj_.fileSize);
        users[msg.sender].storageFree = (user_.storageFree + fileObj_.fileSize);
    }

    /**
     * @notice To make a file accessible by public with a sharable link
     * @dev Send the file ID & the current folder path
     * @param path_ Folder Path where the file is existing
     * @param fileId_ Id of the file
     */
    function togglePublicLink(string memory path_, string memory fileId_)
        public
    {
        (bool exists_, ) = isFileExists(userData[path_], fileId_);
        require(exists_, "File not found");
        bool access_ = files[fileId_].canPublicAccess;
        files[fileId_].canPublicAccess = !access_;
    }

    /**
     * @notice To make a file accessible by public with a sharable link
     * @dev Send the file ID & the current folder path
     * @param path_ Folder Path where the file is existing
     * @param fileId_ Id of the file
     * @param to_ Receiver's metamask address
     * @param isToRemove_ Is to remove file permission or to add permission
     */
    function filePermission(
        string memory path_,
        string memory fileId_,
        address to_,
        bool isToRemove_
    ) public {
        require(to_ != address(0), "Address is invalid");
        string[] memory data_ = sharedFiles[to_];
        (bool exists_, int256 matchIndex_) = isFileExists(data_, fileId_);
        if (isToRemove_) {
            require(exists_, "File not found");
            sharedFiles[to_] = Helpers.removeElement(data_, matchIndex_);
            emit FilePermissionRemoved(to_, path_, fileId_);
        } else {
            require(!exists_, "File exists");
            sharedFiles[to_].push(fileId_);
            emit FilePermissionAdded(to_, path_, fileId_);
        }
    }

    // Internal Functions

    /**
     * @notice Modifier to check for file existance
     * @param data_ Array of File / Folder Ids
     * @param file_ File ID
     * @return File exists or not & matchIndex if exists
     */
    function isFileExists(string[] memory data_, string memory file_)
        internal
        view
        returns (bool, int256)
    {
        assert(isValid(file_, "fl"));
        int256 matchIndex_ = getMatchIndex(data_, file_);
        if (
            matchIndex_ != -1 &&
            files[data_[uint256(matchIndex_)]].uploadedBY == msg.sender
        ) return (true, matchIndex_);
        else return (false, matchIndex_);
    }

    /**
     * @notice Checks if the file / folder id is in required format or not
     * @dev For folder it starts with "fd" & for file it starts with "fl"
     * @param id_ Id of the file / folder
     * @param prefix_ Prefixed that is expected
     * @return Returns true if all required conditions were met
     */
    function isValid(string memory id_, string memory prefix_)
        internal
        pure
        returns (bool)
    {
        require(Helpers.substring(id_, " ").length == 0, "Spaces in name");
        string[] memory subStrings_ = Helpers.substring(id_, "_");
        require(subStrings_.length > 0, "Not in req format");
        require(Helpers.compareStrings(subStrings_[0], prefix_), "Not a file");
        return true;
    }

    /**
     * @notice Checks wether the file / folder id is present in the list or not
     * @param data_ Array of strings that were present in the respective path
     * @param id_ Id of the file / folder
     * @return Returns index value if match found otherwise returns -1
     */
    function getMatchIndex(string[] memory data_, string memory id_)
        internal
        pure
        returns (int256)
    {
        int256 matchIndex_ = -1;
        for (int256 i = 0; i < int256(data_.length); i++) {
            if (Helpers.compareStrings(id_, data_[uint256(i)])) {
                matchIndex_ = i;
                break;
            }
        }
        return matchIndex_;
    }
}
