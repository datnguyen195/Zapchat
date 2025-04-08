import { Schema, model, Document, Types } from 'mongoose';

export interface IUser extends Document {
  username: string;
  email: string;
  password: string;
  avatar?: string;
  status?: 'online' | 'offline';
  friends?: Types.ObjectId[];
  createAt?: Date;
  updateAt?: Date;
}

const UserSchema = new Schema<IUser>(
  {
    username: { type: String, required: true, unique: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    avatar: { type: String, default: '' },
    status: { type: String, enum: ['online', 'offline'], default: 'offline' },
    friends: [{ type: Schema.Types.ObjectId, ref: 'User' }],
  },
  { timestamps: true },
);

export default model<IUser>('User', UserSchema);
