# Skill: Database Patterns

Production database patterns for this project. Follow these exactly.

## Schema Design Rules
1. Every table has: `id` (cuid2), `createdAt`, `updatedAt`
2. Use soft deletes (`deletedAt` nullable timestamp) for user-facing data
3. Normalize to 3NF, denormalize only with measured performance justification
4. Every foreign key has an index
5. Every column that appears in a WHERE clause has an index
6. Use enums for fixed value sets, not magic strings
7. Add CHECK constraints for business rules at the DB level

## Prisma Conventions
```prisma
model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String
  role      UserRole @default(USER)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  deletedAt DateTime?

  // Relations
  projects  Project[]
  sessions  Session[]

  @@index([email])
  @@index([deletedAt])
  @@map("users")
}

enum UserRole {
  USER
  ADMIN
  SUPER_ADMIN
}
```

## Query Patterns
- Always use transactions for multi-table writes
- Always use `select` to limit returned fields (never return `*`)
- Always paginate list queries (cursor-based for large sets, offset for small)
- Always add `where: { deletedAt: null }` for soft-deleted tables
- Never perform DB queries inside loops — batch with `IN` clauses

## Migration Rules
- Migrations are forward-only in production
- Every migration must be reversible (test `down` migration)
- Data migrations go in separate files from schema migrations
- Never drop columns without a 2-phase deprecation (add new → migrate → drop old)
