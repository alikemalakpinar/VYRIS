# VYRIS Server

Production-grade backend for VYRIS: scarcity minting, encounter verification, wallet pass issuance, and device reforge.

## Architecture

Single deployable Fastify service backed by Postgres (state) and Redis (traffic control).

### Key Patterns

- **Idempotent minting** via `receipt_ledger` — every receipt is recorded exactly once
- **Redis bouncer** — Lua-based atomic slot decrement prevents oversell under concurrency
- **SKIP LOCKED allocation** — randomized `sort_order` + row-level locking for deadlock-free claims
- **Compensation** — if Postgres TX fails after Redis decrement, the slot is returned via INCR
- **ES256 JWT encounters** — server-authoritative verification with TTL + replay prevention
- **Device reforge** — email deep link confirmation for secure device key transfer

## Quick Start

### 1. Start infrastructure

```bash
cd server
docker compose up -d
```

### 2. Install dependencies

```bash
npm install
```

### 3. Configure environment

```bash
cp .env.example .env
# Edit .env — at minimum set ENCOUNTER_JWT_PUBLIC_KEY with a real key:
#   openssl ecparam -genkey -name prime256v1 -noout -out ec_private.pem
#   openssl ec -in ec_private.pem -pubout -out ec_public.pem
```

### 4. Run migrations

```bash
npm run migrate
```

### 5. Seed allocation pool

```bash
npm run seed
```

### 6. Start server

```bash
npm run dev
```

Server runs on `http://localhost:3000`. Health check: `GET /health`.

## API Endpoints

| Method | Path | Description | Success | Error Codes |
|--------|------|-------------|---------|-------------|
| POST | `/mint` | Idempotent mint from receipt | 201 | 410, 409, 422, 500 |
| POST | `/issue-pass` | Get pkpass binary for membership | 200 | 401, 404 |
| POST | `/encounters/verify` | Verify encounter JWT | 201 | 401, 409 |
| POST | `/devices/reforge/init` | Start device transfer | 202 | 401, 404, 422 |
| POST | `/devices/reforge/confirm` | Confirm device transfer | 200 | 404, 410 |
| GET | `/health` | Health check | 200 | 503 |

### Error Response Format

All errors follow this structure:

```json
{
  "error": "SOLD_OUT",
  "message": "No allocations remaining for this drop",
  "retryable": false
}
```

Error codes: `SOLD_OUT` (410), `RECEIPT_USED` (409), `INVALID_RECEIPT` (422), `UNAUTHORIZED` (401), `RETRYABLE` (500).

## Mint Flow

```
Client → POST /mint { receipt_data, user_id }
  │
  ├─ 1. Upsert receipt_ledger (PENDING)
  │     └─ If FULFILLED → return existing membership (idempotent)
  │
  ├─ 2. Redis bouncer: EVAL decrement script
  │     └─ If 0 → 410 SOLD_OUT
  │
  └─ 3. Postgres TX:
        ├─ SELECT ... FOR UPDATE SKIP LOCKED → claim allocation
        ├─ INSERT membership
        ├─ UPDATE receipt_ledger → FULFILLED
        └─ On failure → ROLLBACK + Redis INCR compensation
```

## Project Structure

```
server/
├── src/
│   ├── config/         # Environment, logger
│   ├── db/
│   │   ├── migrations/ # SQL migration files (ordered)
│   │   ├── migrate.ts  # Migration runner
│   │   ├── pool.ts     # Postgres pool + transaction helpers
│   │   └── seed.ts     # Allocation pool seeder
│   ├── redis/
│   │   ├── bouncer.lua # Atomic slot decrement script
│   │   ├── bouncer.ts  # Bouncer TypeScript wrapper
│   │   └── client.ts   # Redis connection
│   ├── routes/         # Fastify route handlers
│   ├── services/       # Business logic
│   ├── security/       # JWT verification, PEM parsing
│   ├── utils/          # Error types, hashing
│   └── index.ts        # Server entry point
├── docker-compose.yml
├── package.json
└── tsconfig.json
```
