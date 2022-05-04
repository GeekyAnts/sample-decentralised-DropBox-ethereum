const Dropbox = artifacts.require("Dropbox");

contract("Dropbox", (accounts) => {
  it("test adding folder", async () => {
    const box = await Dropbox.deployed();

    await box.addRemoveFolder(
      "0xee3ff2c59989597D3a823771Fe5f8F7BfF3Ee79b",
      {
        name: "test",
        id: "fd_0xee3ff2c59989597D3a823771Fe5f8F7BfF3Ee79b_test",
        createdBy: accounts[0],
        createdOn: 1651643762,
      },
      true
    );

    var returnData_ = await box.getData(
      1,
      "0xee3ff2c59989597D3a823771Fe5f8F7BfF3Ee79b"
    );
    var data_ = returnData_[1];

    assert.equal(
      data_[0],
      "fd_0xee3ff2c59989597D3a823771Fe5f8F7BfF3Ee79b_test",
      "Folder isn't existing"
    );
  });

  it("test adding single file", async () => {
    const box = await Dropbox.deployed();

    await box.addFiles("0xee3ff2c59989597D3a823771Fe5f8F7BfF3Ee79b", [
      {
        name: "file1.png",
        fileType: 0,
        uploadedOn: 1651643792,
        uploadedBY: accounts[0],
        fileExtension: "png",
        dataHash: "asdfghjksdfguytrdn",
        path: "0xee3ff2c59989597D3a823771Fe5f8F7BfF3Ee79b/file1.png",
        canPublicAccess: false,
        id: "fl_0xee3ff2c59989597D3a823771Fe5f8F7BfF3Ee79b_file1_asdfghjksdfguytrdn",
        fileSize: 1.2, // in MB
      },
    ]);

    var returnData_ = await box.getData(
      1,
      "0xee3ff2c59989597D3a823771Fe5f8F7BfF3Ee79b"
    );
    var data_ = returnData_[0];

    assert.equal(data_.toString(), "1", "Pages isn't Matching");
  });

  it("test adding multiple file", async () => {
    const box = await Dropbox.deployed();

    await box.addFiles("0xee3ff2c59989597D3a823771Fe5f8F7BfF3Ee79b/test", [
      {
        name: "file2.jpg",
        fileType: 0,
        uploadedOn: 1651643999,
        uploadedBY: accounts[0],
        fileExtension: "jpg",
        dataHash: "hjksdsdfbnmkjhgffguytrdn",
        path: "0xee3ff2c59989597D3a823771Fe5f8F7BfF3Ee79b/test/file2.jpg",
        canPublicAccess: false,
        id: "fl_0xee3ff2c59989597D3a823771Fe5f8F7BfF3Ee79b_file2_hjksdsdfbnmkjhgffguytrdn",
        fileSize: 0.6, // in MB
      },
      {
        name: "file3.png",
        fileType: 0,
        uploadedOn: 1651643992,
        uploadedBY: accounts[0],
        fileExtension: "png",
        dataHash: "dfaghsjkdlmf",
        path: "0xee3ff2c59989597D3a823771Fe5f8F7BfF3Ee79b/test/file3.png",
        canPublicAccess: false,
        id: "fl_0xee3ff2c59989597D3a823771Fe5f8F7BfF3Ee79b_file3_dfaghsjkdlmf",
        fileSize: 2, // in MB
      },
    ]);

    var returnData_ = await box.getData(
      1,
      "0xee3ff2c59989597D3a823771Fe5f8F7BfF3Ee79b/test"
    );
    var data_ = returnData_[1];

    assert.equal(
      data_[0],
      "fl_0xee3ff2c59989597D3a823771Fe5f8F7BfF3Ee79b_file2_hjksdsdfbnmkjhgffguytrdn",
      "File not matching"
    );
  });

  it("test getting single file", async () => {
    const instance = await Dropbox.deployed();
    var data_ = await instance.getSingleFile(
      "fl_0xee3ff2c59989597D3a823771Fe5f8F7BfF3Ee79b_file2_hjksdsdfbnmkjhgffguytrdn"
    );

    assert.equal(data_.uploadedBY, accounts[0], "Account not matching");
  });
});
