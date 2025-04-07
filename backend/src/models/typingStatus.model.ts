import { Schema, model, Document, Types } from 'mongoose';

export interface ITypingStatus extends Document {
  chatId: Types.ObjectId;
  userId: Types.ObjectId;
  isTyping: boolean;
  createdAt?: Date;
  updatedAt?: Date;
}

const TypingStatusSchema = new Schema<ITypingStatus>(
  {
    chatId: { type: Schema.Types.ObjectId, ref: 'Chat', required: true },
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    isTyping: { type: Boolean, default: false },
  },
  { timestamps: true },
);

export default model<ITypingStatus>('TypingStatus', TypingStatusSchema);
