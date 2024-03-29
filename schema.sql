-- In this SQL file, write (and comment!) the schema of your database, including the CREATE TABLE, CREATE INDEX, CREATE VIEW, etc. statements that compose it

-- Represent users of the site
CREATE TABLE IF NOT EXISTS "users" (
	"id" INTEGER,
	"email" TEXT NOT NULL UNIQUE,
    "password_hash" TEXT NOT NULL,
	"firstname" TEXT NOT NULL,
	"lastname" TEXT NOT NULL,
	"bio" TEXT,
	"pic_url" TEXT,

	PRIMARY KEY("id")
);

-- Represent articles posted by users
CREATE TABLE IF NOT EXISTS "articles" (
	"id" INTEGER,
	"author_id" INTEGER,
    "title" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "published" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,

	PRIMARY KEY ("id"),
	FOREIGN KEY ("author_id") REFERENCES "users"("id")
);

-- Represent topics of articles
CREATE TABLE IF NOT EXISTS "topics" (
    "id" INTEGER,
    "name" TEXT NOT NULL UNIQUE,

    PRIMARY KEY("id")
);

-- Represent association between articles and topics
CREATE TABLE IF NOT EXISTS "articles_topics" (
    "article_id" INTEGER,
    "topic_id" INTEGER,

    FOREIGN KEY ("article_id") REFERENCES "articles"("id"),
    FOREIGN KEY ("topic_id") REFERENCES "topics"("id")
);

-- Represent article likes by users
CREATE TABLE IF NOT EXISTS "likes" (
	"article_id" INTEGER,
	"user_id" INTEGER,

	FOREIGN KEY ("article_id") REFERENCES "articles" ("id"),
	FOREIGN KEY ("user_id") REFERENCES "users"("id")
);

-- Represent comments on articles by users
CREATE TABLE IF NOT EXISTS "comments" (
    "id" INTEGER,
    "article_id" INTEGER NOT NULL
    "author_id" INTEGER NOT NULL,
    "content" TEXT NOT NULL,
    "written" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY("id"),
    FOREIGN KEY ("article_id") REFERENCES "articles" ("id"),
    FOREIGN KEY ("author_id") REFERENCES "users"("id")
);

-- Represent users following other users
CREATE TABLE IF NOT EXISTS "follows" (
	"user_id" INTEGER,
	"following_id" INTEGER,

	FOREIGN KEY ("user_id") REFERENCES "users"("id"),
	FOREIGN KEY ("following_id") REFERENCES "users"("id")
);

-- Represent logs for activities
CREATE TABLE IF NOT EXISTS "activity_logs" (
    "action_by_id" INTEGER NOT NULL,
    "action_for_id" INTEGER,  -- user on whom action is done, eg. followed
    "action_on_id" INTEGER,  -- post on which action is done, eg. liked
   	"action_type" TEXT NOT NULL CHECK ("action_type" IN ('comment', 'like', 'follow', 'post')),
    "timestamp" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY ("action_by_id") REFERENCES "users"("id"),
    FOREIGN KEY ("action_for_id") REFERENCES "users"("id"),
    FOREIGN KEY ("action_on_id") REFERENCES "articles"("id")  -- Assuming posts table
);
-- Activity logs will be used for updates to users and a user activity log page
-- eg:
-- 	"Alex" liked your post "SQL basics"
-- 	"Bob" followed you
-- 	"Carey" commented on your post "SQL basics"
-- 	"Alex" posted an article "HTML for beginners" (assuming Alex is followed by you)


-- Create indexes to speed common searches
CREATE INDEX IF NOT EXISTS "article_by_writer_search" ON "articles" ("author_id");
CREATE INDEX IF NOT EXISTS "article_by_title_search" ON "articles" ("title");
CREATE INDEX IF NOT EXISTS "articles_by_topic_search" ON "articles_topics" ("topic_id");
CREATE INDEX IF NOT EXISTS "topics_for_articles_search" ON "articles_topics" ("article_id");
CREATE INDEX IF NOT EXISTS "likes_for_article_search" ON "likes" ("article_id");
CREATE INDEX IF NOT EXISTS "comments_for_article_search" ON "comments" ("article_id");
CREATE INDEX IF NOT EXISTS "user_follows_search" ON "follows" ("user_id");
CREATE INDEX IF NOT EXISTS "user_followers_search" ON "follows" ("following_id");
CREATE INDEX IF NOT EXISTS "user_updates_search" ON "activity_logs" ("action_for_id");
CREATE INDEX IF NOT EXISTS "article_updates_search" ON "activity_logs" ("action_on_id");


-- Triggers for updating activity logs on insertions in various tables
CREATE TRIGGER IF NOT EXISTS "article_posted"
AFTER INSERT ON "articles"
BEGIN
    INSERT INTO "activity_logs" ("action_by_id", "action_on_id", "action_type")
    VALUES (NEW."author_id", NEW."id", "post");
END;

CREATE TRIGGER IF NOT EXISTS "liked"
AFTER INSERT ON "likes"
BEGIN
    INSERT INTO "activity_logs" ("action_by_id", "action_on_id", "action_type")
    VALUES (NEW."user_id", NEW."article_id", "like");
END;

CREATE TRIGGER  IF NOT EXISTS "followed"
AFTER INSERT ON "follows"
BEGIN
    INSERT INTO "activity_logs" ("action_by_id", "action_for_id", "action_type")
    VALUES (NEW."user_id", NEW."following_id", "follow");
END;

CREATE TRIGGER IF NOT EXISTS "commented"
AFTER INSERT ON "comments"
BEGIN
    INSERT INTO "activity_logs" ("action_by_id", "action_on_id", "action_type")
    VALUES (NEW."author_id", NEW."article_id", "comment");
END;


/* Views */

-- Get number of likes on an article (to show on a list articles pages)
CREATE VIEW IF NOT EXISTS "article_likes_count" AS
SELECT
    "article_id",
    COUNT(*) AS "likes"
FROM
    "likes"
GROUP BY "article_id";

-- Get number of comments on an article 
CREATE VIEW IF NOT EXISTS "article_comments_count" AS
SELECT
    "article_id",
    COUNT(*) AS "comments"
FROM
    "comments"
GROUP BY "article_id";


-- Details of an article
CREATE VIEW IF NOT EXISTS "article_details" AS
SELECT
    "A"."id" AS "id",
    "A"."title" AS "title",
    "A"."content" AS "content",
    "A"."published" AS "published",
    "U"."firstname" || ' ' || "U"."lastname" AS "author_name",
    "U"."pic_url" AS "author_pic_url",
    GROUP_CONCAT("T"."name") AS "topics",
    "L"."likes" AS "likes",
    "C"."comments" AS "comments"
FROM
    "articles" AS "A"
    JOIN "users" AS "U" ON "A"."author_id" = "U"."id"
    JOIN "articles_topics" AS "AT" ON "A"."id" = "AT"."article_id"
    JOIN "topics" AS "T" ON "AT"."topic_id" = "T"."id"
    JOIN "article_likes_count" AS "L" ON "A"."id" = "L"."article_id"
    JOIN "article_comments_count" AS "C" ON "A"."id" = "C"."article_id"
GROUP BY "A"."id";

-- Followers and following count of a user
CREATE VIEW IF NOT EXISTS "follow_counts" AS
SELECT
    "id",
    (SELECT COUNT(*) FROM "follows" WHERE "following_id" = "id") AS "followers",
    (SELECT COUNT(*) FROM "follows" WHERE "user_id" = "id") AS "followings"
FROM
    "users";

-- User details
CREATE VIEW IF NOT EXISTS "user_details" AS
SELECT
    "users"."id" AS "id",
    "users"."email" AS "email",
    "users"."firstname" || ' ' || "users"."lastname" AS "name",
    "users"."bio" AS "bio",
    "users"."pic_url" AS "pic_url",
    "follow_counts"."followers" AS "followers",
    "follow_counts"."followings" AS "followings"
FROM
    "users"
    JOIN "follow_counts" ON "users"."id" = "follow_counts"."id";


