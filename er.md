---
title: Tehreer DB
---
erDiagram
    User }o--o{ User: "follows"
    User |o--|{ Article: "likes"
    User }|--o{ Article : "writes"
    User ||--o{ Comment: "makes"
    Comment }o--|| Article: "on"
    %% User |o--|{ Article: "comments on"
    Article }|--o{ Topic: "is about"

    User {
        int id
        text email
        text password_hash
        text firstname
        text lastname
        text bio
        text pic_url
    }

    Article {
        int id
        int author_id
        text title
        text content
        numeric published
    }

    Topic {
        int id
        text name
    }

    Comment {
        int author_id
        int article_id
        text content
    }

    
    
