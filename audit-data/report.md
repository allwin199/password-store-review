---
title: Protocol Audit Report
author: Prince Allwin
date: February 10, 2024
header-includes:
  - \usepackage{titling}
  - \usepackage{graphicx}
---

\begin{titlepage}
    \centering
    \begin{figure}[h]
        \centering
    \end{figure}
    \vspace*{2cm}
    {\Huge\bfseries Protocol Audit Report\par}
    \vspace{1cm}
    {\Large Version 1.0\par}
    \vspace{2cm}
    {\Large\itshape Prince Allwin\par}
    \vfill
    {\large \today\par}
\end{titlepage}

\maketitle

<!-- Your report starts here! -->

Prepared by: [Prince Allwin]()
Lead Security Researches: 
- Prince Allwin

# Table of Contents
- [Table of Contents](#table-of-contents)
- [Protocol Summary](#protocol-summary)
- [Disclaimer](#disclaimer)
- [Risk Classification](#risk-classification)
- [Audit Details](#audit-details)
  - [Scope](#scope)
  - [Roles](#roles)
- [Executive Summary](#executive-summary)
  - [Issues found](#issues-found)
- [Findings](#findings)
  - [High](#high)
    - [\[H-1\] Storing the password on-chain make it is visible to anyone. and no longer private.](#h-1-storing-the-password-on-chain-make-it-is-visible-to-anyone-and-no-longer-private)
    - [\[H-2\] `PasswordStore::setPassword` has no access controls, meaning a non-owner could change the password.](#h-2-passwordstoresetpassword-has-no-access-controls-meaning-a-non-owner-could-change-the-password)
      - [Likelihood \& Impact:](#likelihood--impact)
  - [Informational](#informational)
    - [\[I-1\] The `PasswordStore::getPassword` natspec indicates a parameter that dosen't exist, causing the natspec to be incorrect.](#i-1-the-passwordstoregetpassword-natspec-indicates-a-parameter-that-dosent-exist-causing-the-natspec-to-be-incorrect)
      - [Likelihood \& Impact:](#likelihood--impact-1)

# Protocol Summary

A smart contract applicatin for storing a password. Users should be able to store a password and then retrieve it later. Others should not be able to access the password. 

# Disclaimer

Prince Allwin and team makes all effort to find as many vulnerabilities in the code in the given time period, but holds no responsibilities for the findings provided in this document. A security audit by the team is not an endorsement of the underlying business or product. The audit was time-boxed and the review of the code was solely on the security aspects of the Solidity implementation of the contracts.

# Risk Classification

|            |        | Impact |        |     |
| ---------- | ------ | ------ | ------ | --- |
|            |        | High   | Medium | Low |
|            | High   | H      | H/M    | M   |
| Likelihood | Medium | H/M    | M      | M/L |
|            | Low    | M      | M/L    | L   |

We use the [CodeHawks](https://docs.codehawks.com/hawks-auditors/how-to-evaluate-a-finding-severity) severity matrix to determine severity. See the documentation for more details.

# Audit Details 

Commit Hash:
```
7d55682ddc4301a7b13ae9413095feffd9924566
```

## Scope 

./src/
#-- PasswordStore.sol

## Roles

- Owner: The user who can set the password and read the password.
- Outsiders: No one else should be able to set or read the password.

# Executive Summary

## Issues found

| Severity | Number of issues found |
| -------- | ---------------------- |
| High     | 2                      |
| Medium   | 0                      |
| Low      | 0                      |
| Info     | 1                      |
| ---      | ---                    |
| Total    | 3                      |


# Findings

## High

### [H-1] Storing the password on-chain make it is visible to anyone. and no longer private.

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


---

### [H-2] `PasswordStore::setPassword` has no access controls, meaning a non-owner could change the password.

**Description:** The `PasswordStore::setPassword` function is set to be an `external` function, however, the natspec of the function and overall purpose of the smart contract is that `This function allows only the owner to set a new password.`

```js
    function setPassword(string memory newPassword) external {
@>      // @audit There are no access controls
        s_password = newPassword;
        emit SetNetPassword();
    }
```

**Impact:** Anyone can set/change the password of the contract, severly breaking the contract intended functionality.

**Proof of Concept:** Add the following to the `PasswordStore.t.sol` test file

<details>
<summary>Code</summary>

```js
    function test_Fuzz_Anyone_Can_Set_Password(address randomAddress) public {
        vm.assume(randomAddress != owner);

        string memory newPassword = "newPassword";
        vm.startPrank(randomAddress);
        passwordStore.setPassword(newPassword);
        vm.stopPrank();

        vm.startPrank(owner);
        string memory currentPassword = passwordStore.getPassword();
        vm.stopPrank();

        assertEq(currentPassword, newPassword);
    }
```

</details>

**Recommended Mitigation:** Add an access control conditional to the `setPassword` function.

```js
    if(msg.sender != s_owner){
        revert PasswordStore__NotOwner();
    }
```

#### Likelihood & Impact:

-   Impact : HIGH
-   Likelihood: HIGH
-   Severity: HIGH

---

## Informational

### [I-1] The `PasswordStore::getPassword` natspec indicates a parameter that dosen't exist, causing the natspec to be incorrect.

**Description:** The `PasswordStore::getPassword` function signature is `getPassword()` while the natspec says it should be `getPassword(string)`.

**Impact:** The natspec is incorrect.

**Recommended Mitigation:** Remove the incorrect the natspec line.

```diff
-    * @param newPassword The new password to set.
```

#### Likelihood & Impact:

-   Impact : NONE
-   Likelihood: HIGH
-   Severity: Informational/Gas/Non-crits
