const express = require('express');
const mongoose = require('mongoose');
const axios = require('axios');
require('dotenv').config();

const app = express();
app.use(express.json());

// MongoDB connection
mongoose.connect(process.env.MONGODB_URI || 'mongodb://mongodb:27017/cartdb', {
  useNewUrlParser: true,
  useUnifiedTopology: true
});

// Cart Item Schema
const cartItemSchema = new mongoose.Schema({
  productId: { type: String, required: true },
  quantity: { type: Number, required: true, min: 1 },
  price: { type: Number, required: true },
  name: String
});

// Cart Schema
const cartSchema = new mongoose.Schema({
  userId: { type: String, required: true, unique: true },
  items: [cartItemSchema],
  totalAmount: { type: Number, default: 0 },
  updatedAt: { type: Date, default: Date.now }
});

const Cart = mongoose.model('Cart', cartSchema);

// Helper function to get product details
async function getProductDetails(productId) {
  try {
    const response = await axios.get(`http://product-service:3002/${productId}`);
    return response.data;
  } catch (error) {
    return null;
  }
}

// Routes
app.get('/:userId', async (req, res) => {
  try {
    let cart = await Cart.findOne({ userId: req.params.userId });
    if (!cart) {
      cart = new Cart({ userId: req.params.userId, items: [] });
      await cart.save();
    }
    res.json(cart);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/:userId/items', async (req, res) => {
  try {
    const { productId, quantity } = req.body;
    
    // Get product details
    const product = await getProductDetails(productId);
    if (!product) {
      return res.status(404).json({ error: 'Product not found' });
    }

    // Check stock
    if (product.stock < quantity) {
      return res.status(400).json({ error: 'Insufficient stock' });
    }

    let cart = await Cart.findOne({ userId: req.params.userId });
    if (!cart) {
      cart = new Cart({ userId: req.params.userId, items: [] });
    }

    // Check if item already in cart
    const existingItem = cart.items.find(item => item.productId === productId);
    if (existingItem) {
      existingItem.quantity += quantity;
    } else {
      cart.items.push({
        productId,
        quantity,
        price: product.price,
        name: product.name
      });
    }

    // Update total amount
    cart.totalAmount = cart.items.reduce((total, item) => 
      total + (item.price * item.quantity), 0
    );
    
    cart.updatedAt = new Date();
    await cart.save();

    res.json(cart);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.delete('/:userId/items/:productId', async (req, res) => {
  try {
    const cart = await Cart.findOne({ userId: req.params.userId });
    if (!cart) {
      return res.status(404).json({ error: 'Cart not found' });
    }

    cart.items = cart.items.filter(item => item.productId !== req.params.productId);
    cart.totalAmount = cart.items.reduce((total, item) => 
      total + (item.price * item.quantity), 0
    );
    
    cart.updatedAt = new Date();
    await cart.save();

    res.json(cart);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.put('/:userId/items/:productId', async (req, res) => {
  try {
    const { quantity } = req.body;
    const cart = await Cart.findOne({ userId: req.params.userId });
    
    if (!cart) {
      return res.status(404).json({ error: 'Cart not found' });
    }

    const item = cart.items.find(item => item.productId === req.params.productId);
    if (!item) {
      return res.status(404).json({ error: 'Item not found in cart' });
    }

    // Check stock
    const product = await getProductDetails(req.params.productId);
    if (product && product.stock < quantity) {
      return res.status(400).json({ error: 'Insufficient stock' });
    }

    item.quantity = quantity;
    cart.totalAmount = cart.items.reduce((total, item) => 
      total + (item.price * item.quantity), 0
    );
    
    cart.updatedAt = new Date();
    await cart.save();

    res.json(cart);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.delete('/:userId/clear', async (req, res) => {
  try {
    await Cart.findOneAndDelete({ userId: req.params.userId });
    res.json({ message: 'Cart cleared successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3003;
app.listen(PORT, () => {
  console.log(`Cart service running on port ${PORT}`);
});
