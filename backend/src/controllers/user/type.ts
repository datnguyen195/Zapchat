export interface CreateUserInput {
  username: string;
  email: string;
  password: string;
  avatar?: string;
}

export interface LoginUserInput {
  email: string;
  password: string;
}
