import expressAsyncHandler from 'express-async-handler';

import { Request, Response } from 'express';

import { User } from '../../models';
import { sendResponse } from '../../ultils/apiResponse';

import { CreateUserInput } from './type';

export const createUser = expressAsyncHandler(
  async (req: Request<CreateUserInput>, res: Response) => {
    const user = req.body.params ?? req.body;

    const existingUser = await User.findOne({ email: user.email });
    if (existingUser) {
      sendResponse(res, 400, false, 'Email đã được sử dụng', null);
      return;
    }

    const newUser = new User(user);
    await newUser.save();

    sendResponse(res, 201, true, 'User đã được tạo thành công', newUser);
    return;
  },
);
