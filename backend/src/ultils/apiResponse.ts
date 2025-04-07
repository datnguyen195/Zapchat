import { Response } from 'express';

import { ApiResponse } from '../interfaces/apiResponse';

export const sendResponse = <T>(
  res: Response,
  statusCode: number,
  success: boolean,
  message: string,
  data: T | null = null,
): Response<ApiResponse<T>> => {
  return res.status(statusCode).json({
    success,
    message,
    errorCode: statusCode,
    data,
  });
};
