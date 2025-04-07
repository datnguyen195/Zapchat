import { Schema, model, Document, Types } from 'mongoose';

export interface IChat extends Document {
  type: 'private' | 'group';
  participants: Types.ObjectId[];
  groupName?: string;
  groupAvatar?: string;
  createdBy: Types.ObjectId;
  createdAt?: Date;
  updatedAt?: Date;
}

const ChatSchema = new Schema<IChat>(
  {
    type: { type: String, enum: ['private', 'group'], required: true },
    participants: [{ type: Schema.Types.ObjectId, ref: 'User' }],
    groupName: { type: String },
    groupAvatar: { type: String },
    createdBy: { type: Schema.Types.ObjectId, ref: 'User' },
  },
  { timestamps: true },
);

export default model<IChat>('Chat', ChatSchema);
