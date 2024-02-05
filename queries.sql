-- Add some users
INSERT INTO "users" ("username")
VALUES
('khalid'), -- id: 1
('etch'), -- id: 2
('zoz'), -- id: 3
('s7s'), -- id: 4
('hawary'), -- id: 5
('basmala'), -- id: 6
('touqa'), -- id: 7
('hania'); -- id: 8

-- Create a group
INSERT INTO "groups" ("name")
VALUES
('sa7el');

-- Add users to the group
INSERT INTO "memberships" ("user_id", "group_id")
VALUES
(1, 1),
(2, 1),
(3, 1),
(4, 1),
(5, 1);

-- Add an expense
INSERT INTO "expenses" ("user_id", "group_id", "amount", "description")
VALUES
(1, 1, 100, 'Dinner'); -- Khalid pays for dinner

-- Add another expense
INSERT INTO "expenses" ("user_id", "group_id", "amount", "description")
VALUES
(5, 1, 500, 'Gas'); -- Hawary pays for gas

-- Khalid is popular and creates another group
INSERT INTO "groups" ("name")
VALUES
('swifties');

-- Add users to the group
INSERT INTO "memberships" ("user_id", "group_id")
VALUES
(1, 2),
(6, 2),
(7, 2),
(8, 2);

-- Add an expense
INSERT INTO "expenses" ("user_id", "group_id", "amount", "description")
VALUES
(1, 2, 800, 'Concert tickets'); -- Khalid pays for concert tickets

-- Now, let's see how much each user owes or is owed in group 'sa7el'
SELECT "username", "balance"
FROM "users"
JOIN "memberships" ON "users"."id" = "memberships"."user_id"
WHERE "group_id" = (
    SELECT "id"
    FROM "groups"
    WHERE "name" = 'sa7el'
);

-- Now, let's see how much each user owes or is owed in group 'swifties'
SELECT "username", "balance"
FROM "users"
JOIN "memberships" ON "users"."id" = "memberships"."user_id"
WHERE "group_id" = (
    SELECT "id"
    FROM "groups"
    WHERE "name" = 'swifties'
);

-- Now let's see how much Khalid owes or is owed in total
SELECT "username", "total_balance"
FROM "total_balances"
WHERE "username" = 'khalid';

-- Khalid decides to pay off his debts
BEGIN TRANSACTION;

UPDATE "memberships"
SET "balance" = "balance" + 20
WHERE "user_id" = (
    SELECT "id"
    FROM "users"
    WHERE "username" = 'khalid'
);

UPDATE "memberships"
SET "balance" = "balance" - 20
WHERE "user_id" = (
    SELECT "id"
    FROM "users"
    WHERE "username" = 'hawary'
);

COMMIT;

-- Now, let's see how much each user owes or is owed in group 'sa7el'
SELECT "username", "balance"
FROM "users"
JOIN "memberships" ON "users"."id" = "memberships"."user_id"
WHERE "group_id" = (
    SELECT "id"
    FROM "groups"
    WHERE "name" = 'sa7el'
);
