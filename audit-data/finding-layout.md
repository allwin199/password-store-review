### [S-#] Storing the password on-chain make it is visible to anyone. and no longer private.

**Description:** All data stored on-chain is visible to anyone, and can be read directly from the blockchain. The `PasswordStore::s_password` variable is intended to be a private variable and only accessed through the `PasswordStore::getPassword` function, which is intended to be only called by the owner of the contract.

We show one such method of reading any data off chain below.

**Impact:** Anyone can read the private password, severly breaking the functionality of the protocol.

**Proof of Concept:**

The below test case shows how anyone can read the password directly from the blockchain.

1. Create a locally running chain

```bash
make anvil
```

2. Deploy the contract to the chain

```bash
make deploy
```

3. Run the storage tool

```bash
cast storage <contract_name> <storage_slot>
```

```bash
cast storage 0x5FbDB2315678afecb367f032d93F642f64180aa3 1
```

We use `1` because that's the storage slot of `s_password` in the contract.

You'll get an output that looks like this:

`0x6d7950617373776f726400000000000000000000000000000000000000000014`

You can then parse that hex to a string with:

```bash
cast parse-bytes32-string 0x6d7950617373776f726400000000000000000000000000000000000000000014
```

And get an output of:

```bash
myPassword
```

**Recommended Mitigation:** Considering this, it's crucial to reconsider the contract's overall architecture. One potential approach is to encrypt the password off-chain and subsequently store the encrypted version on-chain. Users would then need to remember an additional off-chain password to decrypt it. However, it's advisable to eliminate the view function to prevent users from inadvertently transmitting a transaction with the password used for decryption.
