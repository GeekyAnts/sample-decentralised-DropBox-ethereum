[![Donate Bitcoin](https://img.shields.io/badge/donate-bitcoin-orange.svg)](https://nrobinson2000.github.io/donate-bitcoin/?address=0xce99a1283BEB509b7a5F29BA91d6f6Ef9E2f673C&amount=5&currency=USD&qrcode=true&link=true&name=Suresh&mbits=false)

## Important Links

1. [Contract Address](https://rinkeby.etherscan.io/address/0x1806421c12C8162687478dC451f07a745F6a65E4)<br />
2. [Contract Creator](https://rinkeby.etherscan.io/address/0x910a91e4B4c9E4d41e81f38df169836C4f466303)<br />
3. [Tx Hash of contract creation](https://rinkeby.etherscan.io/tx/0xad26afe0cbbe6d4eabe6110065ff0264b44ecef0e9765edc3731d739fb655fa1)<br />

## Decentralised Dropbox

This is just an idea (Smart Contract) of how the dropbox will be implemented in decentralised storage.

### Features

- One can create / remove folders dynamically.
- Drag & drop for multi file upload. Also supports single file upload.
- One can also delete any file at any point of time
- Provide / Remove permission to a specific file, to specific person(s) based on the(ir) metamask address
- We can also generate the public link for a file & can also disable the public link.
- For enterprise usecase, we have also defined storage limits & alowing user's to upload only if they have limit left in their account.

### Required:

- Metamask for all Users who use the system
- Smart Contract consisting of all the rules and protocols required for Dropbox.
- Blockchain Network to deploy the Contract. We have used Rinkeby for our contract.
- Website for user's Interface where Users can play around with all the files, folders, permisisons.

### Implementation of Dropbox:

- We would be need IPFS (De-centralised file storage system) at front-end.
- We will upload all our Documents, Images, Videos, Files & Data to IPFS & we will get datahash after successful updation.
- We will use this data hash & our metamask address to secure everything.
- Now user's can interact with our smart contract methods to add remove files & folders or to grant / remove permissions etc.

# Let's start with Dropbox Smart Contracts

[Do platform Setup! ](SETUP.md)

## Solidity

### Dropbox Objects

```c++
    // We will use this in future in order to render thumbnail or preview based on the file type
    enum FileType {
        Image, // jpg,jpeg,gif,svg,png,tiff,tif
        Video, // mp4,avi,mov,flv,avchd
        Audio, // m4a,mp3,wav
        Document, // pdf,docx,csv,txt,rtf,odt,epub,xlsx,xls,html
        Presentation, // pptx,ppt,odp,key
        Other // Any other type
    }

    // To add storage restrictions
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
        string id; // fd_metamaskid_folder_name
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

    // NOTE: No Underscore(_) is allowed either in file name or in folder name
```

### Dropbox functions list

| **Function Name**  | **Input Params**                          | **Return value**            | **Description**                                                     |
| ------------------ | ----------------------------------------- | --------------------------- | ------------------------------------------------------------------- |
| getUserProfile()   | -                                         | User                        | To get the details of current logged-in user                        |
| addUser()          | name*,<br>email*                          | -                           | To add new user to system with default storage rights               |
| getData()          | pageNUmber,<br>path\_                     | totalPages,<br>userData\_[] | To fetch folders & files in the provided path as pages              |
| getSharedData()    | pageNumber                                | totalPages,<br>userData\_[] | To fetch the data which is shared by other users as pages           |
| getSingleFile()    | fileId\_                                  | File                        | Send ID of the file to fetch the complete details of it             |
| addRemoveFolder()  | path*,<br>folder*,<br>isToAdd\_           | -                           | To add a new folder or to remove any existing folder                |
| addFiles()         | path*,<br>file*[]                         | -                           | To add single / multiple files to specified path                    |
| removeFile()       | path*,<br>fileId*                         | -                           | To remove a file with provided Id at provided path                  |
| togglePublicLink() | path*,<br>fileId*                         | -                           | To generate public link & to disable public link                    |
| filePermission()   | path*,<br>fileId*,<br>to*,<br>isToRemove* | -                           | To add / remove user's to the permission list of the specified file |

### Events

| **Event Name**        | **Params**                      | **Description**                                             |
| --------------------- | ------------------------------- | ----------------------------------------------------------- |
| FolderAdded           | addedBy,<br>path,<br>folderId   | Triggers when someone adds a folder to a particular path    |
| FolderRemoved         | removedBy,<br>path,<br>folderId | Triggers when someone removes a folder at a particular path |
| FileUploaded          | addedBy,<br>path,<br>fileId     | Triggers when a file successfully gets added                |
| FileUploadFailed      | addedBy,<br>path,<br>fileId     | Triggers when a file upload fails                           |
| FileRemoved           | removedBy,<br>path,<br>fileId   | Triggers when a file gets removed                           |
| FilePermissionAdded   | addedTo,<br>path,<br>fileId     | Triggers when a file is shared to someone                   |
| FilePermissionRemoved | removedTo,<br>path,<br>fileId   | Triggers when a file permission is removed                  |

### Versions

Compiler: solc: 0.8.12+commit.f00d7308

Truffle: v5.5.2

Node: v14.17.0

### Quick Start

1.  cd into project repro

        cd sample-decentralised-DropBox-ethereum

2.  download node libraries

        npm install

3.  Download/Start ganache

https://truffleframework.com/ganache

4.  Compiling contracts

        truffle compile

5.  Migrating to ganache

_Note depending on ganache cli/ui you my need to change truffle.js port settings Current listing on port : 7545_

        truffle migrate --network development  --reset --all

6.  Testing on ganache

        truffle test

7.  Migrating to Rinkeby

_Note Change truffle settings to your Contract Creator address within the "from" rinkeby configuration_

        truffle migrate --network rinkeby  --reset --all

## Team ✨

Meet the amazing team who developed this project.

<table>
  <tr>
    <td align="center"><a href="https://in.linkedin.com/in/sur950"><img src="https://avatars.githubusercontent.com/u/46712434?v=4" width="100px;" alt=""/><br /><sub><b>Suresh Konakanchi</b></sub></a><br /><a href="https://github.com/GeekyAnts/sample-e-voting-system-ethereum" title="Code">💻</a> <a href="https://geekyants.github.io/sample-e-voting-system-ethereum/" title="Documentation">📖</a> <a href="https://github.com/GeekyAnts/sample-e-voting-system-ethereum/issues" title="Maintenance">🚧</a></td>
    <td align="center"><a href="https://twitter.com/95pushkar"><img src="https://avatars.githubusercontent.com/u/41522922?v=4" width="100px;" alt=""/><br /><sub><b>Pushkar Kumar</b></sub></a><br /><a href="https://github.com/GeekyAnts/sample-e-voting-system-ethereum" title="Code">💻</a> <a href="https://geekyants.github.io/sample-e-voting-system-ethereum/" title="Documentation">📖</a> <a href="https://github.com/GeekyAnts/sample-e-voting-system-ethereum/issues" title="Maintenance">🚧</a></td>
    <td align="center"><a href="https://twitter.com/ruchikaSjv"><img src="https://avatars.githubusercontent.com/u/32259133?v=4" width="100px;" alt=""/><br /><sub><b>Ruchika Gupta</b></sub></a><br /><a href="https://github.com/GeekyAnts/sample-e-voting-system-ethereum" title="Code">💻</a> <a href="https://geekyants.github.io/sample-e-voting-system-ethereum/" title="Documentation">📖</a> <a href="https://github.com/GeekyAnts/sample-e-voting-system-ethereum/issues" title="Maintenance">🚧</a></td>
  </tr>
  </table>
