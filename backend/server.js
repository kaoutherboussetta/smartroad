const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const bcrypt = require("bcryptjs");

const app = express();
app.use(cors());
app.use(express.json());

mongoose
  .connect("mongodb+srv://oumaymabenna2_db_user:Test123456@trigessalama.sw3x05v.mongodb.net/trig_essalama?retryWrites=true&w=majority&appName=trigEssalama")
  .then(() => console.log("MongoDB Connected"))
  .catch((err) => console.log(err));

// Schéma utilisateur (collection user_citoyens)
const userCitoyenSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true, trim: true, lowercase: true },
  passwordHash: { type: String, required: true },
  firstName: { type: String, required: true },
  lastName: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now },
  isActive: { type: Boolean, default: true },
  rememberMe: { type: Boolean, default: false },
  acceptTerms: { type: Boolean, default: false },
  phoneNumber: { type: String, default: "" },
});
const UserCitoyen = mongoose.model("UserCitoyen", userCitoyenSchema, "user_citoyens");

app.get("/", (req, res) => {
  res.send("API Working ✅");
});

// Inscription
app.post("/api/register", async (req, res) => {
  try {
    const { firstName, lastName, email, password, acceptTerms } = req.body;
    if (!email || !password || !firstName || !lastName) {
      return res.status(400).json({ error: "Champs requis manquants" });
    }
    const existing = await UserCitoyen.findOne({ email: email.trim().toLowerCase() });
    if (existing) {
      return res.status(400).json({ error: "Un compte avec cet email existe déjà" });
    }
    const passwordHash = await bcrypt.hash(password, 10);
    const user = new UserCitoyen({
      email: email.trim().toLowerCase(),
      passwordHash,
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      acceptTerms: !!acceptTerms,
      isActive: true,
    });
    await user.save();
    res.status(201).json({ success: true, id: user._id.toString() });
  } catch (err) {
    if (err.code === 11000) {
      return res.status(400).json({ error: "Un compte avec cet email existe déjà" });
    }
    res.status(500).json({ error: err.message || "Erreur inscription" });
  }
});

// Connexion
app.post("/api/login", async (req, res) => {
  try {
    const { email, password, rememberMe } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: "Email et mot de passe requis" });
    }
    const user = await UserCitoyen.findOne({ email: email.trim().toLowerCase() });
    if (!user || !user.isActive) {
      return res.status(401).json({ error: "Email ou mot de passe incorrect" });
    }
    const ok = await bcrypt.compare(password, user.passwordHash);
    if (!ok) {
      return res.status(401).json({ error: "Email ou mot de passe incorrect" });
    }
    if (rememberMe !== undefined) {
      user.rememberMe = !!rememberMe;
      user.updatedAt = new Date();
      await user.save();
    }
    res.json({
      id: user._id.toString(),
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      rememberMe: user.rememberMe,
      isActive: user.isActive,
      phoneNumber: user.phoneNumber || "",
    });
  } catch (err) {
    res.status(500).json({ error: err.message || "Erreur connexion" });
  }
});

// Vérifier si l'email existe
app.get("/api/email-exists/:email", async (req, res) => {
  try {
    const email = (req.params.email || "").trim().toLowerCase();
    const user = await UserCitoyen.findOne({ email });
    res.json({ exists: !!user });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Mettre à jour le mot de passe
app.put("/api/update-password", async (req, res) => {
  try {
    const { email, currentPassword, newPassword } = req.body;
    if (!email || !currentPassword || !newPassword) {
      return res.status(400).json({ error: "Champs requis manquants" });
    }
    const user = await UserCitoyen.findOne({ email: email.trim().toLowerCase() });
    if (!user) {
      return res.status(404).json({ error: "Utilisateur non trouvé" });
    }
    const ok = await bcrypt.compare(currentPassword, user.passwordHash);
    if (!ok) {
      return res.status(400).json({ error: "Mot de passe actuel incorrect" });
    }
    user.passwordHash = await bcrypt.hash(newPassword, 10);
    user.updatedAt = new Date();
    await user.save();
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(3000, '0.0.0.0', () => {
  console.log("Server running on port 3000");
});
