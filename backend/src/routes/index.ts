import { Application } from 'express';

import userRouter from './user';

const initRoutes = (app: Application) => {
  app.use('/api/user', userRouter);
};

export default initRoutes;
