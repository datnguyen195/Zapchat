import { Request, Response, NextFunction } from 'express';

import jwt from 'jsonwebtoken';

// Extend the Request interface to include the `user` property
declare global {
  namespace Express {
    interface Request {
      user?: UserPayload;
    }
  }
}

type UserPayload = {
  userId: string;
  email: string;
};

const JWT_SECRET = process.env.JWT_SECRET || 'default_secret';

export const authMiddleware = (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  const authHeader = req.headers.authorization;
  if (!authHeader?.startsWith('Bearer ')) {
    return res.status(401).json({ success: false, message: 'Thiếu token' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, JWT_SECRET) as UserPayload;
    req.user = decoded;
    next();
  } catch (error) {
    return res
      .status(401)
      .json({ success: false, message: 'Token không hợp lệ' });
  }
};
