import expressAsyncHandler from 'express-async-handler';
import { Request, Response } from 'express';
import { User } from '../../models';
import { sendResponse } from '../../ultils/apiResponse';
import { CreateUserInput, LoginUserInput } from './type';
import bcrypt from 'bcrypt';

export const createUser = expressAsyncHandler(
  async (req: Request, res: Response) => {
    const user: CreateUserInput = req.body.params ?? req.body;

    const existingUser = await User.findOne({ email: user.email });
    if (existingUser) {
      sendResponse(res, 400, false, 'Email đã được sử dụng', null);
      return;
    }

    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(user.password, saltRounds);

    const newUser = new User({
      username: user.username,
      email: user.email,
      password: hashedPassword,
      avatar: user.avatar,
    });

    await newUser.save();

    sendResponse(res, 201, true, 'User đã được tạo thành công', newUser);
    return;
  },
);

export const loginUser = expressAsyncHandler(
  async (req: Request, res: Response) => {
    const { email, password }: LoginUserInput = req.body.params ?? req.body;
    const user = await User.findOne({ email });

    if (!user) {
      sendResponse(res, 400, false, 'Email không tồn tại', null);
      return;
    }

    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      sendResponse(res, 400, false, 'Mật khẩu không chính xác', null);
      return;
    }

    sendResponse(res, 200, true, 'Đăng nhập thành công', {
      user,
      // token,
    });
    return;
  },
);
