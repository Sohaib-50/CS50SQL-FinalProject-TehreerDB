-- In this SQL file, write (and comment!) the typical SQL queries users will run on your database

-- find a user by email, eg. 'foo@bar.com', and password_hash (eg for authentication)
SELECT *
FROM "users"
WHERE "email" = 'foo@bar.com'
AND "password_hash" = 'xyz';


-- Get all articles of a user with a particular ID eg. 10 (eg. to display on their profile page)
SELECT "title", "content", "published"
FROM "articles"
WHERE "author_id" = 10;


-- Get all articles of a certain topic eg. AI
SELECT "title", "content", "published"
FROM "articles"
WHERE "id" IN (
    SELECT "article_id"
    FROM "articles_topics"
    WHERE "topic_id" = (
        SELECT "id"
        FROM "topics"
        WHERE "name" = 'AI'
    )
);
-- OR
SELECT "title", "content", "published"
FROM "articles"
JOIN "articles_topics" ON "articles"."id" = "articles_topics"."article_id"
JOIN "topics" ON "articles_topics"."topic_id" = "topics"."id"
WHERE "topics"."name" = 'AI';


-- Get articles written by people followed by the user with id 3
SELECT "title", "content", "published"
FROM "articles"
WHERE "author_id" IN (
    SELECT "following_id"
    FROM "follows"
    WHERE "user_id" = '3'
);

-- Get full details of an article eg. one with id 13
SELECT * FROM "article_details" WHERE "id" = 13;  -- using a view

-- Get comments on a particular article eg. one with id 7
SELECT U."firstname" || ' ' || U."lastname" AS "writer_name",
       C."content",
       C."written"
FROM "comments" AS C
JOIN "users" AS U ON C."author_id" = U."id"
WHERE C."article_id" = 7;


-- Get number of likes on an article, eg. article id 7
SELECT COUNT(*)
FROM "likes"
WHERE "article_id" = 7;
-- OR, via a view
SELECT "likes" FROM "article_likes_count" WHERE "article_id" = 7;


-- Get number of followers and followings of a particular user eg. with id 5
SELECT
    (SELECT COUNT(*) FROM "follows" WHERE "following_id" = 5) AS "followers_count",
    (SELECT COUNT(*) FROM "follows" WHERE "user_id" = 5) AS "followings_count";
-- OR, via view:
SELECT "followers", "followings" FROM "follow_counts" WHERE "id" = 5;

-- Get users followed by a particular user eg. with id 5
SELECT "following_id"
FROM "follows"
WHERE "user_id" = 5;

-- Get users who liked a particular article eg. with id 7
SELECT "user_id"
FROM "likes"
WHERE "article_id" = 7;

-- Get all activity updates for a user particular user eg. with id 9
SELECT
    "U"."firstname" || ' ' || U."lastname" AS "name",
    "action_by_id", "action_on_id", "action_type", "timestamp"
FROM 
    "activity_logs"
    JOIN "users" AS "U" ON "U"."id" = "activity_logs"."action_by_id"
WHERE
    "action_for_id" = 9
UNION
SELECT
    "A"."title" AS "name",
    "action_by_id", "action_on_id", "action_type", "timestamp"
FROM 
    "activity_logs"
    JOIN "articles" AS "A" ON "A"."id" = "activity_logs"."action_on_id"
WHERE
    "action_on_id" IN (
        SELECT "id"
        FROM "articles"
        WHERE "author_id" = 9
    )
ORDER BY "activity_logs"."timestamp" DESC;
