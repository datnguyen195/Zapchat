import { Schema, model, Document, Types } from 'mongoose';

export interface IMessageStatus extends Document {
  messageId: Types.ObjectId;
  userId: Types.ObjectId;
  status: 'sent' | 'delivered' | 'seen';
  createdAt?: Date;
  updatedAt?: Date;
}

const MessageStatusSchema = new Schema<IMessageStatus>(
  {
    messageId: { type: Schema.Types.ObjectId, ref: 'Message', required: true },
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    status: {
      type: String,
      enum: ['sent', 'delivered', 'seen'],
      required: true,
    },
  },
  { timestamps: true },
);

export default model<IMessageStatus>('MessageStatus', MessageStatusSchema);
