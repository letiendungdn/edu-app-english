import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from "@nestjs/common";
import type { Request } from "express";
import { EnglishAuthService } from "./english-auth.service";
import type { EnglishAuthRequest } from "./english-current-user.decorator";

@Injectable()
export class EnglishAuthGuard implements CanActivate {
  constructor(private readonly authService: EnglishAuthService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context
      .switchToHttp()
      .getRequest<EnglishAuthRequest & Request>();
    const user = await this.authService.verifyRequest(request);
    if (!user) {
      throw new UnauthorizedException("Unauthorized");
    }
    request.englishUser = user;
    return true;
  }
}

@Injectable()
export class EnglishOptionalAuthGuard implements CanActivate {
  constructor(private readonly authService: EnglishAuthService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context
      .switchToHttp()
      .getRequest<EnglishAuthRequest & Request>();
    request.englishUser = await this.authService.verifyRequest(request);
    return true;
  }
}
