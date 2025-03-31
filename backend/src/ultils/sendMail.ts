import expressAsyncHandler from 'express-async-handler';

import nodemailer from 'nodemailer';

const sendMail = expressAsyncHandler(async (req, res, next) => {
  let transporter = nodemailer.createTransport({
    host: '',
    port: 587,
    secure: false,
    auth: {
      user: process.env.EMAIL_NAME ?? '',
      pass: process.env.EMAIL_APP_PASSWORD ?? '',
    },
  });

  res.send('Mail sent successfully');
});

export default sendMail;
