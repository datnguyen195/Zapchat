export interface ApiResponse<T> {
  success: boolean;
  message: string;
  errorCode?: string | null;
  data: T | null;
}
