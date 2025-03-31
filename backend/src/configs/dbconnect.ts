import { ConnectionStates } from 'mongoose';
const mongoose = require('mongoose');

const dbConnect = async () => {
  // console.log(process.env.MONGO_URI);
  try {
    const res = await mongoose.connect(process.env.MONGO_URI ?? '');
    if (res.connection.readyState === ConnectionStates.connected) {
      console.log('DB connected succesfully');
    } else {
      console.log('DB connecting');
    }
  } catch (error) {
    console.log('DB connect error');
  }
};

export default dbConnect;
