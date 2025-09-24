StackVault – Secure Treasury Smart Contract

StackVault is a **Clarity smart contract** for the [Stacks](https://stacks.org/) blockchain  
that provides a **secure on-chain treasury** for storing and managing STX tokens.  
It enables **open deposits**, **controlled withdrawals**, and **transparent balance tracking**,  
making it ideal for DAOs, community treasuries, and multi-party project funds.

---

Features
- **Open Deposits** – Anyone can send STX into the vault contract.
- **Authorized Withdrawals** – Only approved signers can withdraw funds.
- **Real-Time Tracking** – Maintains the total vault balance on-chain.
- **Transparent Queries** – Exposes read-only functions for balances and authorized signers.

---

Project Structure
- contracts
- stack-vault.clar 
- Main Clarity smart contract
- tests
- stack-vault_test.ts  
- Clarinet.toml 
- Clarinet unit tests
  
