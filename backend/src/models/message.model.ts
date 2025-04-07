import { Schema, model, Document, Types } from 'mongoose';

export interface IMessage extends Document {
  chatId: Types.ObjectId;
  senderId: Types.ObjectId;
  text?: string;
  image?: string;
  file?: {
    url?: string;
    fileName?: string;
    fileType?: string;
  };
  seenBy?: Types.ObjectId[];
  createdAt?: Date;
  updatedAt?: Date;
}

const MessageSchema = new Schema<IMessage>(
  {
    chatId: { type: Schema.Types.ObjectId, ref: 'Chat', required: true },
    senderId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    text: { type: String },
    image: { type: String },
    file: {
      url: { type: String },
      fileName: { type: String },
      fileType: { type: String },
    },
    seenBy: [{ type: Schema.Types.ObjectId, ref: 'User' }],
  },
  { timestamps: true },
);

export default model<IMessage>('Message', MessageSchema);
