# Supabase Database Tables - DairyTrace

This document outlines the tables used in the Supabase database for the DairyTrace project and their respective purposes. The project tracks the lifecycle of dairy products through the supply chain.

## Tables

### 1. `alerts`
Used to store system-generated or user-triggered alerts. These could relate to temperature deviations, quality check failures, delayed deliveries, or other critical events in the dairy supply chain requiring immediate attention.

### 2. `app_notifications`
Used to store notifications intended for users of the DairyTrace app. This may include updates on batch statuses, assigned deliveries, system announcements, or reminders for quality checks.

### 3. `batch_documents`
Stores metadata and links to documents related to specific batches of milk or dairy products. This could include lab test results, compliance certificates, or transport manifests associated with a batch.

### 4. `batches`
The core table tracking individual batches of milk or dairy products. It likely links milk collected from various farms or collection centres into a single trackable entity that moves through processing, quality control, and distribution.

### 5. `collection_centres`
Stores information about the physical locations where milk is collected from local farms before being aggregated into batches. Details might include the centre's location, capacity, manager details, and contact information.

### 6. `deliveries`
Tracks the transportation and delivery of dairy batches. This table likely includes information such as the delivery vehicle, driver, departure/arrival times, origin, destination, and the current status of the shipment.

### 7. `distributor_organisations`
Contains details about the organizations or businesses responsible for distributing the final dairy products to retailers or consumers. 

### 8. `farms`
Stores information about the individual dairy farms that supply the milk. This would include the farm's location, owner details, capacity, and perhaps details about their livestock or certification status.

### 9. `profiles`
Used for user management, extending the default Supabase authentication users table. It likely stores app-specific user details such as name, role (e.g., farmer, driver, quality inspector, admin), organization ID, and contact information.

### 10. `quality_checks`
Logs the results of quality control tests performed on milk at various stages (e.g., at the farm, collection centre, or during processing). It would track parameters like temperature, fat content, SNF (Solid Not Fat), and the overall pass/fail status.

### 11. `quality_standards`
Defines the acceptable metrics and standards for the `quality_checks`. This table acts as a reference for what constitutes "good" quality milk, allowing the system to flag deviations automatically.

### 12. `tracking_events`
An audit log or event history table that records every significant action or state change for a batch or delivery (e.g., "Collected from Farm A", "Arrived at Processing Plant", "Quality Check Passed"). This provides the traceability aspect of DairyTrace.
