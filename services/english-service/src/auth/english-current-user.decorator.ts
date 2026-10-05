import {
  createParamDecorator,
  ExecutionContext,
  UnauthorizedException,
} from "@nestjs/common";
import { Role } from "@edu/prisma-english/client";

export interface EnglishUserPayload {
  id: number;
  email: string;
  role: Role;
  name: string | null;
}

export interface EnglishAuthRequest {
  englishUser?: EnglishUserPayload | null;
}

export const CurrentEnglishUser = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): EnglishUserPayload => {
    const request = ctx.switchToHttp().getRequest<EnglishAuthRequest>();
    const user = request.englishUser;
    if (!user) {
      throw new UnauthorizedException("Unauthorized");
    }
    return user;
  },
);
