const express = require("express");
const authRouter = express.Router();
const bcryptjs = require("bcryptjs");
const User = require("../models/userModel");
const jwt = require('jsonwebtoken');
const auth = require("../middleware/auth");
const moment = require('moment-timezone');

authRouter.post("/signin", async (req, res) => {
  try {
    const { email, password } = req.body;

    // Check for missing email or password
    if (!email || !password) {
      return res.status(400).json({ msg: "Email and password are required!" });
    }

    // Find the user by email
    const user = await User.findOne({ where: { email } });

    // If no user is found
    if (!user) {
      return res.status(400).json({ msg: "User with this email does not exist!" });
    }

    // Verify password
    const isMatch = await bcryptjs.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ msg: "Incorrect Password" });
    }

    // Generate token with the user's MongoDB _id
    const token = jwt.sign({ id: user._id }, "passwordKey", { expiresIn: "1h" });

    // Send the token and user data back
    res.json({
      token,
      user: {
        id: user._id,
        first_name: user.first_name,
        last_name: user.last_name,
        email: user.email,
        role: user.role,
        created_at: moment(user.created_at).tz('Europe/Berlin').format('YYYY-MM-DD HH:mm:ss'),
        matriculation_number: user.matriculation_number,
        password: user.password,
      },
    });
  } catch (e) {
    console.error("Error during login:", e.message);
    res.status(500).json({ error: e.message });
  }
});

authRouter.post("/tokenIsValid", async (req, res) => {
    try{
        const token = req.header("x-auth-token");
        if(!token){
            return res.json(false);
        }
        // if there is token, the we verify it
        const verified = jwt.verify(token, "passwordKey");
        if(!verified){
            return res.json(false);
        }

        const user = await User.findById(verified.id);
        if(!user){
            return res.json(false);
        }
        res.json(true);
    }catch (e){
        res.status(500).json({ error: e.message });
    }
});

// get user data
// auth is a middleware, whic will extract the token,
// and lets us know the user is authenticated or not
// and this auth is present in middleware/auth.js
authRouter.get("/", auth, async (req, res)=>{
    const user = await User.findById(req.user);
    res.json({...user._doc, token: req.token});

});

// exportingauthRouter, so we can use in index.js
module.exports = authRouter;