# Design Document For CS50 SQL Final Project - Tehreer

By Sohaib Ahmed Abbasi

Video overview: `<URLHERE>`

## Scope

This  database is for "Tehreer", an online article writing application, à la [medium.com](https://medium.com). The application is intended to provide a platform for users to post articles on various topics, like and comment on articles, and follow other users. As such, included in the database's scope is:

&#10003; **Users**, including basic identifying information, their bio (short self description), and picture (URL).
&#10003; **Articles**, including the author, title, content, and when it was published.
&#10003; **Topics** for articles.
&#10003; **Likes** on articles , including the liker.
&#10003; **Comments** on articles, including the content, the user who wrote it, and the timestamp.
&#10003; Notion of **following** users.
&#10003; **Activity logs**, to keep track of likes, comments, and follows, including the performer of activity, what (article) or whom (user) the target of the activity is, and the timestamp.

Out of scope are any other elements that an article publishing site may have for example:

&#10005; Article versions.
&#10005; Notion of saving articles or making collections.
&#10005; User analytics/reports.

## Functional Requirements

This database will support:

&#10003; CRUD operations on users, articles, and comments.
&#10003; Viewing all articles or articles of a certain user.
&#10003; Commenting on articles.
&#10003; Liking and unliking articles, and viewing all liked articles in one place.
&#10003; Following and unfollowing users, and viewing articles of followed users of a certain user.
&#10003; Associating multiple topics per article and viewing all articles with a certain topic or searching posts by topics.
&#10003; Finding out updates for each user, kind of like notifications, for example when someone comments on their article, when a followed user posts, etc.
&#10003; Searching for posts by title.

It will not support:

&#10005; Mantaining versions of articles.
&#10005; Saving articles or making collections.
&#10005; Newsletter service.
&#10005; Monetization.
&#10005; Advertisements.
&#10005; Languages other than english.
&#10005; User analytics and preferences.

## Representation

### Entities

The database includes the following entities:

#### Users

The `users` table includes:

* `id`, which specifies the unique ID for the user as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `email`, which specifies the user's email as `TEXT`, is marked as `NOT NULL` to make it mandatory and has a `UNIQUE` constraint applied because no two users should have the same email.
* `password_hash`, which stores the hashed password as `TEXT` and is marked as `NOT NULL`.
* `firstname`, which specifies the user's first name as `TEXT`.
* `lastname`, which specifies the user's last name as `TEXT`.
* `bio`, which stores the user's bio as `TEXT`.
* `pic_url`, which stores the URL of the user's profile picture as `TEXT`.

Email, password_hash, firstname, and lastname, are marked as `NOT NULL` because they are mandatory fields, while bio and pic_url are not marked as `NOT NULL` because they are optional. A `UNIQUE` constraint is applied to email to ensure no two users have the same email.

#### Articles

The `articles` table includes:

* `id`, which specifies the unique ID for the article as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `author_id`, which specifies the ID of the user who authored the article as an `INTEGER`. This column thus has the `FOREIGN KEY` constraint applied, referencing the `id` column in the `users` table to ensure data integrity.
* `title`, which specifies the title of the article as `TEXT`.
* `content`, which stores the content of the article as `TEXT`.
* `published`, which is a `NUMERIC` column storing the timestamp when the article was published, since according to the SQLite documentation at [https://www.sqlite.org/datatype3.html](https://www.sqlite.org/datatype3.html), timestamps can be conveniently stored using the  `NUMERIC` data type. The default value is the current timestamp as denoted by `DEFAULT CURRENT_TIMESTAMP`.

All columns in the `articles` table are required, and hence have the `NOT NULL` constraint applied. No other constraints are necessary.

#### Topics

The `topics` table includes:

* `id`, which specifies the unique ID for the topic as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `name`, which is the name of the topic as `TEXT`. `UNIQUE` constraint is applied on this column to ensure same topic isn't stored more than once.

#### Articles_Topics

The `articles_topics` table includes:

* `article_id`, which specifies the ID of the article as an `INTEGER`. This column thus has the `FOREIGN KEY` constraint applied, referencing the `id` column in the `articles` table.
* `topic_id`, which specifies the ID of the topic as an `INTEGER`. This column thus has the `FOREIGN KEY` constraint applied, referencing the `id` column in the `topics` table.

#### Likes

The `likes` table includes:

* `article_id`, which specifies the ID of the liked article as an `INTEGER`. This column thus has the `FOREIGN KEY` constraint applied, referencing the `id` column in the `articles` table.
* `user_id`, which specifies the ID of the user who liked the article as an `INTEGER`. This column thus has the `FOREIGN KEY` constraint applied, referencing the `id` column in the `users` table.

#### Comments

The `comments` table includes:

* `id`, which specifies the unique ID for the comment as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `article_id`, which specifies the ID of the commented article as an `INTEGER`. This column has the `FOREIGN KEY` constraint applied, referencing the `id` column in the `articles` table.
* `author_id`, which specifies the ID of the user who wrote the comment as an `INTEGER`. This column has the `FOREIGN KEY` constraint applied, referencing the `id` column in the `users` table.
* `content`, which contains the contents of the comment as `TEXT`.
* `written`, which is a `NUMERIC` column storing the timestamp when the comment was written. The default value is the current timestamp.
  All columns are required, and hence have the `NOT NULL` constraint applied (except `id` which already is not nullable as it is the primary key).

#### Follows

The `follows` table includes:

* `user_id`, which specifies the ID of the user who is following another user as an `INTEGER`. This column has the `FOREIGN KEY` constraint applied, referencing the `id` column in the `users` table.
* `following_id`, which specifies the ID of the user being followed as an `INTEGER`. This column has the `FOREIGN KEY` constraint applied, referencing the `id` column in the `users` table.

#### Activity Logs

The `activity_logs` table includes:

* `action_by_id`, which specifies the ID of the user performing the action as an `INTEGER`. This column has the `FOREIGN KEY` constraint applied, referencing the `id` column in the `users` table.
* `action_for_id`, which specifies the ID of the user on whom the action is done as an `INTEGER`. This column has the `FOREIGN KEY` constraint applied, referencing the `id` column in the `users` table.
* `action_on_id`, which specifies the ID of the article on which the action is done as an `INTEGER`. This column has the `FOREIGN KEY` constraint applied, referencing the `id` column in the `articles` table.
* `action_type`, which specifies the type of action (comment, like, follow, post) as `TEXT`. A `CHECK` constraint ensures the validity of the action type.
* `timestamp`, which is a `NUMERIC` column storing the timestamp when the action was performed. The default value is the current timestamp.

`action_for_id` and `action_by_id` are optional since an action may be performed towards a user (eg. follow) or on an article (eg. like) but not both. Rest of the columns are mandatory and hence have the `NOT NULL` constraint applied.

### Relationships

In this section you should include your entity relationship diagram and describe the relationships between the entities in your database.
`<img src="TehreerDB.svg" alt="Tehreer DB ER Diagram" width="40%">`

## Optimizations

Considering the typical use cases of the database in `queries.sql`, the following optimizations were made:

### Indexes

Following indexes were created to speed up common queries:

* On `author_id` column in `articles` for searching articles by author. (`article_by_writer_search`)
* On `title` column in `articles` for searching articles by title. (`article_by_title_search`)
* On `topic_id` column in `articles_topics` for searching articles by topic. (`articles_by_topic_search`)
* On `article_id` column in `articles_topics` for searching topics for an article. (`topics_for_articles_search`)
* On `article_id` column in `likes` for searching likes for an article. (`likes_for_article_search`)
* On `article_id` column in `comments` for searching comments for an article. (`comments_for_article_search`)
* On `user_id` column in `follows` for searching users followed by a user. (`user_follows_search`)
* On `following_id` column in `follows` for searching users following a user. (`user_followers_search`)
* On `action_for_id` column in `activity_logs` for searching updates for a user. (`user_updates_search`)
* On `action_on_id` column in `activity_logs` for searching updates for an article. (`article_updates_search`)

### Triggers

Following triggers were created to update activity logs on insertions in various tables:

* `article_posted` for when an article is posted.
* `liked` for when an article is liked.
* `followed` for when a user is followed.
* `commented` for when a comment is posted.

### Views

Following views were created to simplify common queries:

* `article_likes_count` for getting number of likes on an article.
* `article_comments_count` for getting number of comments on an article.
* `article_details` for getting details of an article.
* `follow_counts` for getting followers and following count of a user.
* `user_details` for getting details of a user.

## Limitations

The current database design aims to cover most basic important features of an article publishing app. However, it does not cover all the features that a full-fledged real world article publishing site may have, such as the ones mentioned as out of scope in the scope section and not supported in the functional requirements section.
