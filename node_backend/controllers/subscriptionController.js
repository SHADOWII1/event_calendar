const Subscription = require('../models/Subscription');

exports.subscribeStudent = async (req, res) => {
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
};
