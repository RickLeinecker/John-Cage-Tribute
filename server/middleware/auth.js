const jwt = require("jsonwebtoken");
const config = require("config");

function auth(req, res, next) {
    const token = req.header("x-auth-token");

    // Check for token
    if (!token) {
        console.log('auth: No token was found!')
        return res.status(401).json({ msg: "No token, authorizaton denied" });
    }

    try {
        // Verify token
        // const decoded = jwt.verify(token, process.env.JWT_SECRET);
	const decoded = jwt.verify(token, config.get('jwtSecret'));

        // Add user from payload
        req.user = decoded;
        next();
    } catch (e) {
        console.log('auth: Token verification error!')
        res.status(400).json({ msg: "Token is not valid" });
    }
}

module.exports = auth;
