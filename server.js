const express = require("express");

const mongoose = require("mongoose");

const cors = require("cors");
 
const app = express();

app.use(cors());

app.use(express.json());
 
mongoose.connect("mongodb+srv://oumaymabenna2_db_user:Test123456@trigessalama.sw3x05v.mongodb.net/trig_essalama?retryWrites=true&w=majority&appName=trigEssalama")

.then(() => console.log("MongoDB Connected"))

.catch(err => console.log(err));
 
app.get("/", (req, res) => {

    res.send("API Working ✅");

});
 
app.listen(3000, () => {

    console.log("Server running on port 3000");

});
 