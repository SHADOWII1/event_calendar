const Subscription = require('../models/subscriptionModel');
const Training = require('../models/trainingModel');
const express = require("express");
const subscriptionRouter = express.Router();

subscriptionRouter.post("/subscribe", async (req, res) => {
    const { matriculation_number, training_code } = req.body;
      try {
        const exists = await Subscription.findOne({ where: { matriculation_number, training_code } });
        if (exists) {
          return res.status(400).json({ msg: "Subscription already exists." });
        }
        await Subscription.create({ matriculation_number, training_code });
        res.status(201).json({ msg: "Subscription successful." });
      } catch (e) {
        res.status(500).json({ error: e.message });
      }
});

subscriptionRouter.delete("/unsubscribe", async (req, res) => {
   const { matriculation_number, training_code } = req.body;
     try {
       const subscription = await Subscription.findOne({ where: { matriculation_number, training_code } });
       if (!subscription) {
         return res.status(404).json({ msg: "Subscription not found." });
       }
       await subscription.destroy();
       res.status(200).json({ msg: "Unsubscribed successfully." });
     } catch (e) {
       res.status(500).json({ error: e.message });
     }
});

subscriptionRouter.get("/get-subscriptions", async (req, res) => {
  const { matriculation_number } = req.query; // Get matriculation number from query string

  try {
    // Fetch all subscription records for the given matriculation number
    const subscriptions = await Subscription.findAll({
      where: { matriculation_number },
      attributes: ['training_code'], // Only fetch training codes
    });

    if (!subscriptions.length) {
      return res.status(404).json({ msg: "No subscriptions found." });
    }

    // Extract training codes from subscriptions
    const trainingCodes = subscriptions.map(sub => sub.training_code);

    // Fetch detailed information for each training based on training codes
    const trainings = await Training.findAll({
      where: {
        code: trainingCodes,
      },
      attributes: [
        'id_training',
        'title',
        'code',
        'description',
        'start_date',
        'end_date',
        'start_time',
        'end_time',
        'max_enrolled_students',
        'min_enrolled_students',
      ],
    });

    // Check if training details were found
    if (!trainings.length) {
      return res.status(404).json({ msg: "No trainings found for subscriptions." });
    }

    // Respond with training details
    res.status(200).json(trainings);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

subscriptionRouter.get("/check-subscription", async (req, res) => {
  const { matriculation_number, training_code } = req.query;

  if (!matriculation_number || !training_code) {
        return res.status(400).json({ error: "Missing matriculation_number or training_code" });
  }

  try {
    // Find the subscription based on matriculation number and training code
    const subscription = await Subscription.findOne({
      where: { matriculation_number, training_code },
    });

    if (!subscription) {
      return res.status(200).json({ isSubscribed: false });
    }

    // Respond with the subscription details
    res.status(200).json({ isSubscribed: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

subscriptionRouter.get("/subscribed-students-count", async (req, res) => {
  const { training_code } = req.query; // Use query parameters to pass the training code

  try {
    // Count the number of subscriptions for the given training code
    const count = await Subscription.count({
      where: { training_code: training_code },
    });

    res.status(200).json({ subscribedStudents: count });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

subscriptionRouter.get("/student-subscriptions-count", async (req, res) => {
  const { matriculation_number } = req.query; // Extract student ID from the query parameters

  try {
    if (!matriculation_number) {
      // Check if the student ID is provided
      return res.status(400).json({ error: 'Student Matriculation Number is required' });
    }

    // Count the number of subscriptions for the given student ID
    const count = await Subscription.count({
      where: { matriculation_number: matriculation_number },
    });

    // Respond with the count of subscriptions for the student
    res.status(200).json({ subscriptionsCount: count });
  } catch (e) {
    // General error handling with more detailed error messages
    console.error("Error fetching student subscriptions count:", e);
    res.status(500).json({ error: `Error fetching student subscriptions: ${e.message}` });
  }
});




module.exports = subscriptionRouter;
