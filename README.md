# ChainProof — On-Chain Credential System

**FEC Money Matrix | Developer Track | Freshers Recruitment 2026-27**

---

## What This Is

ChainProof is a Solidity smart contract that implements a non-transferable, on-chain credential system for communities. It solves a real problem: people who contribute meaningfully over time have no tamper-proof way to prove it. This contract lets an admin issue verifiable credentials to wallet addresses, computes a trust score from those credentials, and gates access to a function based on that score.

---

## Contract Features

- Admin-only credential issuance with title, level (1/2/3), and timestamp
- Unlimited credentials per wallet address
- Public lookup of any address's full credential history
- Trust score formula: **Σ(level² × 10) + (count × 5)**
- `accessGranted()` gate that reverts with a reason if score is below threshold
- Duplicate credential rejection — same title cannot be issued twice to the same address
- Architecturally non-transferable — no transfer mechanism exists in the contract

---

## Trust Score Formula

```
score = Σ(level² × 10) + (totalCredentials × 5)
```

| Level | Points per Credential |
|-------|-----------------------|
| 1 — Basic | 10 pts |
| 2 — Intermediate | 40 pts |
| 3 — Advanced | 90 pts |

Plus **5 pts** per distinct credential earned (count bonus).

Quadratic scaling ensures advanced contributions are disproportionately rewarded over basic ones. The count bonus rewards sustained engagement without dominating the score. Access threshold is set at **50 points**.

---

## Design Decisions

### Duplicate Handling — Reject
If the admin tries to issue the same credential title to the same address twice, the transaction reverts. A credential title represents a unique achievement. Allowing duplicates would let a malicious admin inflate a friend's trust score by reissuing the same badge repeatedly.

### Non-Transferability — Architectural
Credentials are stored in a `mapping(address => Credential[])` with no transfer, approve, or move function anywhere in the contract. Once issued to an address, a credential is permanently bound to it. Trust scores reflect identity, not wallet purchases.

---

## How to Run

1. Open [remix.ethereum.org](https://remix.ethereum.org)
2. Create a new file `ChainProof.sol` and paste the contract
3. Compile with Solidity `^0.8.20`
4. Deploy on **Remix VM (Cancun)**
5. Use the deployer account as admin to call `issueCredential()`
6. Switch to a member account and call `accessGranted()` to test pass and fail cases

---

## Screenshots

| File | Description |
|------|-------------|
| `success.png` | `accessGranted()` returning `true` after sufficient credentials issued |
| `revert.png` | `accessGranted()` reverting with reason when trust score is below threshold |

---

## Files

```
ChainProof.sol       — main contract with inline design comments
success.png          — successful accessGranted() call
revert.png           — failed accessGranted() call with revert message
README.md            — this file
```

---

## Sample Trust Score Calculation

| Credential | Level | Points |
|------------|-------|--------|
| Completed BlockBase | 2 | 40 |
| Led Workshop | 1 | 10 |
| — | — | + 2 × 5 = 10 (count bonus) |
| **Total** | | **60 pts ✅ Access Granted** |

---

*Built for FEC Freshers Recruitment 2026-27 — Money Matrix, Developer Track.*
