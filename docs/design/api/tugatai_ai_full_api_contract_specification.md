# TUGATAI AI SAAS PLATFORM
# FULL API CONTRACT SPECIFICATION DOCUMENT

---

# Prepared By
## Md. Shahriar Hossain Jihad

# Version
## Version 1.0

# API Architecture Style
## REST API + WebSocket Hybrid Architecture

# Date
## May 2026

---

# TABLE OF CONTENTS

1. API Overview
2. API Standards
3. Authentication Strategy
4. Authorization & RBAC
5. Multi-Tenant API Strategy
6. Branch Isolation Strategy
7. Standard Response Format
8. Error Handling Standards
9. Pagination, Filtering & Sorting
10. Authentication APIs
11. Tenant APIs
12. Branch APIs
13. User & RBAC APIs
14. Omnichannel Inbox APIs
15. Message APIs
16. CRM APIs
17. Booking APIs
18. Pricing Engine APIs
19. AI APIs
20. Knowledge Base APIs
21. Workflow APIs
22. Campaign APIs
23. Analytics APIs
24. Billing & Subscription APIs
25. Notification APIs
26. Upload APIs
27. Webhook APIs
28. Socket.IO Events
29. Validation Rules
30. HTTP Status Codes
31. Security Standards
32. API Best Practices
33. Future API Scalability
34. Conclusion

---

# 1. API OVERVIEW

The Tugatai AI SaaS Platform uses:

- REST APIs for business operations
- Socket.IO for realtime communication
- Webhooks for third-party integrations
- BullMQ for async processing

The API architecture is designed for:

- modular monolith scalability
- future microservice migration
- multi-tenant SaaS operations
- branch-based operations
- realtime messaging
- AI orchestration

---

# 2. API STANDARDS

## Base URL

```text
/api/v1
```

---

## API Design Principles

The API follows:

- RESTful conventions
- consistent response structures
- versioned endpoints
- modular route grouping
- tenant-aware processing
- branch-aware processing
- stateless authentication

---

## Content Type

```http
Content-Type: application/json
```

---

# 3. AUTHENTICATION STRATEGY

## Authentication Method

- JWT Access Tokens
- Refresh Tokens

---

## Authorization Header

```http
Authorization: Bearer <token>
```

---

## Token Flow

```text
Login
  │
  ▼
Access Token + Refresh Token
  │
  ▼
Protected API Access
```

---

# 4. AUTHORIZATION & RBAC

## Supported Roles

- Super Admin
- Tenant Owner
- Branch Manager
- Agent

---

## Access Control Rules

| Role | Access Scope |
|---|---|
| Super Admin | Entire Platform |
| Tenant Owner | Tenant Resources |
| Branch Manager | Assigned Branch |
| Agent | Assigned Conversations & Leads |

---

# 5. MULTI-TENANT API STRATEGY

## Tenant Isolation

Every protected API MUST:

- validate tenant access
- scope queries using tenant_id
- prevent cross-tenant access

---

## Tenant Middleware

Middleware injects:

```text
req.user
req.tenant
req.branch
```

from JWT.

---

# 6. BRANCH ISOLATION STRATEGY

## Branch Isolation

Branch-specific APIs MUST:

- validate branch access
- filter branch resources
- prevent unauthorized branch access

---

## Branch Flow

```text
Tenant
   │
   ▼
Branch
   │
   ▼
Users + Resources
```

---

# 7. STANDARD RESPONSE FORMAT

## Success Response

```json
{
  "success": true,
  "message": "Operation successful",
  "data": {},
  "meta": {}
}
```

---

## Error Response

```json
{
  "success": false,
  "message": "Validation failed",
  "errors": []
}
```

---

# 8. ERROR HANDLING STANDARDS

## Standard Error Structure

```json
{
  "success": false,
  "message": "Unauthorized",
  "errors": [
    {
      "field": "email",
      "message": "Email is required"
    }
  ]
}
```

---

# 9. PAGINATION, FILTERING & SORTING

## Pagination

```http
GET /api/v1/conversations?page=1&limit=20
```

---

## Filtering

```http
GET /api/v1/leads?stage=hot
```

---

## Sorting

```http
GET /api/v1/conversations?sort=created_at:desc
```

---

## Search

```http
GET /api/v1/contacts?search=john
```

---

# 10. AUTHENTICATION APIs

# 10.1 Login

## Endpoint

```http
POST /api/v1/auth/login
```

## Authentication
Public

## Request Body

```json
{
  "email": "admin@example.com",
  "password": "password123"
}
```

## Success Response

```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "access_token": "jwt-token",
    "refresh_token": "refresh-token",
    "user": {}
  }
}
```

---

# 10.2 Register

## Endpoint

```http
POST /api/v1/auth/register
```

---

# 10.3 Refresh Token

## Endpoint

```http
POST /api/v1/auth/refresh
```

---

# 10.4 Logout

## Endpoint

```http
POST /api/v1/auth/logout
```

---

# 10.5 Forgot Password

## Endpoint

```http
POST /api/v1/auth/forgot-password
```

---

# 10.6 Reset Password

## Endpoint

```http
POST /api/v1/auth/reset-password
```

---

# 11. TENANT APIs

# 11.1 Create Tenant

```http
POST /api/v1/tenants
```

---

# 11.2 Get Tenants

```http
GET /api/v1/tenants
```

---

# 11.3 Get Tenant Details

```http
GET /api/v1/tenants/:id
```

---

# 11.4 Update Tenant

```http
PUT /api/v1/tenants/:id
```

---

# 11.5 Delete Tenant

```http
DELETE /api/v1/tenants/:id
```

---

# 12. BRANCH APIs

# 12.1 Create Branch

```http
POST /api/v1/branches
```

---

# 12.2 Get Branches

```http
GET /api/v1/branches
```

---

# 12.3 Get Branch Details

```http
GET /api/v1/branches/:id
```

---

# 12.4 Update Branch

```http
PUT /api/v1/branches/:id
```

---

# 12.5 Delete Branch

```http
DELETE /api/v1/branches/:id
```

---

# 13. USER & RBAC APIs

# 13.1 Create User

```http
POST /api/v1/users
```

---

# 13.2 Get Users

```http
GET /api/v1/users
```

---

# 13.3 Get User Details

```http
GET /api/v1/users/:id
```

---

# 13.4 Update User

```http
PUT /api/v1/users/:id
```

---

# 13.5 Delete User

```http
DELETE /api/v1/users/:id
```

---

# 13.6 Assign Role

```http
POST /api/v1/users/:id/roles
```

---

# 14. OMNICHANNEL INBOX APIs

# 14.1 Get Conversations

```http
GET /api/v1/conversations
```

---

# 14.2 Get Conversation Details

```http
GET /api/v1/conversations/:id
```

---

# 14.3 Assign Conversation

```http
POST /api/v1/conversations/:id/assign
```

---

# 14.4 Close Conversation

```http
POST /api/v1/conversations/:id/close
```

---

# 14.5 Add Conversation Tag

```http
POST /api/v1/conversations/:id/tags
```

---

# 15. MESSAGE APIs

# 15.1 Send Message

```http
POST /api/v1/messages
```

## Request Body

```json
{
  "conversation_id": "uuid",
  "message": "Hello",
  "message_type": "text"
}
```

---

# 15.2 Get Messages

```http
GET /api/v1/conversations/:id/messages
```

---

# 15.3 Upload Media Message

```http
POST /api/v1/messages/upload
```

---

# 16. CRM APIs

# 16.1 Create Lead

```http
POST /api/v1/leads
```

---

# 16.2 Get Leads

```http
GET /api/v1/leads
```

---

# 16.3 Get Lead Details

```http
GET /api/v1/leads/:id
```

---

# 16.4 Update Lead Stage

```http
PATCH /api/v1/leads/:id/stage
```

---

# 16.5 Add CRM Note

```http
POST /api/v1/leads/:id/notes
```

---

# 16.6 Get CRM Activities

```http
GET /api/v1/leads/:id/activities
```

---

# 17. BOOKING APIs

# 17.1 Create Booking

```http
POST /api/v1/bookings
```

---

# 17.2 Get Bookings

```http
GET /api/v1/bookings
```

---

# 17.3 Get Booking Details

```http
GET /api/v1/bookings/:id
```

---

# 17.4 Update Booking Status

```http
PATCH /api/v1/bookings/:id/status
```

---

# 17.5 Add Booking Items

```http
POST /api/v1/bookings/:id/items
```

---

# 18. PRICING ENGINE APIs

# 18.1 Calculate Pricing

```http
POST /api/v1/pricing/calculate
```

## Request Body

```json
{
  "country": "Qatar",
  "weight": 10,
  "service_type": "air"
}
```

---

# 18.2 Create Pricing Rule

```http
POST /api/v1/pricing/rules
```

---

# 18.3 Get Pricing Rules

```http
GET /api/v1/pricing/rules
```

---

# 18.4 Update Pricing Rule

```http
PUT /api/v1/pricing/rules/:id
```

---

# 19. AI APIs

# 19.1 Generate AI Response

```http
POST /api/v1/ai/respond
```

---

# 19.2 Summarize Conversation

```http
POST /api/v1/ai/summarize
```

---

# 19.3 Extract Lead Data

```http
POST /api/v1/ai/extract
```

---

# 19.4 Train AI Knowledge

```http
POST /api/v1/ai/train
```

---

# 20. KNOWLEDGE BASE APIs

# 20.1 Upload Knowledge File

```http
POST /api/v1/knowledge-base/upload
```

---

# 20.2 Get Documents

```http
GET /api/v1/knowledge-base/documents
```

---

# 20.3 Delete Knowledge File

```http
DELETE /api/v1/knowledge-base/documents/:id
```

---

# 20.4 Retrain AI Knowledge

```http
POST /api/v1/knowledge-base/retrain
```

---

# 21. WORKFLOW APIs

# 21.1 Create Workflow

```http
POST /api/v1/workflows
```

---

# 21.2 Get Workflows

```http
GET /api/v1/workflows
```

---

# 21.3 Get Workflow Details

```http
GET /api/v1/workflows/:id
```

---

# 21.4 Update Workflow

```http
PUT /api/v1/workflows/:id
```

---

# 21.5 Execute Workflow

```http
POST /api/v1/workflows/:id/execute
```

---

# 21.6 Get Workflow Executions

```http
GET /api/v1/workflows/executions
```

---

# 22. CAMPAIGN APIs

# 22.1 Create Campaign

```http
POST /api/v1/campaigns
```

---

# 22.2 Get Campaigns

```http
GET /api/v1/campaigns
```

---

# 22.3 Get Campaign Details

```http
GET /api/v1/campaigns/:id
```

---

# 22.4 Send Campaign

```http
POST /api/v1/campaigns/:id/send
```

---

# 22.5 Pause Campaign

```http
POST /api/v1/campaigns/:id/pause
```

---

# 22.6 Campaign Analytics

```http
GET /api/v1/campaigns/:id/analytics
```

---

# 23. ANALYTICS APIs

# 23.1 Dashboard Analytics

```http
GET /api/v1/analytics/dashboard
```

---

# 23.2 Conversation Analytics

```http
GET /api/v1/analytics/conversations
```

---

# 23.3 Campaign Analytics

```http
GET /api/v1/analytics/campaigns
```

---

# 23.4 Agent Analytics

```http
GET /api/v1/analytics/agents
```

---

# 23.5 Branch Analytics

```http
GET /api/v1/analytics/branches
```

---

# 24. BILLING & SUBSCRIPTION APIs

# 24.1 Create Subscription

```http
POST /api/v1/billing/subscriptions
```

---

# 24.2 Get Subscription

```http
GET /api/v1/billing/subscriptions
```

---

# 24.3 Cancel Subscription

```http
POST /api/v1/billing/subscriptions/:id/cancel
```

---

# 24.4 Get Billing History

```http
GET /api/v1/billing/payments
```

---

# 25. NOTIFICATION APIs

# 25.1 Get Notifications

```http
GET /api/v1/notifications
```

---

# 25.2 Mark Notification Read

```http
PATCH /api/v1/notifications/:id/read
```

---

# 26. UPLOAD APIs

# 26.1 Upload File

```http
POST /api/v1/uploads
```

---

# 26.2 Delete File

```http
DELETE /api/v1/uploads/:id
```

---

# 27. WEBHOOK APIs

# 27.1 Meta Webhook

```http
POST /api/v1/webhooks/meta
```

---

# 27.2 Stripe Webhook

```http
POST /api/v1/webhooks/stripe
```

---

# 27.3 OpenAI Callback Webhook

```http
POST /api/v1/webhooks/ai
```

---

# 28. SOCKET.IO EVENTS

## Conversation Events

```text
conversation:new
conversation:update
conversation:assigned
conversation:closed
```

---

## Message Events

```text
message:new
message:typing
message:read
```

---

## Lead Events

```text
lead:new
lead:update
```

---

## Notification Events

```text
notification:new
```

---

## Campaign Events

```text
campaign:started
campaign:completed
```

---

# 29. VALIDATION RULES

## Validation Standards

All APIs MUST:

- validate request body
- validate query params
- validate path params
- validate tenant access
- validate branch access

---

## Required Validation Libraries

Recommended:

- Zod
OR
- Joi

---

# 30. HTTP STATUS CODES

| Status Code | Meaning |
|---|---|
| 200 | Success |
| 201 | Resource Created |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 409 | Conflict |
| 422 | Validation Error |
| 500 | Internal Server Error |

---

# 31. SECURITY STANDARDS

## Security Requirements

All APIs MUST:

- use HTTPS
- validate JWT
- use RBAC
- sanitize inputs
- validate uploads
- rate limit requests
- log critical actions

---

## Rate Limiting

Recommended:

```text
100 requests/minute per user
```

---

# 32. API BEST PRACTICES

## Required Standards

- consistent naming
- modular route grouping
- stateless APIs
- reusable validation
- service abstraction
- repository abstraction
- centralized error handling

---

# 33. FUTURE API SCALABILITY

## Future Scalability Goals

The API architecture supports:

- future microservices
- API gateways
- distributed services
- event-driven scaling

---

## Future Extraction Candidates

```text
AI Service
Campaign Service
Analytics Service
Workflow Engine
Notification Service
```

---

# 34. CONCLUSION

The Tugatai AI SaaS Platform API architecture is designed as a scalable enterprise-grade backend contract system supporting:

- omnichannel communication
- CRM operations
- AI orchestration
- workflow automation
- booking systems
- campaign management
- SaaS scalability
- branch operations
- realtime messaging

The API contract prioritizes:

- scalability
- maintainability
- modularity
- security
- consistency
- future extensibility
- production readiness

