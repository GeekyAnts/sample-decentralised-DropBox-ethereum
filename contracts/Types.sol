// SPDX-License-Identifier: GPL-3.0
pragma experimental ABIEncoderV2;
pragma solidity >=0.4.25 <0.9.0;

/**
 * @title Types
 * @author Suresh Konakanchi
 * @dev Library for managing all custom types that were used in KYC process
 */
library Types {
    enum FileType {
        Image, // jpg,jpeg,gif,svg,png,tiff,tif
        Video, // mp4,avi,mov,flv,avchd
        Audio, // m4a,mp3,wav
        Document, // pdf,docx,csv,txt,rtf,odt,epub,xlsx,xls,html
        Presentation, // pptx,ppt,odp,key
        Other // Any other type
    }

    struct User {
        string name;
        string email;
        address id_;
        uint256 storageAllocated; // In MB
        uint256 storageUsed; // In MB
        uint256 storageFree; // In MB
    }

    struct Folder {
        string name;
        string id; // fd_metamaskid_folder-name
        address createdBy; // metamaskid
        uint256 createdOn;
    }

    struct File {
        string name; // fileName.jpg
        FileType fileType;
        uint256 uploadedOn;
        address uploadedBY;
        string fileExtension;
        string dataHash;
        string path; // outerFolderName/innerFolderName/fileName.jpg
        bool canPublicAccess; // When this file is made public access
        string id; // fl_metamaskid_name_datahash
        uint256 fileSize; // In MB
    }
}
