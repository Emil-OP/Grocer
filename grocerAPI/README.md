# grocerAPI

The REST backend for [Grocer](../README.md) — a Node.js/Express API backed by PostgreSQL that serves the product catalog and manages users and grocery lists for the iOS app.

## Stack

- Node.js + Express
- PostgreSQL (via `pg`)
- JWT access/refresh tokens, with passwords and refresh tokens hashed via `bcrypt`
- `dotenv` for configuration

## Setup

1. **Install PostgreSQL** and create a database for the app (e.g. with pgAdmin: https://www.pgadmin.org/download/).

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure environment variables.** Create a `.env` file in this directory:
   ```
   DB_HOST=localhost
   DB_PORT=5432
   DB_USER=your_db_user
   DB_PASSWORD=your_db_password
   DB_NAME=your_db_name

   PORT=3300
   JWT_SECRET=some_long_random_string
   JWT_REFRESH_SECRET=another_long_random_string
   ```

4. **Run the server**
   ```bash
   node api.js
   ```
   It listens on `PORT` (defaults to `3300`). Visit `http://localhost:3300/products` — if the database connection and schema are set up correctly, you should get back a paginated JSON list of products.

## Endpoints

| Method | Path                                      | Auth | Description                                  |
|--------|-------------------------------------------|------|-----------------------------------------------|
| POST   | `/register`                               | –    | Create a user, returns access + refresh tokens |
| POST   | `/login`                                  | –    | Authenticate, returns access + refresh tokens |
| POST   | `/refresh`                                | –    | Exchange a refresh token for a new access token |
| GET    | `/products?page=&limit=`                  | –    | Paginated product catalog                     |
| GET    | `/search?q=`                              | –    | Search products by name                       |
| GET    | `/product/:id`                            | –    | Fetch a single product                        |
| GET    | `/grocery-lists`                          | JWT  | All of the authenticated user's grocery lists |
| POST   | `/grocery-lists`                          | JWT  | Create a new grocery list                     |
| GET    | `/grocery-lists/:listId`                  | JWT  | Fetch a single grocery list                   |
| POST   | `/grocery-lists/:listId/items`            | JWT  | Add/increment a product in a list             |
| PATCH  | `/grocery-lists/:listId/items/:glItemID`  | JWT  | Mark an item purchased/unpurchased            |

Authenticated routes expect `Authorization: Bearer <access_token>`.

## Schema

The API assumes these tables already exist (not yet checked into this repo as migrations — see [What's next](../README.md#whats-next) on the main README):

- `users` (`id`, `username`, `password_hash`, `name`, `role`)
- `refresh_tokens` (`user_id`, `refresh_token_hash`, `expires_at`)
- `supermarkets` (`id`, `supermarket_name`)
- `products` (`id`, `product_name`, `price`, `measurement`, `measurement_description`, `image_url`, `supermarket`)
- `grocery_lists` (`id`, `user_id`, `name`)
- `grocery_list_items` (`id`, `gl_id`, `p_id`, `amount`, `is_checked`)

## Status

This is the backend half of a personal learning project — see the [root README](../README.md) for the full picture, including what's still in progress.
