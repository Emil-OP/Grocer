const pool = require('./connection')
const express = require('express')
const app = express()
const bcrypt = require('bcrypt')
const port = process.env.PORT || 3300
const jwt = require('jsonwebtoken');

app.use(express.json())

app.listen(port, ()=>{
    console.log(`Server is now listening at port ${port}`)
})

const authenticateToken = (req,res,next)=>{
    console.log("Incoming Headers: ", req.headers);
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if(!token){
        return res.status(401).json({error: "Access token required."});
    };

    jwt.verify(token, process.env.JWT_SECRET,(err, decodedUser)=>{
        if(err){
            return res.status(403).json({error:"Invalid or expired token."});
        }

        req.user = decodedUser;
        next();
    });
};

// onFailure Clause for expired access tokens

// Register user + login

app.post('/register',async (req, res)=>{
    const {username , password, name} = req.body
    try {
        const duplicateSearchQuery = `SELECT * FROM users WHERE username=$1`
        const duplicateQueryResult = await pool.query(duplicateSearchQuery, [username])

        if(duplicateQueryResult.rows.length != 0){
            return res.status(422).json({error: "Username is already in use."})
        }

        const hashedPassword = await bcrypt.hash(password, 10)

        const registerQuery = `INSERT INTO users (username, password_hash, name) VALUES ($1 ,$2, $3) RETURNING id, username, name`
        const registerQueryResult = await pool.query(registerQuery, [username, hashedPassword, name])

        const newUser = registerQueryResult.rows[0]
        const tokenPayload = {
            sub: newUser.id,
            role: 'user'
        }
        const accessToken = jwt.sign(
            tokenPayload,
            process.env.JWT_SECRET,
            {expiresIn: '15d'}
        )
        const refreshToken = jwt.sign(
            tokenPayload,
            process.env.JWT_REFRESH_SECRET,
            {expiresIn: '7d'}
        )
        const hashedRefreshToken = await bcrypt.hash(refreshToken, 10)

        const expiresAt = new Date()
        expiresAt.setDate(expiresAt.getDate() + 7)

        const refreshTokenQuery = `INSERT INTO refresh_tokens (user_id, refresh_token_hash, expires_at) VALUES ($1, $2, $3)`

        const refreshQueryResult = await pool.query(refreshTokenQuery,[newUser.id,hashedRefreshToken,expiresAt])

        res.status(201).json({
            message: "User registered.",
            access_token: accessToken,
            refresh_token: refreshToken,
            username: newUser.username,
            name: newUser.name
        })

    } catch (error){
        console.error("Internal error: ", error )
        res.status(500).json({error: "Internal server error."})
    }
})

//Login user

app.post('/login', async (req, res)=>{
    const { username, password } = req.body

    try{

        const userQuery = `SELECT * FROM users WHERE username = $1`
        const result = await pool.query(userQuery,[username])

        if(result.rows.length != 1){
            return res.status(401).json({error: "Invalid credentials."})
        }

        const user = result.rows[0]

        const isPasswordValid = await bcrypt.compare(password, user.password_hash)

        if(!isPasswordValid){
            return res.status(401).json({error: "Invalid credentials."})
        }

        const accessTokenPayload = {
            sub: user.id,
            role: user.role
        }

        const accessToken = jwt.sign(
            accessTokenPayload,
            process.env.JWT_SECRET,
            {expiresIn : '999d'}
        )

        const refreshTokenPayload = {
            sub: user.id
        }

        const refreshToken = jwt.sign(
            refreshTokenPayload,
            process.env.JWT_REFRESH_SECRET,
            {expiresIn: '7d'}
        )

        const hashedRefreshToken = await bcrypt.hash(refreshToken, 10)

        const expiresAt = new Date()
        expiresAt.setDate(expiresAt.getDate() + 7)

        const refreshTokenQuery = `INSERT INTO refresh_tokens (user_id, refresh_token_hash, expires_at) VALUES ($1, $2, $3)`

        const refreshQueryResult = await pool.query(refreshTokenQuery,[user.id,hashedRefreshToken,expiresAt])

        res.status(200).json({
            message: "Login successful",
            access_token: accessToken,
            refresh_token: refreshToken,
            user: {
                id: user.id,
                username: user.username,
                role: user.role
            }
        })
    } catch (error){
        console.error("Login error:",error)
        res.status(500).json({error: "Internal server error"})
    }
})

// Refresh

app.post('/refresh', async (req, res) => {
    try {
    const { refreshToken } = req.body
    const decodedPayload = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET)
    const userId = decodedPayload.sub
    const refreshTokenQuery = `SELECT * FROM refresh_tokens INNER JOIN users ON refresh_tokens.user_id = users.id WHERE user_id = $1`
    const result = await pool.query(refreshTokenQuery,[userId])

    if (result.rows.length === 0){
        return res.status(401).json({error: "Invalid token"})
    }

    const isTokenValid = await bcrypt.compare(refreshToken,result.rows[0].refresh_token_hash)
    if ( !isTokenValid ) {
        return res.status(401).json({error: "Invalid token"})
    }
    const newAccessTokenPayload = {
        sub: userId,
        role: result.rows[0].role
    }

    const newAccessToken = jwt.sign(
        newAccessTokenPayload,
        process.env.JWT_SECRET,
        {expiresIn : '15m'}
    )
    res.status(200).json({
        message: 'Refresh successful',
        access_token: newAccessToken
    })
    } catch(error){
        console.error("Login error:",error)
        res.status(500).json({error: "Internal server error"})
    }
})


//Paginated fetching of products

app.get('/products', async (req, res)=>{
    try {
        const page = parseInt(req.query.page) || 1
        const limit = parseInt(req.query.limit) || 20
        const offset = (page - 1) * limit
        const productQuery = `SELECT 
                            p.id,
                            p.product_name, 
                            p.price::FLOAT, 
                            p.measurement_description, 
                            p.measurement::FLOAT,
                            p.image_url, 
                            s.supermarket_name
                        FROM 
                            products p 
                        JOIN 
                            supermarkets s 
                        ON 
                            p.supermarket = s.id
                        ORDER BY
                            p.product_name ASC
                        LIMIT 
                            $1 
                        OFFSET 
                            $2`
        const result = await pool.query(productQuery,[limit, offset])

        res.status(200).send(result.rows)
    } catch (err) {
        console.error("Search error:", err)
        res.status(500).send({ error: "Failed to fetch products" })
    }
})

//Search by product name

app.get('/search', async (req, res) =>{
    try {
        const searchTerm = `%${req.query.q}%`
        const searchQuery = `SELECT 
                p.id,
                p.product_name, 
                p.price::FLOAT,
                p.measurement_description, 
                p.measurement::FLOAT,
                p.image_url,
                s.supermarket_name
            FROM 
                products p
            JOIN 
                supermarkets s 
            ON 
                p.supermarket = s.id
            WHERE 
                p.product_name ILIKE $1
            ORDER BY
                p.product_name
            ASC`
        const result = await pool.query(searchQuery, [searchTerm])
        res.status(200).send(result.rows)
    } catch (err) {
        console.error("Search error:", err)
        res.status(500).send({error: "Failed to search products."})
    }
})

// Search by product id

app.get('/product/:id', async (req, res) =>{
    try {
        const id = req.params.id
        const searchQuery = `SELECT 
                p.id,
                p.product_name, 
                p.price::FLOAT,
                p.measurement_description, 
                p.measurement::FLOAT,
                p.image_url,
                s.supermarket_name
            FROM 
                products p
            JOIN 
                supermarkets s 
            ON 
                p.supermarket = s.id
            WHERE 
                p.id = $1`
        const result = await pool.query(searchQuery, [id])
        if (result.rows.length === 0) {
            return res.status(404).send({ error: "Product not found." });
        }
        res.status(200).send(result.rows[0])
    } catch (err) {
        console.error("Search error:", err)
        res.status(500).send({error: "Failed to search products."})
    }
})

// Get grocery lists with user id

app.get('/grocery-lists', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.sub; 

        const getListQuery = `
            SELECT 
            gl.id as gl_id,
            gl.name as grocery_list_name,
            p.id as p_id,
            p.product_name as product_name,
            p.price::FLOAT,
            p.measurement_description,
            p.measurement::FLOAT,
            p.image_url,
            s.supermarket_name as supermarket, /* Fetch the string name and alias it */
            gl_i.amount::INTEGER,
            gl_i.is_checked,
            gl_i.id as gli_id
            FROM grocery_lists as gl
            LEFT JOIN grocery_list_items as gl_i on gl.id = gl_i.gl_id
            LEFT JOIN products as p on gl_i.p_id = p.id
            LEFT JOIN supermarkets as s on p.supermarket = s.id /* Join the supermarkets table */
            WHERE gl.user_id = $1 
            ORDER BY gl.name ASC;
        `;

        const listQueryResult = await pool.query(getListQuery, [userId]);
        const groupedLists = {};

        for (const row of listQueryResult.rows) {
            if (!groupedLists[row.gl_id]) {
                groupedLists[row.gl_id] = {
                    id: row.gl_id,
                    name: row.grocery_list_name,
                    items: [],
                    purchased_items: []
                };
            }
            
            if (row.p_id != null) {
                const product = {
                    id: row.p_id,
                    product_name: row.product_name,
                    amount: row.amount,
                    price: row.price,
                    measurement: row.measurement,
                    measurement_description: row.measurement_description,
                    supermarket_name: row.supermarket,
                    image_url: row.image_url || ""
                };

                const groceryListItem = {
                    gli_id: row.gli_id,
                    item: product,
                    amount: parseInt(row.amount,10),
                    gl_id: row.gl_id
                };
                
                if (row.is_checked) {
                    groupedLists[row.gl_id].purchased_items.push(groceryListItem);
                } else {
                    groupedLists[row.gl_id].items.push(groceryListItem);
                }
            }
        }
        
        const finalResponse = Object.values(groupedLists);
        res.status(200).json(finalResponse);

    } catch (error) {
        console.error("Error fetching grocery list: ", error);
        res.status(500).json({ error: "Internal server error." });
    }
});

//Create grocery list

app.post('/grocery-lists', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.sub;
        const { name } = req.body;

        // 1. Basic validation to ensure the name isn't empty
        if (!name || name.trim() === "") {
            return res.status(400).json({ error: "Grocery list name is required." });
        }

        // 2. Insert the new list into the database
        // We use RETURNING to instantly grab the new UUID generated by Postgres
        const createListQuery = `
            INSERT INTO grocery_lists (user_id, name) 
            VALUES ($1, $2) 
            RETURNING id, name;
        `;

        const result = await pool.query(createListQuery, [userId, name]);
        const newList = result.rows[0];

        // 3. Construct the response to perfectly match your Swift model
        const finalResponse = {
            id: newList.id,
            name: newList.name,
            items: [],
            purchased_items: [],
            is_active: true 
        };

        // 201 Created is the standard HTTP status for a successful POST
        res.status(201).json(finalResponse);

    } catch (error) {
        console.error("Error creating grocery list: ", error);
        res.status(500).json({ error: "Internal server error." });
    }
});

//Add grocery list item

app.post('/grocery-lists/:listId/items', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.sub;
        const { listId } = req.params;
        const { productId, quantity } = req.body; 

        if (!productId || !quantity) {
            return res.status(400).json({ error: "productId and quantity are required." });
        }

        // 1. Insert the item (or update the amount if it already exists in the list)
        // Note: This assumes you have a unique constraint/primary key on (gl_id, p_id)
        const insertItemQuery = `
            INSERT INTO grocery_list_items (gl_id, p_id, amount, is_checked)
            VALUES ($1, $2, $3, false)
            ON CONFLICT (gl_id, p_id) DO UPDATE 
            SET amount = grocery_list_items.amount + EXCLUDED.amount;
        `;
        await pool.query(insertItemQuery, [listId, productId, quantity]);

        // 2. Fetch the fully updated list to return back to Swift
        const getUpdatedListQuery = `
            SELECT 
                gl.id as gl_id, gl.name as grocery_list_name,
                p.id as p_id, p.product_name as product_name, 
                p.price::FLOAT, p.measurement_description, p.measurement::FLOAT, 
                p.supermarket, p.image_url,
                gl_i.amount::INTEGER, gl_i.is_checked,
                gl_i.id as gli_id
            FROM grocery_list_items as gl_i
            INNER JOIN grocery_lists as gl on gl_i.gl_id = gl.id
            INNER JOIN products as p on gl_i.p_id = p.id
            WHERE gl.id = $1 AND gl.user_id = $2
            ORDER BY product_name ASC;
        `;
        
        const listQueryResult = await pool.query(getUpdatedListQuery, [listId, userId]);

        if (listQueryResult.rows.length === 0) {
            return res.status(404).json({ error: "Grocery list not found." });
        }

        // 3. Rebuild the Swift-friendly JSON structure for this single list
        let updatedList = {
            id: listId,
            name: listQueryResult.rows[0].grocery_list_name,
            items: [],
            purchased_items: [],
            is_active: true
        };

        for (const row of listQueryResult.rows) {
            const product = {
                id: row.p_id,
                product_name: row.product_name,
                price: row.price,
                measurement_description: row.measurement_description,
                measurement: row.measurement,
                supermarket_name: row.supermarket,
                image_url: row.image_url || ""
            };

            const groceryListItem = {
                gli_id: row.gli_id, 
                item: product, 
                quantity: parseInt(row.amount,10)
            };

            if (row.is_checked) {
                updatedList.purchased_items.push(groceryListItem);
            } else {
                updatedList.items.push(groceryListItem);
            }
        }

        // Return the single updated list object!
        res.status(200).json(updatedList);

    } catch (error) {
        console.error("Error inserting item into grocery list: ", error);
        res.status(500).json({ error: "Internal server error." });
    }
});

//Marking an item as checked

app.patch('/grocery-lists/:listId/items/:productId', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.sub;
        const { listId, productId } = req.params;
        const { isPurchased } = req.body;


        console.log("Debug Params:", { isPurchased, listId, productId, userId });
        console.log("Raw body:", req.body);
        console.log("Value:", req.body.isPurchased);
        console.log("Type:", typeof req.body.isPurchased);

        if (typeof isPurchased !== 'boolean') {
            return res.status(400).json({ error: "isChecked boolean is required." });
        }

        const updateItemQuery = `
            UPDATE grocery_list_items
            SET is_checked = $1
            WHERE gl_id = $2 AND p_id = $3
            AND EXISTS (
                SELECT 1 FROM grocery_lists 
                WHERE id = $2 AND user_id = $4
            );
        `;
        
        const updateResult = await pool.query(updateItemQuery, [isPurchased, listId, productId, userId]);

        if (updateResult.rowCount === 0) {
            return res.status(404).json({ error: "Item not found or unauthorized." });
        }

        const getUpdatedListQuery = `
            SELECT 
                gl.id as gl_id, gl.name as grocery_list_name,
                p.id as p_id, p.product_name as product_name, 
                p.price::FLOAT, p.measurement_description, p.measurement::FLOAT, 
                p.supermarket, p.image_url,
                s.supermarket_name,
                gl_i.amount::INT, gl_i.is_checked,
                gl_i.id as gli_id
            FROM grocery_list_items as gl_i
            INNER JOIN grocery_lists as gl on gl_i.gl_id = gl.id
            INNER JOIN products as p on gl_i.p_id = p.id
            LEFT JOIN supermarkets as s on p.supermarket = s.id
            WHERE gl.id = $1 AND gl.user_id = $2
            ORDER BY product_name ASC;
        `;
        
        const listQueryResult = await pool.query(getUpdatedListQuery, [listId, userId]);

        let updatedList = {
            id: listId,
            name: listQueryResult.rows[0].grocery_list_name,
            items: [],
            purchased_items: [],
            is_active: true
        };

        for (const row of listQueryResult.rows) {
            const product = {
                id: row.p_id,
                product_name: row.product_name,
                price: row.price,
                measurement_description: row.measurement_description,
                measurement: row.measurement,
                supermarket_name: row.supermarket_name,
                image_url: row.image_url || ""
            };

            const groceryListItem = {
                gli_id: row.gli_id, 
                item: product, 
                amount: parseInt(row.amount,10),
                gl_id: row.gl_id
            };

            if (row.is_checked) {
                updatedList.purchased_items.push(groceryListItem);
            } else {
                updatedList.items.push(groceryListItem);
            }
        }

        res.status(200).json(updatedList);

    } catch (error) {
        console.error("Error toggling item status: ", error);
        res.status(500).json({ error: "Internal server error." });
    }
});

//Find grocery list by ID

app.get('/grocery-lists/:listId', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.sub;
        const { listId } = req.params;

        // Note the LEFT JOINs here to handle empty lists!
        const getListQuery = `
            SELECT 
                gl.id as gl_id, gl.name as grocery_list_name,
                p.id as p_id, p.product_name as product_name, 
                p.price::FLOAT, p.measurement_description, p.measurement::FLOAT, 
                p.supermarket, p.image_url,
                gl_i.amount, gl_i.is_checked,
                gl_i.id as gli_id
            FROM grocery_lists as gl
            LEFT JOIN grocery_list_items as gl_i on gl.id = gl_i.gl_id
            LEFT JOIN products as p on gl_i.p_id = p.id
            WHERE gl.id = $1 AND gl.user_id = $2
            ORDER BY product_name ASC;
        `;
        
        const listQueryResult = await pool.query(getListQuery, [listId, userId]);

        if (listQueryResult.rows.length === 0) {
            return res.status(404).json({ error: "Grocery list not found." });
        }

        // Initialize the base list using the first row
        let fetchedList = {
            id: listQueryResult.rows[0].gl_id,
            list_name: listQueryResult.rows[0].grocery_list_name,
            items: [],
            purchased_items: [],
            is_active: true
        };

        // Populate the arrays only if products actually exist in this list
        for (const row of listQueryResult.rows) {
            if (row.p_id != null) { // Checks if the LEFT JOIN found an item
                const product = {
                    id: row.p_id,
                    product_name: row.product_name,
                    price: row.price,
                    measurement_description: row.measurement_description,
                    measurement: row.measurement,
                    supermarket_name: row.supermarket,
                    image_url: row.image_url || ""
                };

                const groceryListItem = {
                    gli_id: row.gli_id, 
                    item: product, 
                    quantity: parseInt(row.amount,10) 
                };

                if (row.is_checked) {
                    fetchedList.purchased_items.push(groceryListItem);
                } else {
                    fetchedList.items.push(groceryListItem);
                }
            }
        }

        res.status(200).json(fetchedList);

    } catch (error) {
        console.error("Error fetching single grocery list: ", error);
        res.status(500).json({ error: "Internal server error." });
    }
});