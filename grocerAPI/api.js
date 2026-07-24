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

const authenticateToken = (req,req,next)=>{
    const authHeader = req.headers['Authorization'];
    const token = authHeader && autherHeader.split(' ')[1];

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
            {expiresIn: '15m'}
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
            {expiresIn : '15m'}
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
                            p.product_name as "productName", 
                            p.price::FLOAT, 
                            p.measurement_description as "measurementDescription", 
                            p.measurement::FLOAT,
                            p.image_url as "imageURL", 
                            s.supermarket_name as "supermarketName"
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
                p.product_name as "productName", 
                p.price::FLOAT,
                p.measurement_description as "measurementDescription", 
                p.measurement::FLOAT,
                p.image_url as "imageURL",
                s.supermarket_name as "supermarketName"
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
                p.product_name as "productName", 
                p.price::FLOAT,
                p.measurement_description as "measurementDescription", 
                p.measurement::FLOAT,
                p.image_url as "imageURL",
                s.supermarket_name as "supermarketName"
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

// Create grocery lists

app.get('/grocery-list', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.sub; 

        const getListQuery = `
            SELECT 
                gl.id,
                gl.amount,
                gl.is_checked AS "isChecked",
                json_build_object(
                    'id', p.id,
                    'productName', p.product_name,
                    'price', p.price,
                    'measurementDescription', p.measurement_description,
                    'measurement', p.measurement,
                    'supermarketName', p.supermarket_name,
                    'imageURL', p.image_url
                ) AS product
            FROM grocery_lists gl
            JOIN products p ON gl.product_id = p.id
            WHERE gl.user_id = $1
            ORDER BY gl.id ASC;
        `;

        const listQueryResult = await pool.query(getListQuery, [userId]);
        res.status(200).json(listQueryResult.rows);

    } catch (error) {
        console.error("Error fetching grocery list: ", error);
        res.status(500).json({ error: "Internal server error." });
    }
});


