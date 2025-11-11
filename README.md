## 🏡 LandRegistryNFT Smart Contract

The **LandRegistryNFT** smart contract aims to solve **land ownership fraud, corruption, and record tampering** in Kenya’s traditional land registration system.  
It turns every land parcel into a **unique NFT (token)** on the blockchain.  

Each NFT permanently records the parcel’s details — including **LR number, county, coordinates, owner ID hash, and registration date** — making it **tamper-proof** and **publicly verifiable**.

---

### ⚙️ Overview
This basic land registry smart contract (`LandRegistryNFT`) is deployed on the **Sepolia Test Network** and models each land parcel as an **ERC-721 NFT**.

---

### 🔑 Role-Based Control
- **`DEFAULT_ADMIN_ROLE`** – The initial ministry admin; can manage registrar accounts.  
- **`REGISTRAR_ROLE`** – Authorized officers who can register or update parcels.

---

### 🧾 Register Parcel
- `registerParcel(...)` mints a new NFT (tokenId 1, 2, 3, …).  
- Stores parcel metadata:
  - `lrNumber`  
  - `county`  
  - `coordinatesHash` (e.g. IPFS/survey data)  
  - `ownerIdHash` (hashed ID/KRA)  
  - `registeredAt`  
  - Sets `status` to **Active**

---

### 🔍 View Parcel
- `getParcel(tokenId)` → Returns current metadata and owner.  
- `getParcelDocuments(tokenId)` → Returns attached document hashes.

---

### 🛠️ Manage Parcel
- `setParcelStatus(tokenId, newStatus, reason)` → Change parcel status (**Active / Disputed / Frozen / Revoked**).  
- `addParcelDocument(tokenId, docHash)` → Attach supporting documents (e.g. title scans, court orders).  
- `updateParcelMetadata(...)` → Update survey or owner ID hash under registrar authority.

---

### 🔁 Transfer Ownership
- `safeTransferParcel(tokenId, to)`  
  Allows the **current owner** (when parcel is *Active*) to transfer the parcel on-chain.  
  Emits a `ParcelTransferred` event to record the change of ownership.

---

**Contract Address (Sepolia):**  
[`0xB875e8004eb3B757a0Fd3610B49085a1f1260aD9`](https://sepolia.etherscan.io/address/0xB875e8004eb3B757a0Fd3610B49085a1f1260aD9)
