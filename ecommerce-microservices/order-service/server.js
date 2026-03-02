const express = require('express');
const mongoose = require('mongoose');
const axios = require('axios');
require('dotenv').config();

const app = express();
app.use(express.json());

// MongoDB connection
mongoose.connect(process.env.MONGODB_URI || 'mongodb://mongodb:27017/orderdb', {
  useNewUrlParser: true,
  useUnifiedTopology: true
});

// Order Item Schema
const orderItemSchema = new mongoose.Schema({
  productId: { type: String, required: true },
  quantity: { type: Number, required: true },
  price: { type: Number, required: true },
  name: String
});

// Order Schema
const orderSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  items: [orderItemSchema],
  totalAmount: { type: Number, required: true },
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'shipped', 'delivered', 'cancelled'],
    default: 'pending'
  },
  shippingAddress: {
    street: String,
    city: String,
    state: String,
    zipCode: String,
    country: String
  },
  paymentMethod: String,
  paymentStatus: {
    type: String,
    enum: ['pending', 'completed', 'failed'],
    default: 'pending'
  },
  createdAt: { type: Date, default: Date.now }
});

const Order = mongoose.model('Order', orderSchema);

// Helper functions
async function getUserDetails(userId) {
  try {
    const response = await axios.get(`http://user-service:3001/${userId}`);
    return response.data;
  } catch (error) {
    return null;
  }
}

async function updateProductStock(productId, quantity) {
  try {
    await axios.put(`http://product-service:3002/${productId}/stock`, { quantity });
    return true;
  } catch (error) {
    return false;
  }
}

async function clearUserCart(userId) {
  try {
    await axios.delete(`http://cart-service:3003/${userId}/clear`);
    return true;
  } catch (error) {
    return false;
  }
}

// Routes
app.post('/', async (req, res) => {
  try {
    const { userId, items, shippingAddress, paymentMethod } = req.body;

    // Validate user
    const user = await getUserDetails(userId);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Calculate total amount
    const totalAmount = items.reduce((total, item) => 
      total + (item.price * item.quantity), 0
    );

    // Create order
    const order = new Order({
      userId,
      items,
      totalAmount,
      shippingAddress: shippingAddress || user.address,
      paymentMethod
    });

    // Update product stock
    for (const item of items) {
      const updated = await updateProductStock(item.productId, item.quantity);
      if (!updated) {
        return res.status(400).json({ 
          error: `Failed to update stock for product ${item.productId}` 
        });
      }
    }

    await order.save();

    // Clear user's cart
    await clearUserCart(userId);

    res.status(201).json(order);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/user/:userId', async (req, res) => {
  try {
    const orders = await Order.find({ userId: req.params.userId })
      .sort({ createdAt: -1 });
    res.json(orders);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/:orderId', async (req, res) => {
  try {
    const order = await Order.findById(req.params.orderId);
    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }
    res.json(order);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.put('/:orderId/status', async (req, res) => {
  try {
    const { status } = req.body;
    const order = await Order.findById(req.params.orderId);
    
    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }

    order.status = status;
    await order.save();

    res.json(order);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.put('/:orderId/payment', async (req, res) => {
  try {
    const { paymentStatus } = req.body;
    const order = await Order.findById(req.params.orderId);
    
    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }

    order.paymentStatus = paymentStatus;
    await order.save();

    res.json(order);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3004;
app.listen(PORT, () => {
  console.log(`Order service running on port ${PORT}`);
});
