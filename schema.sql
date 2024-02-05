-- Represent users
CREATE TABLE "users" (
    "id" INTEGER,
    "username" TEXT UNIQUE NOT NULL,
    PRIMARY KEY("id")
);

-- Represent groups
CREATE TABLE "groups" (
    "id" INTEGER,
    "name" TEXT UNIQUE NOT NULL,
    "number_of_members" INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY("id")
);

-- Represent memberships
CREATE TABLE "memberships" (
    "user_id" INTEGER,
    "group_id" INTEGER,
    "balance" REAL NOT NULL DEFAULT 0, -- "balance" is the amount of money a user owes to the group, or the amount of money the group owes to the user
    PRIMARY KEY("user_id", "group_id"),
    FOREIGN KEY("user_id") REFERENCES "users"("id"),
    FOREIGN KEY("group_id") REFERENCES "groups"("id")
);

-- Represent expenses
CREATE TABLE "expenses" (
    "id" INTEGER,
    "user_id" INTEGER,
    "group_id" INTEGER,
    "amount" REAL NOT NULL,
    "description" TEXT,
    "timestamp" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id"),
    FOREIGN KEY("user_id") REFERENCES "users"("id"),
    FOREIGN KEY("group_id") REFERENCES "groups"("id")
);

-- Trigger to update the number of members in a group
CREATE TRIGGER "update_number_of_members" AFTER INSERT ON "memberships"
BEGIN
    -- Increase the number of members in the group by one
    UPDATE "groups"
    SET "number_of_members" = "number_of_members" + 1
    WHERE "id" = NEW."group_id";
END;

-- Trigger to update balances
CREATE TRIGGER "update_balances" AFTER INSERT ON "expenses"
BEGIN
    -- Reduce the balance of each user in the group by the amount of the expense divided by the number of users in the group
    UPDATE "memberships"
    SET "balance" = "balance" - (NEW."amount" / (SELECT "number_of_members" FROM "groups" WHERE "id" = NEW."group_id"))
    WHERE "user_id" != NEW."user_id" AND "group_id" = NEW."group_id";
    -- Increase the balance of the user who paid the expense by the amount of the expense divided by the number of users in the group multiplied by the number of users in the group minus one
    UPDATE "memberships"
    SET "balance" = "balance" + (NEW."amount" / (SELECT "number_of_members" FROM "groups" WHERE "id" = NEW."group_id")) * ((SELECT "number_of_members" FROM "groups" WHERE "id" = NEW."group_id") - 1)
    WHERE "group_id" = NEW."group_id" AND "user_id" = NEW."user_id";
END;

-- View to see the total balance of each user across all groups
CREATE VIEW "total_balances" AS
SELECT "username", SUM("balance") AS "total_balance"
FROM "users"
JOIN "memberships" ON "users"."id" = "memberships"."user_id"
GROUP BY "user_id";

CREATE INDEX "users_username" ON "users"("username");
CREATE INDEX "groups_name" ON "groups"("name");
CREATE INDEX "memberships_user_id_group_id" ON "memberships"("user_id", "group_id");
