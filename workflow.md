# DairyTrace User Roles and Testing Workflow

This document outlines the different user roles in the DairyTrace system, their capabilities, and a step-by-step workflow to test the entire application lifecycle from farm collection to consumer traceability.

---

## 👥 User Roles and Capabilities

The system supports four distinct types of interactions, governed by Role-Based Access Control (RBAC):

### 1. System Admin (`admin`)
*The superuser managing the entire ecosystem.*
- **Dashboard**: Views high-level aggregate statistics (total batches, daily volume, rejection trends, active alerts).
- **User Management**: Can create and manage other users (`collection_staff` and `distributor`).
- **Global Oversight**: Can read and manage all collection centres, distributor organizations, farms, batches, and deliveries across the entire system.
- **Alert Management**: Can view and resolve all system, quality, and delivery alerts.

### 2. Collection Staff (`collection_staff`)
*Operators working at a specific Milk Collection Centre.*
- **Dashboard**: Views stats specific to their assigned collection centre.
- **Farm Management**: Can register new farms and view existing farms within their centre.
- **Batch Management**: Can create new milk batches when milk is collected from a farm.
- **Processing & Quality**: Can update the processing stage of a batch (e.g., chilling, pasteurization) and log quality check results (Fat %, SNF %, Temperature).
- **Alerts**: Receives and views alerts (e.g., temperature warnings or quality failures) specifically tied to their collection centre.

### 3. Distributor (`distributor`)
*Logistics partners handling the transport and delivery of processed milk.*
- **Dashboard**: Views deliveries assigned to their specific distributor organisation.
- **Delivery Tracking**: Can track assigned deliveries and update delivery statuses (e.g., `picked_up`, `in_transit`, `delivered`).
- **Batch Visibility**: Has read-only access to the details and quality checks of the specific batches they are transporting.
- **Alerts**: Receives alerts related to delays or issues with their assigned deliveries.

### 4. Consumer / Public (`customer`)
*End consumers who buy the milk product.*
- **No Login Required**: Accesses the public-facing side of the app.
- **QR Scanning**: Can use the `/scan` screen to scan a QR code on a milk bottle.
- **Traceability**: Views the complete "Journey Timeline" of the batch, verifying its origin (farm), processing stages, quality test results, and delivery history.

---

## 🧪 Detailed End-to-End Testing Flow

To fully test the application, you need to simulate the lifecycle of a milk batch passing through the hands of each user role.

### Phase 1: Admin Setup
1. **Login as Admin**: Open the app and log in with your Admin credentials (e.g., `admin@dairytrace.com`).
2. **Review Dashboard**: Check the Admin Dashboard to ensure stats are loading correctly.
3. **Create Staff User**: Navigate to **Users** -> **Create User**.
   - Create a user with the role **COLLECTION_STAFF**.
   - Assign them to an existing Collection Centre (e.g., "South Hill Center").
4. **Create Distributor User**: Create another user with the role **DISTRIBUTOR**.
   - Assign them to an existing Distributor Organisation.
5. **Logout**.

### Phase 2: Farm & Collection (Collection Staff)
1. **Login as Staff**: Log in with the newly created Collection Staff credentials.
2. **Register a Farm**: Navigate to **Farms** -> **Add New Farm**. Fill in the details (Farm Code, Owner Name, Location).
3. **Receive Milk (Create Batch)**: Navigate to **Batches** -> **Create Batch**.
   - Select the farm you just created.
   - Enter the quantity (e.g., 500 Liters).
   - *This generates a unique Batch ID and Public Token.*
4. **Log a Quality Check**: Go to the Batch Details and perform a Quality Check for the `collection` stage.
   - *Test Scenario A (Pass)*: Enter valid metrics (e.g., Fat: 4.5%, SNF: 8.5%, Temp: 4°C). The batch should be marked as `accepted`.
   - *Test Scenario B (Fail/Alert)*: Enter failing metrics (e.g., Temp: 12°C). The system should automatically generate a `temperature_warning` alert.
5. **Update Stages**: Update the batch stage from `collection` -> `chilling` -> `processing` -> `packaging`.
6. **Logout**.

### Phase 3: Logistics (Distributor)
1. **Login as Distributor**: Log in using the Distributor credentials.
2. **View Deliveries**: Navigate to the Distributor Dashboard. You should see deliveries assigned to your organisation (if batches were marked for distribution).
3. **Update Delivery Status**: Select a pending delivery and update its status to `picked_up`, then `in_transit`, and finally `delivered`.
4. **Logout**.

### Phase 4: Consumer Verification (Public Trace)
1. **Open Public App**: Without logging in, navigate to the `/scan` screen (or click "Scan QR Code" from the Welcome screen).
2. **Enter Token / Scan**: Either scan a generated QR code (you can find the QR code in the Collection Staff's Batch Details screen) or manually enter the batch's `public_token` if testing on an emulator.
3. **View the Journey**: 
   - Verify that the consumer can see the Origin Farm.
   - Verify that the timeline accurately reflects the exact times the Staff updated the stages.
   - Verify that the Quality Check status (Passed) is visible to the consumer, assuring them of product safety.

> [!TIP]
> If you encounter `Permission Denied` errors during Phase 1, ensure you have run the Admin bootstrap SQL script in your Supabase SQL Editor as discussed previously!
